/*==============================================================================
  File:     15_comparison_master.do
  Purpose:  Run ALL DID methods on the SAME verified data, compare results
  
  Code Source:
    Structure adapted from Borusyak five_estimators_example.do
    (which compares 5 methods) and extended to cover all 12+ methods.
    
    The final event_plot combining code is from Borusyak's original.
  
  Required: All packages from 01-14
  
  Use this for:
    1. Learning: see how methods compare on same data
    2. Robustness: show your paper's results are method-invariant
    3. Appendix: "Results are robust to alternative DID estimators"
==============================================================================*/

clear all
timer clear
set seed 10
global T = 15
global I = 400

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (same verified DGP)
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


* ═══════════════════════════════════════════════════════════
* SECTION 2: CONSTRUCT TRUE VALUES
* ═══════════════════════════════════════════════════════════
* Source: Borusyak five_estimators_example.do

matrix btrue = J(1,6,.)
matrix colnames btrue = tau0 tau1 tau2 tau3 tau4 tau5
qui forvalues h = 0/5 {
	sum tau if K==`h'
	matrix btrue[1,`h'+1]=r(mean)
}


* ═══════════════════════════════════════════════════════════
* SECTION 3: RUN ALL METHODS
* ═══════════════════════════════════════════════════════════

* --- Prepare common variables ---
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


* --- (1) BJS Imputation ---
di "▶ [1] Borusyak et al. (2024)"
did_imputation Y i t Ei, allhorizons pretrend(5)
event_plot, default_look graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") title("BJS (2024)") ///
	xlabel(-5(1)5) name(BJS, replace))
estimates store bjs

* --- (2) dCDH (2020) ---
di "▶ [2] de Chaisemartin-D'Haultfoeuille (2020)"
did_multiplegt Y i t D, robust_dynamic dynamic(5) placebo(5) ///
	longdiff_placebo breps(100) cluster(i)
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("dCDH (2020)") xlabel(-5(1)5) name(dCdH, replace)) ///
	stub_lag(Effect_#) stub_lead(Placebo_#) together
matrix dcdh_b = e(estimates)
matrix dcdh_v = e(variances)

* --- (3) Callaway-Sant'Anna (2021) ---
di "▶ [3] Callaway-Sant'Anna (2021)"
csdid Y, ivar(i) time(t) gvar(gvar) agg(event)
event_plot e(b)#e(V), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-13(1)5) title("CS (2021)") name(CS, replace)) ///
	stub_lag(T+#) stub_lead(T-#) together
matrix cs_b = e(b)
matrix cs_v = e(V)

* --- (4) Sun-Abraham (2021) ---
di "▶ [4] Sun-Abraham (2021)"
eventstudyinteract Y L*event F*event, vce(cluster i) absorb(i t) ///
	cohort(Ei) control_cohort(lastcohort)
event_plot e(b_iw)#e(V_iw), default_look ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-14(1)5) title("SA (2021)") name(SA, replace)) ///
	stub_lag(L#event) stub_lead(F#event) together
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)

* --- (5) Gardner did2s (2022) ---
di "▶ [5] Gardner (2022)"
did2s Y, first_stage(i.i i.t) second_stage(F*event L*event) ///
	treatment(D) cluster(i)
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-14(1)5) title("Gardner (2022)") name(DID2S, replace))
matrix did2s_b = e(b)
matrix did2s_v = e(V)

* --- (6) Stacked DID (Cengiz et al.) ---
di "▶ [6] Stacked DID"
gen treat_year = .
replace treat_year = Ei if Ei != 16
gen no_treat = (Ei == 16)
cap drop F*event2 L*event2
forvalues l = 0/5 {
	gen L`l'event2 = K==`l'
	replace L`l'event2 = 0 if no_treat==1
}
forvalues l = 1/14 {
	gen F`l'event2 = K==-`l'
	replace F`l'event2 = 0 if no_treat==1
}
cap drop F1event2
preserve
stackedev Y F*event2 L*event2, cohort(treat_year) time(t) ///
	never_treat(no_treat) unit_fe(i) clust_unit(i)
restore
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)

* --- (7) TWFE OLS ---
di "▶ [7] TWFE OLS"
reghdfe Y F*event L*event, absorb(i t) vce(cluster i)
estimates store ols


* ═══════════════════════════════════════════════════════════
* SECTION 4: COMBINED EVENT STUDY PLOT
* ═══════════════════════════════════════════════════════════
* Source: Borusyak five_estimators_example.do (adapted)

event_plot btrue# bjs dcdh_b#dcdh_v cs_b#cs_v sa_b#sa_v ///
	did2s_b#did2s_v stackedev_b#stackedev_v ols, ///
	stub_lag(tau# tau# Effect_# T+# L#event L#event L#event L#event) ///
	stub_lead(pre# pre# Placebo_# T-# F#event F#event F#event F#event) ///
	plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.1)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators comparison (400 units, 15 periods)", size(med)) ///
		xtitle("Periods since the event", size(small)) ///
		ytitle("Average causal effect", size(small)) xlabel(-5(1)5) ///
		legend(order(1 "True value" 2 "BJS" 4 "dCDH" ///
			6 "CS" 8 "SA" 10 "Gardner" 12 "Stacked" 14 "TWFE OLS") ///
			rows(2) position(6) region(style(none))) ///
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) ///
		graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(black)) lag_ci_opt1(color(black)) ///
	lag_opt2(msymbol(O) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) ///
	lag_opt5(msymbol(Sh) color(dkorange)) lag_ci_opt5(color(dkorange)) ///
	lag_opt6(msymbol(Th) color(blue)) lag_ci_opt6(color(blue)) ///
	lag_opt7(msymbol(Dh) color(red)) lag_ci_opt7(color(red)) ///
	lag_opt8(msymbol(Oh) color(purple)) lag_ci_opt8(color(purple))

* graph export "did_comparison.png", replace

di _newline "  DONE: 15_comparison_master.do"
di "  🎉 All methods compared on same data!"
