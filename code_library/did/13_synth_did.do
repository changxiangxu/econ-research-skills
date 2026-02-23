/*==============================================================================
  File:     13_synth_did.do
  Method:   Synthetic DID (Arkhangelsky et al. 2021; Clarke et al. 2023)
  Author:   econ-research-skills
  
  Reference:
    Arkhangelsky, D., Athey, S., Hirshberg, D.A., Imbens, G.W., 
    Wager, S. (2021). "Synthetic Difference-in-Differences."
    American Economic Review.
    
    Clarke, D., Pailañir, D., Athey, S., Imbens, G.W. (2023).
    "Synthetic Difference-in-Differences Estimation." Stata Journal.
  
  Install: ssc install sdid, replace
  GitHub:  https://github.com/Daniel-Pailanir/sdid
  
  Why This Method?
    ✅ Combines Synthetic Control + DID — best of both worlds
    ✅ Reweights control units AND time periods
    ✅ Works when parallel trends is weak (SCM handles level differences)
    ✅ Perfect for: province-level policies with few treated units
    ✅ Published in AER + Stata Journal implementation
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

* Simple setup: units 1-10 treated at t=15, rest control
gen treat = (id <= 10 & time >= 15)

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + 2.0 * treat + epsilon

xtset id time


* ═══════════════════════════════════════════════════════════
* SECTION 2: SYNTHETIC DID ESTIMATION
* ═══════════════════════════════════════════════════════════
* sdid syntax:
*   sdid Y unit_var time_var treatment_var [, options]
*
* Key options:
*   vce(method)  = bootstrap / jackknife / placebo
*   reps(#)      = bootstrap repetitions
*   seed(#)      = random seed
*   graph         = display weights and fit plot

di _newline "═══ Synthetic DID (Arkhangelsky et al., 2021) ═══"

sdid y id time treat, vce(bootstrap) reps(50) seed(12345) graph

* 📌 SDID produces:
*   - ATT estimate
*   - Unit weights (which control units matter most)
*   - Time weights (which pre-treatment periods matter most)
*   - Graph showing the synthetic vs treated trajectory


* ═══════════════════════════════════════════════════════════
* SECTION 3: COMPARISON — DID vs SCM vs SDID
* ═══════════════════════════════════════════════════════════
*
* | Method | Reweights Units? | Reweights Time? | Parallel Trends? |
* |--------|-----------------|-----------------|-----------------|
* | DID    | No (equal)      | No (equal)      | Required        |
* | SCM    | Yes             | No              | Not required    |
* | SDID   | Yes             | Yes             | Partially       |
*
* When to use SDID over standard DID:
*   1. Few treated units (< 10 provinces)
*   2. Parallel trends is questionable
*   3. Want robustness to both DID and SCM assumptions
*   4. Policy evaluation at aggregate (province/state) level

di _newline "  DONE: 13_synth_did.do"
