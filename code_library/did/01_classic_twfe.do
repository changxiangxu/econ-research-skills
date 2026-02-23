/*==============================================================================
  File:     01_classic_twfe.do
  Method:   Classic Two-Way Fixed Effects (TWFE) DID
  Author:   econ-research-skills
  Purpose:  Tutorial — Classic DID with panel data and TWFE estimation
  
  Reference:
    Angrist & Pischke (2009), "Mostly Harmless Econometrics", Ch.5
    Angrist & Pischke (2014), "Mastering 'Metrics", Ch.5
  
  Required Packages:
    - reghdfe (install: ssc install reghdfe)
    - ftools  (install: ssc install ftools)
    - coefplot (install: ssc install coefplot)
    - estout  (install: ssc install estout)
  
  What This File Does:
    1. Generates simulated panel data with staggered treatment
    2. Runs classic TWFE DID regression
    3. Produces event study plot
    4. Exports regression table
    5. Discusses when TWFE works and when it fails
  
  ⚠️ WARNING: Classic TWFE can be BIASED with staggered treatment and
     heterogeneous effects. See files 02-07 for robust alternatives.
     Always run 05_bacon_decomposition.do first to diagnose!
==============================================================================*/

clear all
set more off
set seed 12345    // 📌 Always set seed for reproducibility!

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA GENERATING PROCESS (DGP)
* ═══════════════════════════════════════════════════════════
* We create a panel dataset that mimics a real empirical setting:
*   - 40 units (e.g., firms/cities) observed over 30 periods
*   - 4 cohorts: treated at t=10, t=15, t=20, and never-treated
*   - True Average Treatment Effect on Treated (ATT) = 2.0
*   - In your own research, REPLACE THIS SECTION with your real data

* Step 1.1: Create panel skeleton
set obs 40
gen id = _n
expand 30
bysort id: gen time = _n

* Step 1.2: Assign treatment cohorts
*   Cohort 1: units 1-10,  treated at t=10
*   Cohort 2: units 11-20, treated at t=15
*   Cohort 3: units 21-30, treated at t=20
*   Cohort 4: units 31-40, never treated (control group)
gen cohort = .
replace cohort = 10 if id <= 10
replace cohort = 15 if id > 10 & id <= 20
replace cohort = 20 if id > 20 & id <= 30
replace cohort = 0  if id > 30         // 0 = never treated

* Step 1.3: Create treatment indicator
*   D_it = 1 if unit i is treated at time t (post-treatment)
gen treat = (cohort > 0 & time >= cohort)

* Step 1.4: Generate outcome variable
*   Y_it = unit_FE + time_FE + ATT*D_it + noise
*   True ATT = 2.0 (this is what we want to recover)
gen unit_fe = id * 0.5                           // unit fixed effect
gen time_fe = 0.3 * time                         // time fixed effect
gen epsilon = rnormal(0, 1)                      // random noise
gen y = unit_fe + time_fe + 2.0 * treat + epsilon
*          ↑         ↑         ↑           ↑
*       unit FE   time FE   TRUE ATT    noise

label var id     "Unit ID"
label var time   "Time Period"
label var cohort "Treatment Cohort (0=never treated)"
label var treat  "Treatment Indicator (1=treated)"
label var y      "Outcome Variable"

* Step 1.5: Declare panel structure
xtset id time

di "✅ Data created: `c(N)' observations, `c(k)' variables"
di "   Panel: 40 units × 30 periods = 1,200 obs"
di "   True ATT = 2.0"


* ═══════════════════════════════════════════════════════════
* SECTION 2: DESCRIPTIVE STATISTICS
* ═══════════════════════════════════════════════════════════

* Step 2.1: Summary statistics by treatment status
di _newline "───── Descriptive Statistics ─────"
tabstat y, by(treat) stat(n mean sd min max) format(%9.3f)

* Step 2.2: Treatment timing distribution
di _newline "───── Treatment Cohort Distribution ─────"
tab cohort, missing


* ═══════════════════════════════════════════════════════════
* SECTION 3: CLASSIC TWFE DID REGRESSION
* ═══════════════════════════════════════════════════════════
* The classic DID specification:
*   Y_it = α_i + γ_t + β * D_it + ε_it
*
* Where:
*   α_i = unit fixed effects (absorb time-invariant differences)
*   γ_t = time fixed effects (absorb common shocks)
*   β   = DID estimate (our coefficient of interest)
*   D_it = treatment indicator (1 if treated at time t)
*
* 📌 Key Assumption: PARALLEL TRENDS
*   Absent treatment, treated and control units would have
*   followed the same trajectory (same trends, not same levels!)

di _newline "═══════════════════════════════════════════"
di "  CLASSIC TWFE DID REGRESSION"
di "═══════════════════════════════════════════"

* Method A: Using reghdfe (recommended — fastest, most flexible)
* reghdfe absorbs multiple high-dimensional fixed effects efficiently
eststo clear

* Column (1): No fixed effects (naive OLS — DO NOT USE in practice)
eststo m1: reg y treat, robust
di "Col(1) Naive OLS: β = " _b[treat]

