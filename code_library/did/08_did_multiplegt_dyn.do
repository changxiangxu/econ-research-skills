/*==============================================================================
  File:     08_did_multiplegt_dyn.do
  Method:   de Chaisemartin & D'Haultfœuille (2024) — Dynamic, Non-Binary
  Author:   econ-research-skills
  
  Reference:
    de Chaisemartin, C., D'Haultfœuille, X., Pasquier, F., Gonzalez, A.
    (2024). "Difference-in-Differences Estimators of Intertemporal 
    Treatment Effects."
  
  Install: ssc install did_multiplegt_dyn, replace
  GitHub:  https://github.com/Credible-Answers/did_multiplegt_dyn
  
  Why This Method?
    ✅ Treatment can switch ON and OFF multiple times
    ✅ Non-binary treatment (continuous intensity)
    ✅ Intertemporal effects (treatment at t affects Y at t+k)
    ✅ Perfect for Chinese policies: tax rates adjusted repeatedly,
       pilot programs expanded/contracted across waves
  
  When to Use (vs 06_dcdh.do):
    06_dcdh = static version (one-shot treatment)
    08_dyn  = dynamic version (repeated/reversible treatment)
==============================================================================*/

clear all
set more off
set seed 12345

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA — Treatment switches on/off
* ═══════════════════════════════════════════════════════════

set obs 40
gen id = _n
expand 30
bysort id: gen time = _n
xtset id time

* Treatment that switches: on at t=10, off at t=18, back on at t=22
gen treat = 0
replace treat = 1 if id <= 15 & time >= 10 & time < 18
replace treat = 1 if id <= 15 & time >= 22
replace treat = 1 if id > 15 & id <= 25 & time >= 15

gen unit_fe = id * 0.5
gen time_fe = 0.3 * time
gen epsilon = rnormal(0, 1)
gen y = unit_fe + time_fe + 2.0 * treat + epsilon

label var y     "Outcome"
label var treat "Treatment (switches on/off)"


* ═══════════════════════════════════════════════════════════
* SECTION 2: ESTIMATION
* ═══════════════════════════════════════════════════════════
* did_multiplegt_dyn syntax:
*   did_multiplegt_dyn Y G T D, effects(#) placebo(#) [options]
*
* Key arguments:
*   effects(#)  = number of post-treatment periods
*   placebo(#)  = number of pre-treatment placebo tests
*   cluster(var) = clustering variable
*   graph_off   = suppress automatic graph

di _newline "═══ dCDH Dynamic (2024) ═══"

did_multiplegt_dyn y id time treat, effects(8) placebo(3) cluster(id)

* 📌 Output:
*   Effect_0 to Effect_7: dynamic treatment effects
*   Placebo_1 to Placebo_3: pre-treatment tests (should ≈ 0)
*   Automatic event study graph produced


* ═══════════════════════════════════════════════════════════
* SECTION 3: KEY ADVANTAGE — Switching treatment
* ═══════════════════════════════════════════════════════════
* Most DID methods assume "absorbing" treatment (once treated, 
* always treated). This method DOES NOT.
*
* Real-world examples where treatment switches:
*   - Tax rates adjusted up AND down over time
*   - Pilot zone designated then revoked
*   - Subsidy given, then removed, then reinstated
*   - Regulatory policy tightened then relaxed
*
* If your treatment ever switches off → use this method

di _newline "  DONE: 08_did_multiplegt_dyn.do"
