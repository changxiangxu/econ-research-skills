/*==============================================================================
  File:     10_gardner_did2s.do
  Method:   Gardner (2022) — Two-Stage DID (Imputation-Based)
  Author:   econ-research-skills
  
  Reference:
    Gardner, J. (2022). "Two-Stage Differences in Differences."
    Working Paper.
  
  Install: ssc install did2s, replace
  GitHub:  https://github.com/kylebutts/did2s_stata
  
  Why This Method?
    ✅ Conceptually simplest imputation method
    ✅ Two clear steps: (1) estimate FE from untreated, (2) get ATT
    ✅ Very fast — works well with large datasets
    ✅ Produces clean event study
    ✅ Close cousin of BJS (04) but different implementation
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
replace gvar = . if cohort == 0  // never-treated = missing

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: GARDNER TWO-STAGE ESTIMATION
* ═══════════════════════════════════════════════════════════
* did2s syntax:
*   did2s Y, first_stage(FE_vars) second_stage(treatment_vars)
*     treatment(D) cluster(var)

di _newline "═══ Gardner Two-Stage DID (2022) ═══"

* Method A: Using did2s package
did2s y, first_stage(i.id i.time) second_stage(treat) ///
    treatment(treat) cluster(id)

* Method B: Manual two-stage (for understanding)
di _newline "─── Manual Two-Stage ───"
* Step 1: Estimate FE from untreated observations only
reghdfe y if treat == 0, absorb(id time) resid(y_resid)
* Step 2: The residuals for treated obs = treatment effect
sum y_resid if treat == 1
di "Manual ATT estimate: " r(mean)


* ═══════════════════════════════════════════════════════════
* SECTION 3: EVENT STUDY
* ═══════════════════════════════════════════════════════════

* Create relative time indicators
gen rel_time = time - cohort if cohort > 0
replace rel_time = -1 if cohort == 0

forvalues k = 5(-1)2 {
    gen g_m`k' = (rel_time == -`k')
}
forvalues k = 0/10 {
    gen g_p`k' = (rel_time == `k')
}

did2s y, first_stage(i.id i.time) ///
    second_stage(g_m5 g_m4 g_m3 g_m2 g_p0-g_p10) ///
    treatment(treat) cluster(id)

* 📌 Gardner vs BJS (04):
*   - Both are imputation-based
*   - Gardner: first residualize, then estimate
*   - BJS: directly impute counterfactual
*   - In practice: very similar results

di _newline "  DONE: 10_gardner_did2s.do"
