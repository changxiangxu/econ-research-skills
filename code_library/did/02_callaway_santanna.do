/*==============================================================================
  File:     02_callaway_santanna.do
  Method:   Callaway & Sant'Anna (2021) — Group-Time ATT
  Author:   econ-research-skills
  Purpose:  Tutorial — Modern DID for staggered treatment adoption
  
  Reference:
    Callaway, B. & Sant'Anna, P.H.C. (2021). "Difference-in-Differences 
    with Multiple Time Periods." Journal of Econometrics, 225(2), 200-230.
  
  Required Packages:
    - csdid   (install: ssc install csdid)
    - drdid   (install: ssc install drdid)
    - event_plot (install: ssc install event_plot)
  
  Why Callaway-Sant'Anna?
    ✅ Correctly handles staggered treatment (no "bad comparisons")
    ✅ Produces group-time ATTs: ATT(g,t) for each cohort g at time t
    ✅ Flexible aggregation: simple average, dynamic (event study), calendar
    ✅ Uses never-treated or not-yet-treated as clean controls
    ✅ Most widely used modern DID estimator (2000+ citations)
  
  When to Use:
    - Staggered treatment rollout
    - Panel data with unit and time identifiers
    - Binary treatment (once treated, always treated — "absorbing")
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA GENERATING PROCESS
* ═══════════════════════════════════════════════════════════
* Same DGP as 01_classic_twfe.do for comparability
* BUT we add HETEROGENEOUS treatment effects across cohorts
* to show why TWFE fails and CS works

set obs 40
gen id = _n
expand 30
bysort id: gen time = _n

* Treatment cohorts
gen cohort = .
replace cohort = 10 if id <= 10        // early adopters
replace cohort = 15 if id > 10 & id <= 20  // middle adopters
replace cohort = 20 if id > 20 & id <= 30  // late adopters
replace cohort = 0  if id > 30             // never treated

gen treat = (cohort > 0 & time >= cohort)

* 📌 HETEROGENEOUS effects: early cohorts get smaller effects!
*    This is realistic — early adopters may respond differently
*    This is exactly when TWFE breaks down
gen true_att = 0
replace true_att = 1.0 if cohort == 10 & treat == 1   // small effect
replace true_att = 2.0 if cohort == 15 & treat == 1   // medium effect
replace true_att = 3.0 if cohort == 20 & treat == 1   // large effect

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + true_att + epsilon

* 📌 For csdid: need a "group" variable
*    group = first treatment period (0 for never-treated)
gen gvar = cohort

label var id    "Unit ID"
label var time  "Time Period"
label var gvar  "First Treatment Period (0=never treated)"
label var y     "Outcome Variable"

xtset id time

di "✅ Data with heterogeneous effects:"
di "   Cohort 10: ATT = 1.0"
di "   Cohort 15: ATT = 2.0"
di "   Cohort 20: ATT = 3.0"
di "   Overall ATT = 2.0 (simple average)"


* ═══════════════════════════════════════════════════════════
* SECTION 2: WHY TWFE FAILS HERE
* ═══════════════════════════════════════════════════════════
* Let's first run TWFE to see the bias

di _newline "═══ TWFE (biased with heterogeneous effects) ═══"
reghdfe y treat, absorb(id time) cluster(id)
di "TWFE estimate: " %6.4f _b[treat]
di "True overall ATT: 2.0"
di "Bias: " %6.4f (_b[treat] - 2.0)
di "📌 TWFE is biased because it uses already-treated units as controls!"


* ═══════════════════════════════════════════════════════════
* SECTION 3: CALLAWAY & SANT'ANNA ESTIMATION
* ═══════════════════════════════════════════════════════════
* csdid syntax:
*   csdid Y [covariates], ivar(unit_id) time(time_var) gvar(group_var)
*
* Key arguments:
*   ivar()  = unit identifier
*   time()  = time identifier  
*   gvar()  = first treatment period (0 = never treated)
*   method() = estimation method:
*     - drimp (doubly-robust improved, DEFAULT — recommended)
*     - dripw (doubly-robust IPW)
*     - reg   (outcome regression only)
*     - ipw   (inverse probability weighting only)

di _newline "═══ Callaway & Sant'Anna (2021) ═══"

* Step 3.1: Estimate group-time ATTs
*   ATT(g,t) = average treatment effect for cohort g at time t
csdid y, ivar(id) time(time) gvar(gvar) method(drimp)

* 📌 The output shows ALL group-time ATTs
*    Each row is ATT(g,t) for a specific cohort g at time t
*    This is the most granular level of estimation


* ═══════════════════════════════════════════════════════════
* SECTION 4: AGGREGATION
* ═══════════════════════════════════════════════════════════
* Group-time ATTs are too many to report. We aggregate them.
* csdid_estat provides several aggregation options:

* Step 4.1: Simple aggregation (overall ATT)
*   Weighted average of all ATT(g,t)
di _newline "─── Simple Aggregation: Overall ATT ───"
estat simple
*   This should be close to 2.0 (average of 1.0, 2.0, 3.0)

* Step 4.2: Group aggregation (ATT by cohort)
*   Average ATT(g,t) within each cohort g
di _newline "─── Group Aggregation: ATT by Cohort ───"
estat group
*   Should show: cohort 10 ≈ 1.0, cohort 15 ≈ 2.0, cohort 20 ≈ 3.0

* Step 4.3: Calendar-time aggregation
*   Average ATT(g,t) within each calendar time t
di _newline "─── Calendar Time Aggregation ───"
estat calendar

* Step 4.4: Event-time aggregation (MOST IMPORTANT for event study)
*   Average ATT(g,t) by event time e = t - g
*   This is the dynamic event study plot
di _newline "─── Event Study (Dynamic Effects) ───"
estat event


* ═══════════════════════════════════════════════════════════
* SECTION 5: EVENT STUDY PLOT
* ═══════════════════════════════════════════════════════════
* The event study from CS is "clean" — no contamination from
* bad comparisons that plague TWFE event studies

csdid_plot, title("Event Study: Callaway & Sant'Anna (2021)")          ///
    xtitle("Event Time (periods relative to treatment)")               ///
    ytitle("ATT Estimate")                                             ///
    style(rcap)

* Alternative: using event_plot for nicer formatting
* event_plot, default_look                                             ///
*     graph_opt(title("CS Event Study") xtitle("Event Time")           ///
*     ytitle("ATT"))

* graph export "event_study_cs.pdf", replace


* ═══════════════════════════════════════════════════════════
* SECTION 6: COMPARISON: TWFE vs CS
* ═══════════════════════════════════════════════════════════

di _newline "═══════════════════════════════════════════"
di "  COMPARISON: TWFE vs Callaway-Sant'Anna"
di "═══════════════════════════════════════════"
di "  True ATT (overall): 2.0"
di "  True ATT (cohort 10): 1.0"
di "  True ATT (cohort 15): 2.0"
di "  True ATT (cohort 20): 3.0"
di ""
di "  TWFE estimate: biased (uses already-treated as controls)"
di "  CS estimate: correctly identifies heterogeneous effects"
di "═══════════════════════════════════════════"

di _newline "  DONE: 02_callaway_santanna.do"
di "  Next: Try 03_sun_abraham.do or 04_imputation_bjs.do"
