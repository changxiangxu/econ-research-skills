/*==============================================================================
  File:     09_did_multiplegt_stat.do
  Method:   de Chaisemartin et al. (2024) — Continuous Treatment + Stayers
  Author:   econ-research-skills
  
  Reference:
    de Chaisemartin, C. & D'Haultfœuille, X. (2024). 
    "Two-Way Fixed Effects and Differences-in-Differences Estimators 
    in Heterogeneous Adoption Designs."
  
  Install: ssc install did_multiplegt_stat, replace
  GitHub:  https://github.com/chaisemartinPackages/did_multiplegt_stat
  
  Why This Method?
    ✅ Continuous treatment intensity (not just 0/1)
    ✅ Uses "stayers" (units whose treatment doesn't change) as controls
    ✅ More flexible than BJS for continuous treatments
    ✅ Perfect for: tax rate levels, subsidy amounts, regulatory intensity
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA — Continuous treatment intensity
* ═══════════════════════════════════════════════════════════

set obs 40
gen id = _n
expand 30
bysort id: gen time = _n
xtset id time

* Continuous treatment: intensity varies across units and time
* Some units are "stayers" (treatment doesn't change)
gen d = 0
replace d = 0.5 + 0.1*rnormal() if id <= 10 & time >= 12  // low dose
replace d = 1.5 + 0.1*rnormal() if id > 10 & id <= 20 & time >= 15  // high dose
* Units 21-40: stayers (d = 0 always)

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + 2.0 * d + epsilon  // True effect = 2 per unit of d

label var y "Outcome"
label var d "Continuous Treatment Intensity"


* ═══════════════════════════════════════════════════════════
* SECTION 2: ESTIMATION
* ═══════════════════════════════════════════════════════════
* did_multiplegt_stat syntax:
*   did_multiplegt_stat Y G T D, or(#) estimator(type) [options]
*
* Key arguments:
*   or(#)        = number of outcome lags
*   estimator()  = waoss (recommended) / ols / etc.
*   placebo      = include placebo tests

di _newline "═══ dCDH Continuous + Stayers (2024) ═══"

did_multiplegt_stat y id time d, or(2) estimator(waoss) placebo

* 📌 Interpretation:
*   The coefficient represents the effect of a one-unit increase
*   in treatment intensity on the outcome.
*   "Stayers" = units whose treatment level doesn't change between
*   consecutive periods — used as the control group.

di _newline "  DONE: 09_did_multiplegt_stat.do"
