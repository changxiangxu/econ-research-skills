/*==============================================================================
  File:     12_wooldridge_etwfe.do
  Method:   Wooldridge (2021/2025) — Extended TWFE (ETWFE)
  Author:   econ-research-skills
  
  Reference:
    Wooldridge, J.M. (2021). "Two-Way Fixed Effects, the Two-Way 
    Mundlak Regression, and Difference-in-Differences Estimators."
    Working Paper.
  
  Install: ssc install jwdid, replace
          ssc install wooldid, replace (alternative)
  
  Why This Method?
    ✅ "Just add interactions" — enrich TWFE rather than replace it
    ✅ Familiar regression syntax (no new estimator to learn)
    ✅ Adds cohort×time interactions to absorb heterogeneous effects
    ✅ Wooldridge shows: properly saturated TWFE IS consistent
    ✅ Roth et al. (2023) recommend as one of the simplest fixes
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA
* ═══════════════════════════════════════════════════════════

set obs 40
gen id = _n
expand 30
bysort id: gen time = _n

gen cohort = .
replace cohort = 10 if id <= 10
replace cohort = 15 if id > 10 & id <= 20
replace cohort = 20 if id > 20 & id <= 30
replace cohort = 0  if id > 30

gen treat = (cohort > 0 & time >= cohort)
gen true_att = 0
replace true_att = 1.0 if cohort == 10 & treat == 1
replace true_att = 2.0 if cohort == 15 & treat == 1
replace true_att = 3.0 if cohort == 20 & treat == 1

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + true_att + epsilon

gen gvar = cohort
xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: WOOLDRIDGE ETWFE ESTIMATION
* ═══════════════════════════════════════════════════════════
* jwdid syntax:
*   jwdid Y, ivar(unit) tvar(time) gvar(cohort)

di _newline "═══ Wooldridge ETWFE (2021) ═══"

* Method A: Using jwdid package
jwdid y, ivar(id) tvar(time) gvar(gvar)

* Aggregate to get overall ATT
estat simple
estat group
estat event

* Method B: Manual ETWFE (for understanding)
* The key insight: add cohort×post interactions to TWFE
di _newline "─── Manual ETWFE ───"
gen cohort10_post = (cohort == 10) * (time >= 10)
gen cohort15_post = (cohort == 15) * (time >= 15)
gen cohort20_post = (cohort == 20) * (time >= 20)

reghdfe y cohort10_post cohort15_post cohort20_post, ///
    absorb(id time) cluster(id)

di "Cohort 10 ATT: " %6.3f _b[cohort10_post] " (true: 1.0)"
di "Cohort 15 ATT: " %6.3f _b[cohort15_post] " (true: 2.0)"
di "Cohort 20 ATT: " %6.3f _b[cohort20_post] " (true: 3.0)"

* 📌 Wooldridge's insight:
*   Standard TWFE fails because it constrains all cohorts to 
*   have the same treatment effect. Simply add cohort×post 
*   interactions and the bias disappears. That's it.

di _newline "  DONE: 12_wooldridge_etwfe.do"
