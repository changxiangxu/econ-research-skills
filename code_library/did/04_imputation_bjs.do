/*==============================================================================
  File:     04_imputation_bjs.do
  Method:   Borusyak, Jaravel & Spiess (2024) — Imputation Estimator
  
  Reference:
    Borusyak, K., Jaravel, X. & Spiess, J. (2024). "Revisiting Event-Study 
    Designs: Robust and Efficient Estimation." Review of Economic Studies.
  
  Required: ssc install did_imputation, replace
            ssc install event_plot, replace
            ssc install reghdfe, replace
            ssc install ftools, replace
  
  Code Source: Borusyak five_estimators_example.do (THE original)
               https://github.com/borusyak/did_imputation
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
* SECTION 2: BJS IMPUTATION ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: Borusyak five_estimators_example.do (verbatim)
*
* did_imputation syntax:
*   did_imputation Y i t Ei, allhorizons pretrend(#)
*
* Key arguments:
*   Y:    outcome variable
*   i:    unit id variable
*   t:    time period variable
*   Ei:   first treatment period (MISSING for never-treated)
*   allhorizons: include all available post-treatment periods
*   pretrend(#): number of pre-treatment coefficients to test

* Estimation
did_imputation Y i t Ei, allhorizons pretrend(5)
// standard errors are clustered at unit level by default

* Plot
event_plot, default_look graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") ///
	title("Borusyak et al. (2024) imputation estimator") ///
	xlabel(-5(1)5) name(BJS, replace))

* Store for later comparison
estimates store bjs


* ═══════════════════════════════════════════════════════════
* SECTION 3: HOW IMPUTATION WORKS
* ═══════════════════════════════════════════════════════════
* 📌 The imputation approach:
*    Step 1: Take only untreated observations (pre-treatment for 
*            treated units + all periods for never-treated)
*    Step 2: Estimate Y_it = α_i + γ_t + ε_it on untreated obs
*    Step 3: Predict Ŷ(0)_it = α̂_i + γ̂_t for treated obs
*    Step 4: Treatment effect τ̂_it = Y_it − Ŷ(0)_it
*    Step 5: Average across desired horizons/groups
*
* 📌 Why better than TWFE:
*    - TWFE uses ALL obs (including already-treated) to estimate FE
*    - Imputation uses ONLY untreated obs → clean counterfactual
*    - Most efficient among heterogeneity-robust estimators
