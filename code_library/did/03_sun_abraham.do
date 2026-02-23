/*==============================================================================
  File:     03_sun_abraham.do
  Method:   Sun & Abraham (2021) — Interaction-Weighted Estimator
  Author:   econ-research-skills
  
  Reference:
    Sun, L. & Abraham, S. (2021). "Estimating Dynamic Treatment Effects 
    in Event Studies with Heterogeneous Treatment Effects." 
    Journal of Econometrics, 225(2), 175-199.
  
  Required Packages:
    - eventstudyinteract (install: ssc install eventstudyinteract)
    - avar               (install: ssc install avar)
    - reghdfe, ftools
  
  Why Sun-Abraham?
    ✅ Produces clean event study coefficients (no contamination)  
    ✅ Interaction-weighted: reweights cohort-specific estimates
    ✅ Natural companion to TWFE event studies
    ✅ Easy syntax — similar to standard event study specification
  
  Key Idea:
    Standard event study with lead/lag dummies suffers from the same
    contamination as TWFE. Sun-Abraham fixes this by estimating
    cohort-specific effects and then averaging with proper weights.
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (same DGP as 02 — heterogeneous effects)
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

* Heterogeneous effects
gen true_att = 0
replace true_att = 1.0 if cohort == 10 & treat == 1
replace true_att = 2.0 if cohort == 15 & treat == 1
replace true_att = 3.0 if cohort == 20 & treat == 1

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + true_att + epsilon

gen gvar = cohort
xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: CREATE RELATIVE TIME INDICATORS
* ═══════════════════════════════════════════════════════════
* Sun-Abraham needs dummy variables for each relative time period
* relative_time = t - g (where g = first treatment period)

gen rel_time = time - cohort if cohort > 0
replace rel_time = -1 if cohort == 0   // never-treated: reference period

* Create dummies for event time -5 to +10
* 📌 Omit rel_time = -1 (the reference period, standard practice)
forvalues k = 5(-1)2 {
    gen g_m`k' = (rel_time == -`k')    // g_m5 = "5 periods before"
}
forvalues k = 0/10 {
    gen g_p`k' = (rel_time == `k')     // g_p0 = "treatment period"
}

* Endpoint binning: lump very early/late periods together
* This prevents thin cells from driving results
gen g_m6_plus = (rel_time <= -6 & cohort > 0)  // 6+ periods before
gen g_p11_plus = (rel_time >= 11 & cohort > 0) // 11+ periods after


* ═══════════════════════════════════════════════════════════
* SECTION 3: SUN-ABRAHAM ESTIMATION
* ═══════════════════════════════════════════════════════════
* eventstudyinteract syntax:
*   eventstudyinteract Y [lead/lag dummies], 
*     cohort(group_var) control_cohort(never_treated_indicator)
*     absorb(unit_fe time_fe) [cluster options]
*
* Key arguments:
*   cohort() = first treatment period variable
*   control_cohort() = indicator for the control group (never-treated)

di _newline "═══ Sun & Abraham (2021) ═══"

* Create never-treated indicator
gen never_treat = (cohort == 0)

* Run Sun-Abraham
eventstudyinteract y g_m6_plus g_m5 g_m4 g_m3 g_m2                   ///
    g_p0 g_p1 g_p2 g_p3 g_p4 g_p5 g_p6 g_p7 g_p8 g_p9 g_p10        ///
    g_p11_plus,                                                        ///
    cohort(gvar) control_cohort(never_treat)                           ///
    absorb(id time) vce(cluster id)

* 📌 The coefficients are "clean" — properly weighted averages
*    of cohort-specific effects, unlike naive TWFE event study


* ═══════════════════════════════════════════════════════════
* SECTION 4: EVENT STUDY PLOT
* ═══════════════════════════════════════════════════════════

* Store results for plotting
matrix sa_b = e(b_iw)
matrix sa_V = e(V_iw)

* Plot using event_plot (if available) or coefplot
event_plot sa_b#sa_V,                                                  ///
    stub_lag(g_p#) stub_lead(g_m#)                                     ///
    together                                                           ///
    graph_opt(                                                          ///
        title("Event Study: Sun & Abraham (2021)")                     ///
        xtitle("Periods Relative to Treatment")                        ///
        ytitle("Coefficient")                                          ///
        xlabel(-5(1)10)                                                ///
        yline(0, lcolor(red) lpattern(dash))                           ///
    )                                                                   ///
    lag_opt(msymbol(D) mcolor(navy))                                   ///
    lead_opt(msymbol(D) mcolor(navy))

* graph export "event_study_sa.pdf", replace

di _newline "  DONE: 03_sun_abraham.do"
