/*==============================================================================
  Project:  [Your Project Name]
  Author:   [Your Name]
  Date:     [Date Created]
  Purpose:  Master script — one-click replication of all analyses
  
  INSTRUCTIONS:
    1. Open this file in Stata
    2. Modify ONLY the global path on line 20 below
    3. Run this entire file (Ctrl+D or "do" button)
    4. All tables, figures, and logs will be generated automatically
  
  Software Requirements:
    - Stata 17+ (SE or MP recommended)
    - User-written packages: reghdfe, estout, winsor2, coefplot, csdid,
      eventstudyinteract, did_imputation, bacondecomp, ftools
    
  File Structure:
    00_RawData/     — Raw data (READ-ONLY, never modify)
    01_Code/        — All do-files (this master + sub-scripts)
    02_CleanData/   — Cleaned analysis-ready data
    03_Output/      — Auto-generated tables, figures, logs
    04_Paper/       — Manuscript and references
==============================================================================*/

clear all
set more off
set maxvar 32767
set matsize 11000

* ═══════════════════════════════════════════════════════════
* 📌 ONLY PATH TO MODIFY ↓↓↓
* ═══════════════════════════════════════════════════════════
global root "D:/Research/YourProjectName"
* ═══════════════════════════════════════════════════════════

* ─── Derived Paths (DO NOT MODIFY) ───────────────────────
global raw      "$root/00_RawData"
global code     "$root/01_Code"
global clean    "$root/02_CleanData"
global output   "$root/03_Output"
global tables   "$output/Tables"
global figures  "$output/Figures"
global logs     "$output/Logs"

* ─── Create Output Directories ───────────────────────────
cap mkdir "$output"
cap mkdir "$tables"
cap mkdir "$figures"
cap mkdir "$logs"

* ─── Install Required Packages ───────────────────────────
* Uncomment on first run:
/*
ssc install reghdfe, replace
ssc install ftools, replace
ssc install estout, replace
ssc install winsor2, replace
ssc install coefplot, replace
ssc install csdid, replace
ssc install drdid, replace
ssc install eventstudyinteract, replace
ssc install did_imputation, replace
ssc install bacondecomp, replace
ssc install event_plot, replace
ssc install did_multiplegt, replace
ssc install honestdid, replace
ssc install psacalc, replace
*/

* ─── Set Graph Scheme ────────────────────────────────────
set scheme s2color
graph set window fontface "Times New Roman"

* ═══════════════════════════════════════════════════════════
* RUN ANALYSIS PIPELINE
* ═══════════════════════════════════════════════════════════

timer clear
timer on 1

log using "$logs/master_log_`c(current_date)'.txt", replace text

di "═══════════════════════════════════════════════════════"
di "  Project: [Your Project Name]"
di "  Date:    `c(current_date)' `c(current_time)'"
di "  Stata:   `c(stata_version)'"
di "═══════════════════════════════════════════════════════"

* ─── Step 1: Data Cleaning ───────────────────────────────
di _newline "▶ Step 1: Data Cleaning"
do "$code/01_clean.do"

* ─── Step 2: Variable Construction ───────────────────────
di _newline "▶ Step 2: Variable Construction"
do "$code/02_construct.do"

* ─── Step 3: Descriptive Statistics ──────────────────────
di _newline "▶ Step 3: Descriptive Statistics"
do "$code/03_descriptive.do"

* ─── Step 4: Baseline Regression ─────────────────────────
di _newline "▶ Step 4: Baseline Regression"
do "$code/04_baseline.do"

* ─── Step 5: Robustness Checks ──────────────────────────
di _newline "▶ Step 5: Robustness Checks"
do "$code/05_robustness.do"

* ─── Step 6: Heterogeneity Analysis ─────────────────────
di _newline "▶ Step 6: Heterogeneity Analysis"
do "$code/06_heterogeneity.do"

* ─── Step 7: Mechanism Analysis ─────────────────────────
di _newline "▶ Step 7: Mechanism Analysis"
do "$code/07_mechanism.do"

* ─── Step 8: Tables & Figures Export ────────────────────
di _newline "▶ Step 8: Tables & Figures Export"
do "$code/08_tables_figures.do"

* ═══════════════════════════════════════════════════════════

timer off 1
timer list

di _newline "═══════════════════════════════════════════════════════"
di "  ✅ ALL ANALYSES COMPLETE!"
di "  Total time: `r(t1)' seconds"
di "  Tables saved to: $tables"
di "  Figures saved to: $figures"
di "═══════════════════════════════════════════════════════"

log close
