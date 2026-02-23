/*==============================================================================
  File:     10_gardner_did2s.do
  Method:   Gardner (2022) — Two-Stage DID
  
  Reference:
    Gardner, J. (2022). "Two-Stage Differences in Differences."
    Working Paper.
  
  Required: ssc install did2s, replace
            ssc install event_plot, replace
            ssc install reghdfe, replace
            ssc install ftools, replace
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (5)
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
* SECTION 2: GARDNER did2s ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (5)
*
* did2s syntax:
*   did2s Y, first_stage(FE_vars) second_stage(treatment_vars) 
*     treatment(D) cluster(var)

* Prepare event-time indicators
sum Ei
forvalues l = 0/5 {
	gen L`l'event = K==`l'
}
forvalues l = 1/14 {
	gen F`l'event = K==-`l'
}
drop F1event // normalize K=-1 to zero

* Estimation (event study)
did2s Y, first_stage(i.i i.t) second_stage(F*event L*event) ///
	treatment(D) cluster(i)
// first_stage(): FE used to estimate counterfactual Y(0)
//   This should be everything BESIDES treatment
// second_stage(): treatment (event-study leads/lags or single dummy)
// treatment(): treatment indicator
// cluster(): cluster SE variable

* Plot
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
	graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	xlabel(-14(1)5) title("Gardner (2022)") name(DID2S, replace))

* Store for later comparison
matrix did2s_b = e(b)
matrix did2s_v = e(V)


* ═══════════════════════════════════════════════════════════
* SECTION 3: SIMPLE ATT (single coefficient)
* ═══════════════════════════════════════════════════════════
* For a simple overall ATT instead of event study:

did2s Y, first_stage(i.i i.t) second_stage(D) treatment(D) cluster(i)
di "Gardner ATT: " %6.4f _b[D]


* ═══════════════════════════════════════════════════════════
* SECTION 4: KEY INSIGHT
* ═══════════════════════════════════════════════════════════
* 📌 Gardner's two-stage approach:
*    Stage 1: Estimate unit + time FE from untreated observations
*    Stage 2: Residualize Y, regress residuals on treatment
*
* 📌 Very similar to BJS (04_imputation_bjs.do) in intuition.
*    Both are "imputation-based." In practice, results are 
*    nearly identical. Gardner's advantage: very fast on large data.
