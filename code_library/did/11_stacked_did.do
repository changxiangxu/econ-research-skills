/*==============================================================================
  File:     11_stacked_did.do
  Method:   Stacked DID (Cengiz et al. 2019)
  
  Reference:
    Cengiz, D., Dube, A., Lindner, A., Zipperer, B. (2019). 
    "The Effect of Minimum Wages on Low-Wage Jobs." QJE.

  Required: ssc install stackedev, replace
            ssc install event_plot, replace
            ssc install reghdfe, replace
            ssc install ftools, replace
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (6)
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
* SECTION 2: STACKED DID ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (6)
*
* stackedev syntax:
*   stackedev Y leads lags, cohort() time() never_treat() unit_fe() clust_unit()

* Preparation
gen treat_year = .
replace treat_year = Ei if Ei != 16
gen no_treat = (Ei == 16) // never-treated indicator

* Create event-time indicators
cap drop F*event L*event
sum Ei
forvalues l = 0/5 {
	gen L`l'event = K==`l'
	replace L`l'event = 0 if no_treat==1
}
forvalues l = 1/14 {
	gen F`l'event = K==-`l'
	replace F`l'event = 0 if no_treat==1
}
drop F1event // normalize K=-1 to zero

* Estimation using stackedev
preserve
stackedev Y F*event L*event, cohort(treat_year) time(t) ///
	never_treat(no_treat) unit_fe(i) clust_unit(i) 
// Y: outcome
// F*event L*event: leads and lags
// cohort(): first treatment period (missing for never-treated)
// time(): time variable
// never_treat(): binary = 1 if never treated
// unit_fe(): unit FE variable
// clust_unit(): cluster variable
restore

* Plot
event_plot e(b)#e(V), default_look ///
	graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") xlabel(-14(1)5) ///
	title("Cengiz et al. (2019) Stacked DID") name(CDLZ, replace)) ///
	stub_lag(L#event) stub_lead(F#event) together

* Store for later comparison
matrix stackedev_b = e(b)
matrix stackedev_v = e(V)


* ═══════════════════════════════════════════════════════════
* SECTION 3: KEY INSIGHT
* ═══════════════════════════════════════════════════════════
* 📌 Stacked DID creates separate "sub-experiments" for each cohort:
*    - For each treatment timing g, keep only cohort g + never-treated
*    - Apply a symmetric time window around g
*    - Stack all sub-experiments and run TWFE with stack-specific FE
*
* 📌 Advantage: Uses familiar TWFE regression — just restructure data.
*    Referee-friendly because it's easy to explain.
*
* 📌 stackedev automates the stacking; for manual version see 
*    the stacking code in the wenddymacro repo.
