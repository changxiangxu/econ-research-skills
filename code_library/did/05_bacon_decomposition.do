/*==============================================================================
  File:     05_bacon_decomposition.do
  Method:   Goodman-Bacon (2021) — TWFE Decomposition Diagnostic
  Author:   econ-research-skills
  
  Reference:
    Goodman-Bacon, A. (2021). "Difference-in-Differences with Variation 
    in Treatment Timing." Journal of Econometrics, 225(2), 254-277.
  
  Required Packages:
    - bacondecomp (install: ssc install bacondecomp)
    - reghdfe, ftools
  
  Why Bacon Decomposition?
    ✅ DIAGNOSTIC tool — run BEFORE choosing your DID estimator
    ✅ Shows exactly what TWFE is doing: decomposes β into 2×2 DID pieces
    ✅ Reveals "bad comparisons" (treated vs. already-treated)
    ✅ If all comparisons are consistent → TWFE is probably fine
    ✅ If signs differ → TWFE is biased, use robust estimators
  
  Key Insight:
    TWFE β = Σ (weight_k × β_k) where each β_k is a 2×2 DID
    Some 2×2 DIDs use ALREADY-TREATED as controls → "bad" comparisons
    Bacon decomposition shows you exactly which comparisons are driving β
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (heterogeneous effects to show bias)
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

* Heterogeneous effects (same as 02)
gen true_att = 0
replace true_att = 1.0 if cohort == 10 & treat == 1
replace true_att = 2.0 if cohort == 15 & treat == 1
replace true_att = 3.0 if cohort == 20 & treat == 1

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + true_att + epsilon

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: BACON DECOMPOSITION
* ═══════════════════════════════════════════════════════════
* bacondecomp syntax:
*   bacondecomp Y D [, options]
*
* Where:
*   Y = outcome variable
*   D = binary treatment indicator (0/1)
*
* Key options:
*   ddetail = show detailed 2×2 DID comparisons
*   stub()  = save decomposition results to variables

di _newline "═══ Goodman-Bacon Decomposition (2021) ═══"
bacondecomp y treat, ddetail

* ═══════════════════════════════════════════════════════════
* SECTION 3: INTERPRETING THE OUTPUT
* ═══════════════════════════════════════════════════════════
*
* The output table shows three types of 2×2 DID comparisons:
*
* 1. "Earlier Treatment vs. Later Control" (GOOD ✅)
*    → Early-treated units vs. not-yet-treated units
*    → This is a valid comparison
*    → Weight: typically large
*
* 2. "Later Treatment vs. Earlier Control" (BAD ❌)
*    → Late-treated units vs. already-treated units
*    → Already-treated units' outcomes have CHANGED due to treatment
*    → Using them as "controls" is invalid
*    → This is the source of TWFE bias!
*
* 3. "Treatment vs. Never Treated" (GOOD ✅)
*    → Treated vs. pure controls
*    → Always a valid comparison
*
* DECISION RULE:
*   - If all sub-estimates have consistent signs → TWFE probably OK
*   - If "bad" comparisons have opposite signs → TWFE IS BIASED
*   - Weight on "bad" comparisons > 10%? → Switch to robust estimator
*
* 📌 Think of it like a medical X-ray:
*    Bacon decomposition doesn't fix the problem —
*    it shows you WHERE the problem is.


* ═══════════════════════════════════════════════════════════
* SECTION 4: VISUAL DIAGNOSTIC
* ═══════════════════════════════════════════════════════════
* The scatter plot shows each 2×2 DID estimate vs. its weight
* Points to the left or right of the TWFE line indicate bias sources

* bacondecomp automatically produces a graph if supported
* You should see:
*   - X-axis: weight in the TWFE estimate
*   - Y-axis: 2×2 DID estimate
*   - Points clustered around true ATT → TWFE is fine
*   - Points dispersed → TWFE is biased

* graph export "bacon_decomposition.pdf", replace

di _newline "═══════════════════════════════════════════"
di "  BACON DECOMPOSITION DECISION:"
di ""  
di "  If 'bad' comparisons (treated vs already-treated)"
di "  have different signs or large weights → USE:"
di "    02_callaway_santanna.do"
di "    03_sun_abraham.do"
di "    04_imputation_bjs.do"
di ""
di "  If all comparisons consistent → TWFE is probably fine"
di "═══════════════════════════════════════════"

di _newline "  DONE: 05_bacon_decomposition.do"
