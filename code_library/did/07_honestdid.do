/*==============================================================================
  File:     07_honestdid.do
  Method:   Rambachan & Roth (2023) — Sensitivity Analysis for Parallel Trends
  Author:   econ-research-skills
  
  References:
    Roth, J. (2023). "Pre-test with Caution: Event-Study Estimates after 
    Testing for Parallel Trends." AER: Insights.
    
    Rambachan, A. & Roth, J. (2023). "A More Credible Approach to 
    Parallel Trends." Review of Economic Studies.
  
  Required Packages:
    - honestdid (install: ssc install honestdid)
    - reghdfe, ftools, coefplot
  
  Why HonestDiD?
    ✅ Addresses the #1 referee concern: "What if parallel trends is violated?"
    ✅ Provides bounds on ATT under controlled violations of parallel trends
    ✅ Two approaches: smoothness bounds (ΔRM) and relative magnitude (M)
    ✅ Shows how large the violation would need to be to overturn results
    ✅ THE most sophisticated robustness check for any DID paper
  
  Key Insight (Roth, 2023):
    Passing a pre-trends test does NOT mean parallel trends holds!
    Pre-trends tests have low power — you might pass the test even when
    the assumption is violated. HonestDiD provides honest confidence sets
    that account for this.
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
replace true_att = 2.0 if treat == 1    // homogeneous for simplicity

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + true_att + epsilon

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: FIRST — RUN EVENT STUDY (needed as input)
* ═══════════════════════════════════════════════════════════
* HonestDiD builds on top of an event study regression.
* We first estimate a standard event study, then feed it to honestdid.

* Create relative time indicators
gen rel_time = time - cohort if cohort > 0
replace rel_time = -1 if cohort == 0

forvalues k = 5(-1)2 {
    gen lead`k' = (rel_time == -`k')
}
forvalues k = 0/10 {
    gen lag`k' = (rel_time == `k')
}

* Run event study regression
reghdfe y lead5 lead4 lead3 lead2 lag0-lag10, absorb(id time) cluster(id)

* Store the estimation results (honestdid reads from e())


* ═══════════════════════════════════════════════════════════
* SECTION 3: HONESTDID SENSITIVITY ANALYSIS
* ═══════════════════════════════════════════════════════════
* honestdid syntax:
*   honestdid, pre(pre_trend_vars) post(post_treat_vars) [options]
*
* Key arguments:
*   pre()  = list of pre-treatment coefficient names
*   post() = list of post-treatment coefficient names
*   mvec() = vector of M values (magnitude of violation to consider)
*   delta() = type of restriction on violations
*     - delta(rm) = "relative magnitudes" — violation bounded by M × max(pre-trend)
*     - delta(sd) = "smoothness" — violation bounded by M × Δ(pre-trend)

di _newline "═══ Rambachan & Roth (2023) — HonestDiD ═══"

* Step 3.1: Relative Magnitudes approach (most common)
* "The post-treatment violation of parallel trends is at most M times
*  as large as the maximum pre-treatment violation"
honestdid, pre(lead5 lead4 lead3 lead2)                               ///
           post(lag0 lag1 lag2 lag3 lag4 lag5)                          ///
           mvec(0 0.5 1 1.5 2)                                         ///
           delta(rm)

* 📌 Interpretation of output:
*   M = 0: Original confidence set (assumes exact parallel trends)
*   M = 0.5: Allows 50% of max pre-trend as post-trend violation
*   M = 1: Allows 100% of max pre-trend violation
*   M = 2: Allows 200% of max pre-trend violation
*
*   If the confidence set excludes 0 even at M = 1 or M = 2,
*   your results are VERY robust!


* ═══════════════════════════════════════════════════════════
* SECTION 4: SENSITIVITY PLOT
* ═══════════════════════════════════════════════════════════
* The sensitivity plot shows:
*   X-axis: M (degree of parallel trends violation allowed)
*   Y-axis: Confidence set for ATT
*   Key question: At what M does the confidence set include 0?

honestdid, pre(lead5 lead4 lead3 lead2)                               ///
           post(lag0 lag1 lag2 lag3 lag4 lag5)                          ///
           mvec(0(0.25)3)                                               ///
           delta(rm)                                                    ///
           coefplot

* graph export "honestdid_sensitivity.pdf", replace

* 📌 Reporting in your paper:
* "Following Rambachan and Roth (2023), we perform a sensitivity 
*  analysis for violations of the parallel trends assumption. Figure X 
*  shows that our results remain significant even when allowing the 
*  post-treatment violation to be [M] times as large as the maximum 
*  pre-treatment differential trend."


* ═══════════════════════════════════════════════════════════
* SECTION 5: HOW TO REPORT IN YOUR PAPER
* ═══════════════════════════════════════════════════════════
*
* In your robustness section, include:
*
* 1. The sensitivity plot (Figure)
* 2. A statement like:
*    "Our baseline results are robust to allowing post-treatment 
*     violations of parallel trends up to [M] times the magnitude 
*     of the largest pre-treatment differential trend 
*     (Rambachan and Roth, 2023)."
*
* 3. If M_critical (where CI includes 0) is large (> 1), you're solid
*    If M_critical is small (< 0.5), results are fragile — be honest
*
* This is the single most impressive robustness check you can do
* for a DID paper. Referees love it.

di _newline "═══════════════════════════════════════════"
di "  DONE: 07_honestdid.do"
di ""
di "  🎉 You've completed the full DID toolkit!"
di "  Recommended workflow:"
di "    01 → 05 → (02 or 03 or 04) → 07"
di "═══════════════════════════════════════════"