* Column (2): Unit FE only
eststo m2: reghdfe y treat, absorb(id) cluster(id)
di "Col(2) Unit FE:   β = " _b[treat]

* Column (3): Unit + Time FE (standard TWFE — your baseline)
eststo m3: reghdfe y treat, absorb(id time) cluster(id)
di "Col(3) TWFE:      β = " _b[treat]

* 📌 Compare with true ATT = 2.0
di _newline "True ATT = 2.0"
di "TWFE estimate = " %6.4f _b[treat]
di "Bias = " %6.4f (_b[treat] - 2.0)


* ═══════════════════════════════════════════════════════════
* SECTION 4: EVENT STUDY (LEADS AND LAGS)
* ═══════════════════════════════════════════════════════════
* The event study is THE most important diagnostic for DID.
* It shows:
*   - Pre-treatment coefficients ≈ 0? → Parallel trends supported
*   - Post-treatment coefficients > 0? → Treatment effect
*   - Dynamic effects: does the effect grow/shrink over time?
*
* Event time = t - treatment_onset
*   Negative = before treatment (should be ≈ 0)
*   Zero     = treatment period
*   Positive = after treatment

* Step 4.1: Create event time variable
gen event_time = time - cohort if cohort > 0
replace event_time = -1 if cohort == 0   // never-treated: set to omitted

* Step 4.2: Create lead/lag dummies
* We use 5 leads (pre) and 10 lags (post) as an example
* 📌 The period just before treatment (event_time = -1) is OMITTED
*    as the reference category. This is standard practice.
forvalues k = 5(-1)2 {
    gen lead`k' = (event_time == -`k')
}
forvalues k = 0/10 {
    gen lag`k' = (event_time == `k')
}

* Step 4.3: Run event study regression
reghdfe y lead5 lead4 lead3 lead2 lag0-lag10, absorb(id time) cluster(id)

* Step 4.4: Event study plot
coefplot, keep(lead* lag*) vertical                                    ///
    yline(0, lcolor(red) lpattern(dash))                               ///
    xline(4.5, lcolor(gray) lpattern(dash))                            ///
    ylabel(, labsize(small)) xlabel(, labsize(small))                  ///
    xtitle("Event Time (periods relative to treatment)")               ///
    ytitle("Coefficient Estimate")                                     ///
    title("Event Study: Classic TWFE")                                 ///
    subtitle("Pre-treatment coefficients should be ≈ 0")              ///
    note("Reference period: t-1. Dashed red line = zero."              ///
         "95% CI shown. Clustered at unit level.")                     ///
    ciopts(recast(rcap) lcolor(navy))                                  ///
    msymbol(D) mcolor(navy) msize(small)

* graph export "event_study_twfe.pdf", replace   // uncomment to save


* ═══════════════════════════════════════════════════════════
* SECTION 5: EXPORT REGRESSION TABLE
* ═══════════════════════════════════════════════════════════
* Format: publication-ready LaTeX table

esttab m1 m2 m3 using "tab_twfe_baseline.tex", replace                ///
    title("Baseline DID Regression Results")                           ///
    mtitles("OLS" "Unit FE" "TWFE")                                   ///
    keep(treat) label                                                  ///
    b(%9.4f) se(%9.4f)                                                ///
    stats(N r2 r2_a, labels("Observations" "R²" "Adjusted R²")       ///
        fmt(%9.0gc %9.4f %9.4f))                                      ///
    star(* 0.10 ** 0.05 *** 0.01)                                     ///
    addnotes("Standard errors clustered at unit level in parentheses." ///
             "True ATT = 2.0.")

di _newline "📄 Table exported: tab_twfe_baseline.tex"


* ═══════════════════════════════════════════════════════════
* SECTION 6: ⚠️ WHEN DOES TWFE FAIL?
* ═══════════════════════════════════════════════════════════
* TWFE is unbiased ONLY when:
*   1. Treatment is NOT staggered (simple 2×2 design), OR
*   2. Treatment effects are HOMOGENEOUS across all units and time
*
* TWFE can be BIASED when:
*   1. Treatment is staggered (units treated at different times)
*   2. Treatment effects vary across cohorts or over time
*   → TWFE uses "already-treated" units as controls (bad!)
*   → This creates "negative weights" (Goodman-Bacon, 2021)
*
* WHAT TO DO:
*   → Run 05_bacon_decomposition.do to diagnose
*   → If bias detected, use 02-04 for robust estimators
*   → Always run 07_honestdid.do for sensitivity analysis
*
* KEY REFERENCES:
*   - Goodman-Bacon (2021), "Difference-in-Differences with
*     Variation in Treatment Timing", Journal of Econometrics
*   - de Chaisemartin & D'Haultfœuille (2020), "Two-Way Fixed 
*     Effects Estimators with Heterogeneous Treatment Effects", AER
*   - Roth et al. (2023), "What's Trending in DID?", JoE

di _newline "═══════════════════════════════════════════"
di "  DONE: 01_classic_twfe.do"
di "  Next step: Run 05_bacon_decomposition.do"
di "═══════════════════════════════════════════"
