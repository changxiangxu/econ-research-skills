/*==============================================================================
  Run all DID methods, export event study plots as PNG
  Output: PNG files saved to current working directory
==============================================================================*/

clear all
set more off
timer clear
set seed 10
set scheme s2color
global T = 15
global I = 400

* ═══════════════════════════════════════════════════════════
* DATA (Borusyak verified DGP)
* ═══════════════════════════════════════════════════════════
set obs `=$I*$T'
gen i = int((_n-1)/$T )+1
gen t = mod((_n-1)/$T )+1
tsset i t

gen Ei = ceil(runiform()*7)+$T -6 if t==1
bys i (t): replace Ei = Ei[1]
gen K = t-Ei
gen D = K>=0 & Ei!=.
gen tau = cond(D==1, (t-Ei), 0)
gen eps = rnormal()
gen Y = i + 3*t + tau*D + eps

* Prep variables
gen gvar = cond(Ei>15, 0, Ei)
sum Ei
gen lastcohort = Ei==r(max)

forvalues l = 0/5 {
	gen L`l'event = K==`l'
}
forvalues l = 1/14 {
	gen F`l'event = K==-`l'
}
drop F1event

* True values
matrix btrue = J(1,6,.)
matrix colnames btrue = tau0 tau1 tau2 tau3 tau4 tau5
qui forvalues h = 0/5 {
	sum tau if K==`h'
	matrix btrue[1,`h'+1]=r(mean)
}


* ═══════════════════════════════════════════════════════════
* (1) BJS IMPUTATION
* ═══════════════════════════════════════════════════════════
di _newline ">>> [1/7] BJS Imputation..."
did_imputation Y i t Ei, allhorizons pretrend(5)
event_plot, default_look graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") title("Borusyak et al. (2024) Imputation") ///
	xlabel(-5(1)5) name(g_bjs, replace))
graph export "01_bjs.png", replace width(1200)
estimates store bjs


* ═══════════════════════════════════════════════════════════
* (2) dCDH (2020)
* ═══════════════════════════════════════════════════════════
di _newline ">>> [2/7] dCDH..."
did_multiplegt Y i t D, robust_dynamic dynamic(5) placebo(5) ///
	longdiff_placebo breps(30) cluster(i)
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin-D'Haultfoeuille (2020)") xlabel(-5(1)5) ///
	name(g_dcdh, replace)) ///
	stub_lag(Effect_#) stub_lead(Placebo_#) together
graph export "02_dcdh.png", replace width(1200)
matrix dcdh_b = e(estimates)
matrix dcdh_v = e(variances)


* ═══════════════════════════════════════════════════════════
* (3) CALLAWAY-SANT'ANNA (2021)
* ═══════════════════════════════════════════════════════════
di _newline ">>> [3/7] Callaway-Sant'Anna..."
csdid Y, ivar(i) time(t) gvar(gvar) agg(event)
event_plot e(b)#e(V), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-13(1)5) title("Callaway-Sant'Anna (2021)") ///
	name(g_cs, replace)) ///
	stub_lag(T+#) stub_lead(T-#) together
graph export "03_cs.png", replace width(1200)
matrix cs_b = e(b)
matrix cs_v = e(V)


* ═══════════════════════════════════════════════════════════
* (4) SUN-ABRAHAM (2021)
* ═══════════════════════════════════════════════════════════
di _newline ">>> [4/7] Sun-Abraham..."
eventstudyinteract Y L*event F*event, vce(cluster i) absorb(i t) ///
	cohort(Ei) control_cohort(lastcohort)
event_plot e(b_iw)#e(V_iw), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-14(1)5) title("Sun-Abraham (2021)") ///
	name(g_sa, replace)) ///
	stub_lag(L#event) stub_lead(F#event) together
graph export "04_sa.png", replace width(1200)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)


* ═══════════════════════════════════════════════════════════
* (5) GARDNER did2s (2022)
* ═══════════════════════════════════════════════════════════
di _newline ">>> [5/7] Gardner did2s..."
did2s Y, first_stage(i.i i.t) second_stage(F*event L*event) ///
	treatment(D) cluster(i)
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-14(1)5) title("Gardner (2022) Two-Stage") name(g_did2s, replace))
graph export "05_gardner.png", replace width(1200)
matrix did2s_b = e(b)
matrix did2s_v = e(V)


* ═══════════════════════════════════════════════════════════
* (6) TWFE OLS (biased baseline)
* ═══════════════════════════════════════════════════════════
di _newline ">>> [6/7] TWFE OLS..."
reghdfe Y F*event L*event, absorb(i t) vce(cluster i)
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
	graph_opt(xtitle("Periods since the event") ytitle("OLS coefficients") ///
	xlabel(-14(1)5) title("TWFE OLS (biased)") name(g_ols, replace))
graph export "06_twfe.png", replace width(1200)
estimates store ols


* ═══════════════════════════════════════════════════════════
* (7) COMBINED COMPARISON PLOT
* ═══════════════════════════════════════════════════════════
di _newline ">>> [7/7] Combined comparison plot..."

event_plot btrue# bjs dcdh_b#dcdh_v cs_b#cs_v sa_b#sa_v did2s_b#did2s_v ols, ///
	stub_lag(tau# tau# Effect_# T+# L#event L#event L#event) ///
	stub_lead(pre# pre# Placebo_# T-# F#event F#event F#event) ///
	plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.1)0.325) trimlead(5) noautolegend ///
	graph_opt(title("DID Estimator Comparison (400 units, 15 periods)", size(med)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") ///
		xlabel(-5(1)5) ylabel(0(1)5) ///
		legend(order(1 "True value" 2 "BJS (2024)" 4 "dCDH (2020)" ///
			6 "CS (2021)" 8 "SA (2021)" 10 "Gardner (2022)" ///
			12 "TWFE OLS") rows(2) position(6) region(style(none))) ///
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) ///
		graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(black)) lag_ci_opt1(color(black)) ///
	lag_opt2(msymbol(O) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) ///
	lag_opt5(msymbol(Sh) color(dkorange)) lag_ci_opt5(color(dkorange)) ///
	lag_opt6(msymbol(Oh) color(purple)) lag_ci_opt6(color(purple)) ///
	lag_opt7(msymbol(Dh) color(red)) lag_ci_opt7(color(red))
graph export "00_all_methods_comparison.png", replace width(1600)

di _newline "========================================"
di "  ALL DONE! Check PNG files in CWD."
di "========================================"
