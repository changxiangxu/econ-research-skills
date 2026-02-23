/*==============================================================================
  File:     03_sun_abraham.do
  Method:   Sun & Abraham (2021) — Interaction-Weighted Estimator
  
  Reference:
    Sun, L. & Abraham, S. (2021). "Estimating Dynamic Treatment Effects 
    in Event Studies with Heterogeneous Treatment Effects." 
    Journal of Econometrics.
  
  Required: ssc install eventstudyinteract, replace
            ssc install event_plot, replace
            ssc install avar, replace
            ssc install reghdfe, replace
            ssc install ftools, replace
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (4)
               and Borusyak five_estimators_example.do
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
gen t = mod((_n-1),$T )+1
tsset i t

gen Ei = ceil(runiform()*7)+$T -6 if t==1
bys i (t): replace Ei = Ei[1]
gen K = t-Ei
gen D = K>=0 & Ei!=.

gen tau = cond(D==1, (t-Ei), 0)
gen eps = rnormal()
gen Y = i + 3*t + tau*D + eps


* ═══════════════════════════════════════════════════════════
* SECTION 2: SUN-ABRAHAM ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (4), Borusyak five_estimators_example.do
*
* eventstudyinteract syntax:
*   eventstudyinteract Y lags leads, vce() absorb() cohort() control_cohort()

* Preparation: create event-time indicators
sum Ei
gen lastcohort = Ei==r(max) // dummy for latest-treated cohort

forvalues l = 0/5 {
	gen L`l'event = K==`l'
}
forvalues l = 1/14 {
	gen F`l'event = K==-`l'
}
drop F1event // normalize K=-1 to zero

* Estimation
eventstudyinteract Y L*event F*event, vce(cluster i) absorb(i t) ///
	cohort(Ei) control_cohort(lastcohort)
// Y: outcome variable
// L*event: lags (post-treatment indicators)
// F*event: leads (pre-treatment indicators)
// vce(cluster i): cluster SE at unit level
// absorb(i t): unit and time FE
// cohort(Ei): unit-specific first-treatment period
// control_cohort(lastcohort): indicator for control cohort

* Plot
event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") xlabel(-14(1)5) ///
	title("Sun and Abraham (2021)") name(SA, replace)) ///
	stub_lag(L#event) stub_lead(F#event) together

* Store for later comparison
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)


* ═══════════════════════════════════════════════════════════
* SECTION 3: KEY INSIGHT
* ═══════════════════════════════════════════════════════════
* 📌 Sun-Abraham re-weights the TWFE event study to remove
*    contamination from other cohorts' treatment effects.
*    
*    Standard TWFE event study coefficients are weighted averages
*    of cohort-specific effects, with potentially negative weights.
*    SA's "interaction-weighted" estimator uses only clean weights.
*
* 📌 The key input is control_cohort(): this defines which units
*    are used as the comparison group (latest-treated or never-treated).
