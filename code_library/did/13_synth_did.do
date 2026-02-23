/*==============================================================================
  File:     13_synth_did.do
  Method:   Synthetic DID (Arkhangelsky et al. 2021)
  
  Reference:
    Arkhangelsky, D., Athey, S., Hirshberg, D.A., Imbens, G.W., 
    Wager, S. (2021). "Synthetic Difference-in-Differences."
    American Economic Review.
  
  Required: ssc install sdid, replace
  GitHub:   https://github.com/Daniel-Pailanir/sdid
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (15)
==============================================================================*/

clear all
timer clear
set seed 10
global T = 15
global I = 400

* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (same verified DGP)
* ═══════════════════════════════════════════════════════════

set obs `=$I*$T'
gen i = int((_n-1)/$T )+1
gen t = mod((_n-1)/$T )+1
tsset i t

gen Ei = ceil(runiform()*7)+$T -6 if t==1
bys i (t): replace Ei = Ei[1]
gen K = t-Ei
gen D = K>=0 & Ei!=.

gen tau = cond(D==1, (t-Ei), 0)
gen eps = rnormal()
gen Y = i + 3*t + tau*D + eps


* ═══════════════════════════════════════════════════════════
* SECTION 2: SYNTHETIC DID ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (15)
*
* sdid syntax:
*   sdid Y groupvar timevar treatment, vce(vcetype) [options]

sdid Y i t D, vce(bootstrap) seed(1000) graph
// Y: outcome
// i: unit (group) variable
// t: time variable
// D: treatment indicator
// vce(bootstrap): bootstrap SE
// seed(): random seed for bootstrap
// graph: display diagnostic plot


* ═══════════════════════════════════════════════════════════
* SECTION 3: COMPARISON TABLE
* ═══════════════════════════════════════════════════════════
* 📌 SDID combines DID and Synthetic Control:
*
* | Method | Reweights Units? | Reweights Time? | Parallel Trends? |
* |--------|------------------|-----------------|------------------|
* | DID    | No (equal)       | No (equal)      | Required         |
* | SCM    | Yes              | No              | Not required     |
* | SDID   | Yes              | Yes             | Partially        |
*
* 📌 Use SDID when:
*    1. Few treated units (< 10 provinces)
*    2. Parallel trends is questionable
*    3. Want robustness to both DID and SCM assumptions
*    4. Policy evaluation at aggregate level
*
* 📌 Published in AER, Stata Journal implementation by Clarke et al.
