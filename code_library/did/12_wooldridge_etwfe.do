/*==============================================================================
  File:     12_wooldridge_etwfe.do
  Method:   Wooldridge (2021) — Extended TWFE (ETWFE)
  
  Reference:
    Wooldridge, J.M. (2021). "Two-Way Fixed Effects, the Two-Way 
    Mundlak Regression, and Difference-in-Differences Estimators."
  
  Required: ssc install jwdid, replace
            ssc install wooldid, replace (alternative)
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (13)
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

gen gvar = cond(Ei>15, 0, Ei) // jwdid needs gvar=0 for never-treated


* ═══════════════════════════════════════════════════════════
* SECTION 2: WOOLDRIDGE ETWFE — jwdid
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (13-1)
*
* jwdid syntax:
*   jwdid Y, ivar(unit) tvar(time) gvar(cohort)

jwdid Y, ivar(i) tvar(t) gvar(gvar)
// ivar(): unit identifier
// tvar(): time identifier
// gvar(): first treatment period (0 for never-treated)

* Post-estimation: aggregate
estat simple   // overall ATT
estat group    // by cohort
estat event    // event study


* ═══════════════════════════════════════════════════════════
* SECTION 3: WOOLDRIDGE ETWFE — wooldid
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (13-2)
*
* wooldid syntax:
*   wooldid Y i t Ei, cluster() makeplots espre() espost()

wooldid Y i t Ei, cluster(i) makeplots espre(4) espost(4)
// makeplots: produce event study plots
// espre(): number of pre-treatment periods
// espost(): number of post-treatment periods


* ═══════════════════════════════════════════════════════════
* SECTION 4: KEY INSIGHT
* ═══════════════════════════════════════════════════════════
* 📌 Wooldridge's insight:
*    Standard TWFE fails because it forces all cohorts to have 
*    the same treatment effect. The fix is simple: add cohort×post 
*    interaction terms to the regression.
*
* 📌 "Just enrich your TWFE with interactions, don't abandon it."
*    This is the simplest conceptual fix — no new estimator needed.
*
* 📌 jwdid and wooldid are two different implementations:
*    - jwdid: by Fernando Rios-Avila, integrates with csdid
*    - wooldid: by Thomas Hegland, more plot options
