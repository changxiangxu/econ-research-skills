/*==============================================================================
  File:     02_callaway_santanna.do
  Method:   Callaway & Sant'Anna (2021) — Group-Time ATT
  
  Reference:
    Callaway, B. & Sant'Anna, P.H.C. (2021). "Difference-in-Differences 
    with Multiple Time Periods." Journal of Econometrics.
  
  Required: ssc install csdid, replace
            ssc install drdid, replace
            ssc install event_plot, replace
  
  Code Source: Adapted from wenddymacro/straggered_did_13 Method (3)
               and Borusyak five_estimators_example.do
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
gen t = mod((_n-1),$T )+1
tsset i t

gen Ei = ceil(runiform()*7)+$T -6 if t==1
bys i (t): replace Ei = Ei[1]
gen K = t-Ei
gen D = K>=0 & Ei!=.

gen tau = cond(D==1, (t-Ei), 0)
gen eps = rnormal()
gen Y = i + 3*t + tau*D + eps


* ═══════════════════════════════════════════════════════════
* SECTION 2: CALLAWAY-SANT'ANNA ESTIMATION
* ═══════════════════════════════════════════════════════════
* Source: wenddymacro Method (3), Borusyak five_estimators_example.do
*
* csdid syntax:
*   csdid Y, ivar(unit) time(time) gvar(group) [agg() method() notyet]
*
* Key arguments:
*   ivar():  unit identifier
*   time():  time period
*   gvar():  first treatment period (never-treated: gvar == 0)
*   agg():   aggregation method (event = event study)
*   notyet:  use not-yet-treated as controls (alternative to never-treated)

gen gvar = cond(Ei>15, 0, Ei) // csdid requires gvar=0 for never-treated

* Estimation with event-time aggregation
csdid Y, ivar(i) time(t) gvar(gvar) agg(event)

* Plot
event_plot e(b)#e(V), default_look graph_opt(xtitle("Periods since the event") ///
	ytitle("Average causal effect") xlabel(-13(1)5) ///
	title("Callaway and Sant'Anna (2021)") name(CS, replace)) ///
	stub_lag(T+#) stub_lead(T-#) together

* Store for later comparison
matrix cs_b = e(b)
matrix cs_v = e(V)


* ═══════════════════════════════════════════════════════════
* SECTION 3: AGGREGATION METHODS
* ═══════════════════════════════════════════════════════════
* CS provides multiple aggregation options:

* Simple ATT (weighted average across all groups and periods)
csdid Y, ivar(i) time(t) gvar(gvar)
estat simple

* Group-level ATT (average by cohort)
estat group

* Calendar-time ATT (average by calendar period)
estat calendar

* Event-study ATT (average by relative time)
estat event

* 📌 Key insight: CS first estimates ATT(g,t) for every 
*    group g and time t, then aggregates flexibly.
*    This avoids the contamination problem of TWFE.
