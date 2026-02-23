/*==============================================================================
  File:     11_stacked_did.do
  Method:   Stacked DID (Cengiz et al. 2019; Wing et al. 2024)
  Author:   econ-research-skills
  
  Reference:
    Cengiz, D., Dube, A., Lindner, A., Zipperer, B. (2019). 
    "The Effect of Minimum Wages on Low-Wage Jobs." QJE.
    
    Wing, C., Freedman, S., Hollingsworth, A. (2024). 
    "Stacked Difference-in-Differences." NBER w32054.
  
  No Special Package — uses reghdfe on stacked data
  
  Why This Method?
    ✅ Uses your familiar TWFE command — just restructure data
    ✅ Each cohort gets its own "clean" 2×2 comparison
    ✅ Stack multiple cohort-specific datasets, then run TWFE
    ✅ Removes "bad comparisons" by construction
    ✅ Referee-friendly: easy to explain
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: ORIGINAL DATA
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
tempfile original
save `original'


* ═══════════════════════════════════════════════════════════
* SECTION 2: CREATE STACKED DATASET
* ═══════════════════════════════════════════════════════════
* Key idea: For each treatment cohort g, create a sub-dataset
* containing ONLY:
*   - Units in cohort g (treated)
*   - Never-treated units OR not-yet-treated units (controls)
*   - A symmetric time window around g
* Then stack all sub-datasets and run TWFE with stack FE

di _newline "═══ Building Stacked Dataset ═══"

* Sub-dataset for cohort g=10 (window: t=5 to t=15)
use `original', clear
keep if cohort == 10 | cohort == 0
keep if time >= 5 & time <= 15
gen stack_id = 1
gen stack_treat = (cohort == 10 & time >= 10)
tempfile stack1
save `stack1'

* Sub-dataset for cohort g=15 (window: t=10 to t=20)
use `original', clear
keep if cohort == 15 | cohort == 0
keep if time >= 10 & time <= 20
gen stack_id = 2
gen stack_treat = (cohort == 15 & time >= 15)
tempfile stack2
save `stack2'

* Sub-dataset for cohort g=20 (window: t=15 to t=25)
use `original', clear
keep if cohort == 20 | cohort == 0
keep if time >= 15 & time <= 25
gen stack_id = 3
gen stack_treat = (cohort == 20 & time >= 20)
tempfile stack3
save `stack3'

* Stack all
use `stack1', clear
append using `stack2'
append using `stack3'

* Create stacked unit and time identifiers
*   Each unit appears multiple times (in different stacks)
*   Need stack-specific FE to avoid cross-contamination
egen stack_unit = group(stack_id id)
egen stack_time = group(stack_id time)

di "Stacked dataset: `c(N)' observations across 3 stacks"


* ═══════════════════════════════════════════════════════════
* SECTION 3: STACKED TWFE REGRESSION
* ═══════════════════════════════════════════════════════════
* Now run standard TWFE — but with STACK-specific FE!

di _newline "═══ Stacked DID Regression ═══"

reghdfe y stack_treat, absorb(stack_unit stack_time) cluster(id)

di "Stacked DID estimate: " %6.4f _b[stack_treat]
di "True ATT (average): 2.0"

* 📌 Why this works:
*   - Each stack uses ONLY clean controls (never-treated)
*   - No "already-treated" units contaminate the comparison
*   - Stack FE absorb stack-specific level differences
*   - Same intuition as CS/BJS but using TWFE machinery

di _newline "  DONE: 11_stacked_did.do"
