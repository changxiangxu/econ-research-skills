/*==============================================================================
  DID Code Library v2.1 — Based on Verified Original Author Code
  
  File:     01_classic_twfe.do
  Method:   Two-Way Fixed Effects (TWFE) OLS
  
  NOTE ON CODE PROVENANCE:
    The DGP (data generating process) and core estimation commands in this 
    library are adapted from TWO verified, peer-reviewed sources:
    
    1. Borusyak, K. (2021). "five_estimators_example.do"
       GitHub: https://github.com/borusyak/did_imputation
    
    2. 许文立 (wenddymacro). "staggered_did_13"
       GitHub: https://github.com/wenddymacro/straggered_did_13
    
    We use their shared DGP (400 units × 15 periods, staggered treatment 
    Ei ~ Uniform{10,...,16}, heterogeneous τ = t − Ei) to ensure 
    correctness. Tutorial comments and structural formatting are original.
    
  Why This DGP?
    - Used in the definitive comparison paper by Borusyak et al.
    - Adopted by 许文立 for the 13/16-estimator comparison
    - Treatment effects are heterogeneous by design → TWFE is BIASED
    - This lets you see each method's bias (or lack thereof)
==============================================================================*/

clear all
timer clear
set seed 10
global T = 15
global I = 400


* ═══════════════════════════════════════════════════════════
* SECTION 1: DATA (Borusyak/wenddymacro verified DGP)
* ═══════════════════════════════════════════════════════════
* Source: https://github.com/borusyak/did_imputation
*         five_estimators_example.do, lines 14-34

* Generate a complete panel of 400 units observed in 15 periods
set obs `=$I*$T'
gen i = int((_n-1)/$T )+1 			// unit id
gen t = mod((_n-1),$T )+1			// calendar period
tsset i t

* Randomly generate treatment rollout periods uniformly across Ei=10..16
* (periods t>=16 not useful since all units treated by then)
gen Ei = ceil(runiform()*7)+$T -6 if t==1	// first treatment period
bys i (t): replace Ei = Ei[1]

gen K = t-Ei 						// relative time (periods since treatment)
gen D = K>=0 & Ei!=. 				// treatment indicator

* Generate outcome with parallel trends and HETEROGENEOUS treatment effects
gen tau = cond(D==1, (t-Ei), 0) 	// true TE: varies with time since treatment
gen eps = rnormal()					// error term
gen Y = i + 3*t + tau*D + eps 		// outcome (unit FE + time trend + TE + noise)


* ═══════════════════════════════════════════════════════════
* SECTION 2: TWFE OLS ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro, Method (7)

* Prepare event-time indicators
sum Ei
gen lastcohort = Ei==r(max)

forvalues l = 0/5 {
	gen L`l'event = K==`l'
}
forvalues l = 1/14 {
	gen F`l'event = K==-`l'
}
drop F1event // normalize K=-1 to zero

* TWFE OLS regression
reghdfe Y F*event L*event, absorb(i t) vce(cluster i)

* Plot
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
	graph_opt(xtitle("Periods since the event") ytitle("OLS coefficients") ///
	xlabel(-14(1)5) title("TWFE OLS") name(OLS, replace))

estimates store ols

* ═══════════════════════════════════════════════════════════
* SECTION 3: WHY TWFE IS BIASED HERE
* ═══════════════════════════════════════════════════════════
* 📌 The true treatment effect τ = t - Ei, which means:
*    - Early-treated units (Ei=10) at t=15: τ = 5
*    - Late-treated units (Ei=15) at t=15:  τ = 0
*    Treatment effects are heterogeneous across cohorts and time.
*
* 📌 TWFE is biased because it uses already-treated units as 
*    implicit controls, producing "negative weights" on some 
*    2×2 comparisons (see 05_bacon_decomposition.do).
*
* 📌 Run 15_comparison_master.do to see how robust estimators 
*    (02-07) recover the correct treatment effects.
