/*==============================================================================
  File:     06_dcdh.do
  Method:   de Chaisemartin & D'Haultfœuille (2020) — Static
  
  Reference:
    de Chaisemartin, C. & D'Haultfœuille, X. (2020). "Two-Way Fixed 
    Effects Estimators with Heterogeneous Treatment Effects."
    American Economic Review.
  
  Required: ssc install did_multiplegt, replace
            ssc install event_plot, replace
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (2)
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
* SECTION 2: dCDH ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (2), Borusyak five_estimators_example.do
*
* did_multiplegt syntax:
*   did_multiplegt Y i t D, robust_dynamic dynamic(#) placebo(#)
*     longdiff_placebo breps(#) cluster(var)

did_multiplegt Y i t D, robust_dynamic dynamic(5) placebo(5) ///
	longdiff_placebo breps(100) cluster(i)
// Y:    outcome variable
// i:    unit id variable
// t:    time period variable
// D:    treatment indicator
//
// robust_dynamic: uses dCdH (2021) estimator for intertemporal effects
// dynamic(5): estimate 5 post-treatment periods
// placebo(5): estimate 5 pre-treatment periods
// longdiff_placebo: use long differences for placebos (comparable to dynamic)
// breps(100): bootstrap iterations for SE
// cluster(i): block bootstrap at unit level
//
// NOTE from wenddymacro: "by default placebos are first-difference estimators,
// while dynamic effects are long-difference estimators, so they are not 
// comparable." Always use longdiff_placebo to make them comparable.

* Plot
event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") ///
	xlabel(-5(1)5) name(dCdH, replace)) ///
	stub_lag(Effect_#) stub_lead(Placebo_#) together

* Store for later comparison
matrix dcdh_b = e(estimates)
matrix dcdh_v = e(variances)


* ═══════════════════════════════════════════════════════════
* SECTION 3: KEY INSIGHT
* ═══════════════════════════════════════════════════════════
* 📌 dCDH adapts DID for settings where:
*    - Treatment can switch on/off (non-absorbing)
*    - Want to allow heterogeneous effects across groups/time
*    
* 📌 For the dynamic version (switching treatment, non-binary)
*    → use 08_did_multiplegt_dyn.do instead
