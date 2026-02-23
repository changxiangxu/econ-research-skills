/*==============================================================================
  File:     14_continuous_did.do
  Method:   Continuous Treatment DID (Callaway et al. 2024)
  Author:   econ-research-skills
  
  Reference:
    Callaway, B., Goodman-Bacon, A., Sant'Anna, P.H.C. (2024).
    "Difference-in-Differences with a Continuous Treatment." 
    NBER Working Paper w32117.
  
  Note: Full implementation in R (did package v2.3+).
        Stata: manual implementation shown below.
  
  Why This Method?
    ✅ Treatment is continuous (dose), not binary (0/1)
    ✅ Estimates dose-response curve, not just average effect
    ✅ Framework by the same team who created CS (02)
    ✅ Perfect for: tax rates, subsidy amounts, pollution levels
    ✅ 2024-2026 frontier — very few papers use this yet
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA — Continuous treatment (dose)
* ═══════════════════════════════════════════════════════════

set obs 200
gen id = _n
expand 20
bysort id: gen time = _n
xtset id time

* Treatment dose: varies across units (continuous)
* Applied starting at time 10 for treated units
gen dose = 0
replace dose = runiform(0.5, 3.0) if id <= 100 & time >= 10
* Units 101-200: never treated (dose = 0 always)

* True dose-response: Y = 1.5 * dose (linear)
gen unit_fe = id * 0.1
gen time_fe = 0.2 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + 1.5 * dose + epsilon

gen treated = (id <= 100)
gen post = (time >= 10)

label var y    "Outcome"
label var dose "Treatment Dose (continuous)"


* ═══════════════════════════════════════════════════════════
* SECTION 2: NAIVE APPROACH (for comparison)
* ═══════════════════════════════════════════════════════════

di _newline "═══ Naive: Regress Y on continuous dose ═══"
reghdfe y dose, absorb(id time) cluster(id)
di "Naive estimate: " %6.4f _b[dose]
di "True dose-response: 1.5"


* ═══════════════════════════════════════════════════════════
* SECTION 3: MANUAL CONTINUOUS DID
* ═══════════════════════════════════════════════════════════
* Callaway et al. (2024) approach:
* Step 1: Discretize the dose into bins (quantiles)
* Step 2: For each dose bin, estimate ATT(g,t) using CS-style
* Step 3: Trace out the dose-response curve

di _newline "═══ Continuous DID (Callaway et al., 2024) ═══"

* Step 1: Create dose bins among treated units
gen dose_level = dose if treated == 1 & post == 1
xtile dose_bin = dose_level, nquantiles(3)
replace dose_bin = 0 if treated == 0  // controls

* Step 2: Estimate separate effects for each dose bin
* (Binary DID for each dose level vs. controls)
gen low_dose  = (dose_bin == 1 & post == 1)
gen mid_dose  = (dose_bin == 2 & post == 1)
gen high_dose = (dose_bin == 3 & post == 1)

reghdfe y low_dose mid_dose high_dose, absorb(id time) cluster(id)

di _newline "─── Dose-Response Estimates ───"
di "Low dose  (avg ≈ 0.9): β = " %6.3f _b[low_dose]
di "Mid dose  (avg ≈ 1.7): β = " %6.3f _b[mid_dose]
di "High dose (avg ≈ 2.5): β = " %6.3f _b[high_dose]
di ""
di "Expected (linear, slope=1.5):"
di "Low:  1.5 × 0.9 ≈ 1.35"
di "Mid:  1.5 × 1.7 ≈ 2.55"
di "High: 1.5 × 2.5 ≈ 3.75"

* 📌 The dose-response should be monotonically increasing
*   if the true relationship is linear/positive

* 📌 For full implementation: use R package `did` v2.3+
*   library(did)
*   att_gt(..., treat_type = "continuous")

di _newline "  DONE: 14_continuous_did.do"
