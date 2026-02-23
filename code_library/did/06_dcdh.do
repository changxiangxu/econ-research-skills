/*==============================================================================
  File:     06_dcdh.do
  Method:   de Chaisemartin & D'Haultfœuille (2020) — did_multiplegt
  Author:   econ-research-skills
  
  Reference:
    de Chaisemartin, C. & D'Haultfœuille, X. (2020). "Two-Way Fixed Effects 
    Estimators with Heterogeneous Treatment Effects." American Economic Review.
    
    de Chaisemartin, C. & D'Haultfœuille, X. (2023). "Two-Way Fixed Effects 
    and Differences-in-Differences with Heterogeneous Treatment Effects: 
    A Survey." Econometrics Journal.
  
  Required Packages:
    - did_multiplegt (install: ssc install did_multiplegt)
  
  Why dCDH?
    ✅ Minimal assumptions — does not require "no anticipation"
    ✅ Works with non-binary / non-absorbing treatments (switchers!)
    ✅ First paper to formally show TWFE bias (2020 AER — very influential)
    ✅ Allows for treatment effect heterogeneity across groups and time
  
  When to Use (vs CS or BJS):
    - Treatment can switch on AND off (not absorbing)
    - Continuous treatment intensity (not just 0/1)
    - You want the most conservative assumptions
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

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: dCDH ESTIMATION
* ═══════════════════════════════════════════════════════════
* did_multiplegt syntax:
*   did_multiplegt Y group_var time_var treatment_var [, options]
*
* Key arguments:
*   Y = outcome
*   G = group identifier (e.g., unit id)
*   T = time identifier
*   D = treatment indicator (can be binary or continuous!)
*
* Key options:
*   robust_dynamic = compute dynamic effects (event study)
*   dynamic(#)     = number of post-treatment periods
*   placebo(#)     = number of pre-treatment placebo tests
*   breps(#)       = bootstrap repetitions for SE
*   cluster(var)   = clustering variable

di _newline "═══ de Chaisemartin & D'Haultfœuille (2020) ═══"

* Step 2.1: Basic estimation
did_multiplegt y id time treat,                                        ///
    robust_dynamic                                                      ///
    dynamic(5)                                                          ///
    placebo(3)                                                          ///
    breps(50)                                                           ///
    cluster(id)

* 📌 Output shows:
*   - Effect_0: instantaneous effect (at treatment time)
*   - Effect_1, Effect_2, ...: dynamic effects (1, 2, ... periods after)
*   - Placebo_1, Placebo_2, ...: pre-treatment tests (should be ≈ 0)
*   - Joint nullity of placebos: parallel trends test


* ═══════════════════════════════════════════════════════════
* SECTION 3: EVENT STUDY PLOT
* ═══════════════════════════════════════════════════════════
* did_multiplegt automatically produces an event study graph
* if robust_dynamic is specified

* The graph shows:
*   Left side (Placebo): should be close to 0
*   Right side (Effects): the dynamic treatment effects
*   Vertical line: separates pre and post treatment

* graph export "event_study_dcdh.pdf", replace


* ═══════════════════════════════════════════════════════════
* SECTION 4: WHEN TO PREFER dCDH
* ═══════════════════════════════════════════════════════════
*
* Use dCDH when:
*   1. Treatment is NOT absorbing (units can switch treatment on/off)
*      → CS and BJS assume absorbing treatment
*   2. Treatment is continuous (not just 0/1)
*   3. You want the most conservative/minimal assumptions
*   4. Referee specifically asks for dCDH (it's an AER paper!)
*
* Use CS or BJS instead when:
*   1. Treatment is absorbing (most policy evaluations)
*   2. You want directly interpretable ATT(g,t) (CS)
*   3. You want imputation-based efficiency (BJS)
*   4. Speed matters (dCDH bootstrap can be slow with large datasets)

di _newline "  DONE: 06_dcdh.do"
