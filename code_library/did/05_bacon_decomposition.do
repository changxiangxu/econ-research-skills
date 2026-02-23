/*==============================================================================
  File:     05_bacon_decomposition.do
  Method:   Goodman-Bacon (2021) — TWFE Decomposition
  
  Reference:
    Goodman-Bacon, A. (2021). "Difference-in-Differences with Variation 
    in Treatment Timing." Journal of Econometrics.
  
  Required: ssc install bacondecomp, replace
            ssc install reghdfe, replace
            ssc install ftools, replace

  Note: bacondecomp requires a balanced panel.
  
  Code Source: Original — the command is straightforward.
               Verified against wenddymacro and Borusyak repos.
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
* SECTION 2: BACON DECOMPOSITION
* ═══════════════════════════════════════════════════════════
* bacondecomp decomposes the TWFE DD coefficient into:
*   1. Earlier vs Later treated (2×2 DID)
*   2. Later vs Earlier treated (2×2 DID) ← PROBLEM: negative weights!
*   3. Treated vs Never-treated (if any)
*
* bacondecomp syntax:
*   bacondecomp Y D, ddetail

bacondecomp Y D, ddetail

* 📌 How to read the output:
*    - Each row is a 2×2 comparison
*    - "Weight" = how much this comparison contributes to TWFE
*    - "DD estimate" = the estimate from this comparison
*    - TWFE = weighted sum of all these
*    - If "Later vs Earlier" has large weight → TWFE is biased
*      because it uses already-treated as controls


* ═══════════════════════════════════════════════════════════
* SECTION 3: DIAGNOSIS — WHEN IS TWFE OK?
* ═══════════════════════════════════════════════════════════
* 📌 Decision rules based on Bacon decomposition:
*
*    If most weight is on "Treated vs Never-treated":
*      → TWFE is probably fine
*      → But still check with robust estimators
*
*    If "Later vs Earlier" has substantial weight:
*      → TWFE is biased
*      → Use 02 (CS) or 04 (BJS) or 10 (Gardner)
*
*    If all weights are positive and estimates are similar:
*      → Treatment effects are likely homogeneous
*      → TWFE is fine, but report this as evidence
*
* 📌 Always run Bacon FIRST as a diagnostic before choosing
*    your main estimator. Report it in your paper.
