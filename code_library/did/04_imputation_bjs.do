/*==============================================================================
  File:     04_imputation_bjs.do
  Method:   Borusyak, Jaravel & Spiess (2024) — Imputation Estimator
  Author:   econ-research-skills
  
  Reference:
    Borusyak, K., Jaravel, X. & Spiess, J. (2024). "Revisiting Event-Study 
    Designs: Robust and Efficient Estimation." Review of Economic Studies.
  
  Required Packages:
    - did_imputation (install: ssc install did_imputation)
    - event_plot     (install: ssc install event_plot)
    - reghdfe, ftools
  
  Why Imputation DID?
    ✅ Conceptually cleanest: "What would treated units look like untreated?"
    ✅ Imputes Y(0) for treated units using untreated observations
    ✅ Efficient: uses all available pre-treatment data
    ✅ Easy to implement: very clean syntax
    ✅ Directly produces event study coefficients
  
  Key Idea:
    Step 1: Estimate unit FE and time FE from untreated observations ONLY
    Step 2: Predict Y(0) for treated observations using these FEs
    Step 3: ATT = observed Y - imputed Y(0)
    This avoids using already-treated units as controls.
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (same DGP — heterogeneous effects)
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
* 📌 did_imputation needs gvar = . for never-treated (not 0)
replace gvar = . if cohort == 0

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: IMPUTATION DID ESTIMATION
* ═══════════════════════════════════════════════════════════
* did_imputation syntax:
*   did_imputation Y unit_id time_id first_treatment_period [, options]
*
* Key arguments:
*   First 4 positional arguments are required:
*     Y = outcome variable
*     i = unit identifier
*     t = time identifier  
*     ei = first treatment period (MISSING for never-treated)
*   
*   horizons(#) = number of post-treatment periods to report
*   pretrends(#) = number of pre-treatment periods to test
*   minn(#) = minimum observations per unit (default: 0)

di _newline "═══ Borusyak, Jaravel & Spiess (2024) ═══"

* Step 2.1: Overall ATT with pre-trend test
did_imputation y id time gvar, horizons(0/10) pretrends(5) minn(0)

* 📌 The pre-treatment coefficients test parallel trends
*    They should be jointly insignificant
* 📌 Post-treatment coefficients = dynamic treatment effects


* ═══════════════════════════════════════════════════════════
* SECTION 3: EVENT STUDY PLOT
* ═══════════════════════════════════════════════════════════

* event_plot creates a clean event study graph from did_imputation output
event_plot, default_look                                               ///
    graph_opt(                                                          ///
        title("Event Study: BJS Imputation (2024)")                    ///
        xtitle("Periods Relative to Treatment")                        ///
        ytitle("ATT Estimate")                                         ///
        yline(0, lcolor(red) lpattern(dash))                           ///
        xlabel(-5(1)10)                                                ///
    )

* graph export "event_study_bjs.pdf", replace


* ═══════════════════════════════════════════════════════════
* SECTION 4: POOLED ATT (single overall estimate)
* ═══════════════════════════════════════════════════════════
* For a single overall ATT number:
did_imputation y id time gvar, allhorizons pretrends(5) minn(0)

di _newline "Overall ATT from imputation:"
di "True ATT = 2.0 (average of heterogeneous effects)"


* ═══════════════════════════════════════════════════════════
* SECTION 5: INTUITION — HOW IMPUTATION WORKS
* ═══════════════════════════════════════════════════════════
*
* Step 1: Take only untreated observations (pre-treatment for treated
*         units + all periods for never-treated units)
* Step 2: Estimate: Y_it = α_i + γ_t + ε_it  (only on untreated obs)
* Step 3: For each treated observation (i,t), predict:
*         Ŷ(0)_it = α̂_i + γ̂_t
* Step 4: Individual treatment effect:
*         τ̂_it = Y_it - Ŷ(0)_it = Y_it - α̂_i - γ̂_t
* Step 5: Average to get ATT, ATT(e), ATT(g), etc.
*
* Why this is better than TWFE:
*   - TWFE implicitly uses ALL observations (including already-treated)
*     to estimate FEs, contaminating the counterfactual
*   - Imputation uses ONLY untreated observations — clean counterfactual
*
* Practical advantage:
*   - Very simple syntax (4 required arguments)
*   - Directly reports pre-trends and dynamic effects
*   - Works well even with few never-treated units

di _newline "  DONE: 04_imputation_bjs.do"
