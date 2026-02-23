/*==============================================================================
  File:     15_comparison_master.do
  Method:   All-in-One Comparison — Run all DID methods on same data
  Author:   econ-research-skills
  
  Purpose:
    Run EVERY DID method on the SAME simulated dataset and compare:
    - Point estimates (should all be close to true ATT)
    - Standard errors
    - Event study plots
    
    Use this for:
    1. Learning: see how different methods compare
    2. Robustness: show your paper's results are method-invariant
    3. Appendix: "Results are robust to alternative DID estimators"
  
  Required Packages: reghdfe, csdid, eventstudyinteract, did_imputation,
    bacondecomp, did_multiplegt, did2s, jwdid, sdid
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: COMMON DATA (same for all methods)
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
gen gvar_miss = cohort
replace gvar_miss = . if cohort == 0
gen never_treat = (cohort == 0)

xtset id time

di "═══════════════════════════════════════════"
di "  DATA: 40 units × 30 periods"
di "  Cohorts: 10, 15, 20 (+ never-treated)"
di "  True ATT: 1.0 / 2.0 / 3.0 (avg = 2.0)"
di "═══════════════════════════════════════════"


* ═══════════════════════════════════════════════════════════
* SECTION 2: RUN ALL METHODS
* ═══════════════════════════════════════════════════════════

* --- Store results ---
matrix RESULTS = J(8, 3, .)
matrix rownames RESULTS = "TWFE" "CS" "SA" "BJS" "Gardner" "ETWFE" "dCDH" "SDID"
matrix colnames RESULTS = "ATT" "SE" "Method_ID"
local row = 0

* --- 1. Classic TWFE ---
local ++row
di _newline "▶ [`row'] Classic TWFE"
qui reghdfe y treat, absorb(id time) cluster(id)
matrix RESULTS[`row', 1] = _b[treat]
matrix RESULTS[`row', 2] = _se[treat]
matrix RESULTS[`row', 3] = 1

* --- 2. Callaway-Sant'Anna ---
local ++row
di "▶ [`row'] Callaway-Sant'Anna (2021)"
qui csdid y, ivar(id) time(time) gvar(gvar) method(drimp)
qui estat simple
matrix temp = r(table)
matrix RESULTS[`row', 1] = temp[1,1]
matrix RESULTS[`row', 2] = temp[2,1]
matrix RESULTS[`row', 3] = 2

* --- 3. Sun-Abraham ---
local ++row
di "▶ [`row'] Sun-Abraham (2021)"
gen rel = time - cohort if cohort > 0
replace rel = -1 if cohort == 0
gen sa_treat = (rel >= 0 & cohort > 0)
qui eventstudyinteract y sa_treat, cohort(gvar) control_cohort(never_treat) ///
    absorb(id time) vce(cluster id)
matrix sa_b = e(b_iw)
matrix sa_V = e(V_iw)
matrix RESULTS[`row', 1] = sa_b[1,1]
matrix RESULTS[`row', 2] = sqrt(sa_V[1,1])
matrix RESULTS[`row', 3] = 3
drop rel sa_treat

* --- 4. BJS Imputation ---
local ++row
di "▶ [`row'] BJS Imputation (2024)"
qui did_imputation y id time gvar_miss, allhorizons pretrends(3) minn(0)
matrix RESULTS[`row', 1] = _b[tau]
matrix RESULTS[`row', 2] = _se[tau]
matrix RESULTS[`row', 3] = 4

* --- 5. Gardner did2s ---
local ++row
di "▶ [`row'] Gardner Two-Stage (2022)"
qui did2s y, first_stage(i.id i.time) second_stage(treat) ///
    treatment(treat) cluster(id)
matrix RESULTS[`row', 1] = _b[treat]
matrix RESULTS[`row', 2] = _se[treat]
matrix RESULTS[`row', 3] = 5

* --- 6. Wooldridge ETWFE ---
local ++row
di "▶ [`row'] Wooldridge ETWFE (2021)"
qui jwdid y, ivar(id) tvar(time) gvar(gvar)
qui estat simple
matrix temp2 = r(table)
matrix RESULTS[`row', 1] = temp2[1,1]
matrix RESULTS[`row', 2] = temp2[2,1]
matrix RESULTS[`row', 3] = 6

* --- 7. dCDH Static ---
local ++row
di "▶ [`row'] dCDH (2020)"
qui did_multiplegt y id time treat, robust_dynamic dynamic(0) breps(20) cluster(id)
matrix RESULTS[`row', 1] = e(effect_0)
matrix RESULTS[`row', 2] = e(se_effect_0)
matrix RESULTS[`row', 3] = 7

* --- 8. Synthetic DID ---
local ++row
di "▶ [`row'] Synthetic DID (2021)"
qui sdid y id time treat, vce(bootstrap) reps(20) seed(12345)
matrix RESULTS[`row', 1] = e(ATT)
matrix RESULTS[`row', 2] = e(se)
matrix RESULTS[`row', 3] = 8


* ═══════════════════════════════════════════════════════════
* SECTION 3: COMPARISON TABLE
* ═══════════════════════════════════════════════════════════

di _newline "═══════════════════════════════════════════════════════"
di "  DID METHOD COMPARISON (True ATT = 2.0)"
di "═══════════════════════════════════════════════════════"
di "  Method              │  ATT     │  SE      │  Bias"
di "  ────────────────────┼──────────┼──────────┼──────────"

local methods `" "TWFE" "CS" "SA" "BJS" "Gardner" "ETWFE" "dCDH" "SDID" "'
forvalues i = 1/8 {
    local m : word `i' of `methods'
    local att = RESULTS[`i', 1]
    local se  = RESULTS[`i', 2]
    local bias = `att' - 2.0
    di "  `m'" _col(24) "│ " %7.4f `att' " │ " %7.4f `se' " │ " %7.4f `bias'
}

di "  ═══════════════════════════════════════════════════════"
di ""
di "  📌 All robust methods should give ATT ≈ 2.0"
di "  📌 TWFE may be biased (uses already-treated as controls)"
di "  📌 For your paper: report 2-3 methods as robustness"

di _newline "  DONE: 15_comparison_master.do"
di "  🎉 DID Code Library v2.0 Complete!"
