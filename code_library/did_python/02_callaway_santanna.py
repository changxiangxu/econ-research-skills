"""
02_callaway_santanna.py — Callaway & Sant'Anna (2021)
Python equivalent of 02_callaway_santanna.do

Uses: differences package (pip install differences)
      or csdid package

Reference:
  Callaway, B. & Sant'Anna, P.H.C. (2021). "Difference-in-Differences 
  with Multiple Time Periods." Journal of Econometrics.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd

try:
    from differences import ATTgt, att_gt
    HAS_DIFFERENCES = True
except ImportError:
    HAS_DIFFERENCES = False

try:
    from csdid import csdid
    HAS_CSDID = True
except ImportError:
    HAS_CSDID = False


def run_cs_manual(df):
    """
    Manual Callaway-Sant'Anna style estimation.
    Computes ATT(g,t) for each group g and time t,
    then aggregates to event-study format.
    
    This is a simplified version — the full CS uses 
    doubly-robust (DR) estimation with propensity scores.
    Here we use simple DiD for each (g,t) pair.
    """
    df = df.copy()
    never_treated = df[df['never_treated'] == 1]
    cohorts = sorted(df.loc[df['gvar'] > 0, 'gvar'].unique())
    
    att_gt_results = {}
    
    for g in cohorts:
        cohort_g = df[df['gvar'] == g]
        for t in sorted(df['t'].unique()):
            if t < 2:
                continue  # need pre-period
            
            # DiD: (Y_g,t - Y_g,t-1) - (Y_never,t - Y_never,t-1)
            y_g_t = cohort_g.loc[cohort_g['t'] == t, 'Y'].mean()
            y_g_t1 = cohort_g.loc[cohort_g['t'] == t-1, 'Y'].mean()
            y_n_t = never_treated.loc[never_treated['t'] == t, 'Y'].mean()
            y_n_t1 = never_treated.loc[never_treated['t'] == t-1, 'Y'].mean()
            
            att = (y_g_t - y_g_t1) - (y_n_t - y_n_t1)
            att_gt_results[(g, t)] = att
    
    # Aggregate to event study: average by relative time e = t - g
    event_study = {}
    for (g, t), att in att_gt_results.items():
        e = int(t - g)
        if e not in event_study:
            event_study[e] = []
        event_study[e].append(att)
    
    estimates = {e: np.mean(vals) for e, vals in event_study.items()}
    
    return estimates


def run_cs_differences(df):
    """Use the `differences` package (if installed)."""
    if not HAS_DIFFERENCES:
        print("  ⚠️ `differences` not installed. pip install differences")
        return None
    
    result = att_gt(
        data=df,
        yname='Y',
        tname='t',
        idname='i',
        gname='gvar',
    )
    return result


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("Callaway-Sant'Anna (2021) — Group-Time ATT")
    print("=" * 60)
    
    # Try `differences` package first
    if HAS_DIFFERENCES:
        print("Using `differences` package...")
        result = run_cs_differences(df)
        print(result.summary())
    else:
        print("Using manual CS implementation...")
        estimates = run_cs_manual(df)
        
        print(f"\nEvent Study (averaged ATT(g,t) by relative time):")
        for e in sorted(estimates.keys()):
            if -6 <= e <= 5:
                true_val = true_att.get(e, 0)
                print(f"  e={e:+d}: ATT = {estimates[e]:.4f}  (true: {true_val:.4f})")
        
        # Filter to reasonable range for plotting
        plot_est = {k: v for k, v in estimates.items() if -6 <= k <= 5}
        
        os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
        plot_event_study(plot_est, true_values=true_att,
                         title="Callaway-Sant'Anna (2021) — Manual CS",
                         save_path=os.path.join(os.path.dirname(__file__), 
                                                'output', '02_cs.png'))
    
    print(f"\n📌 CS first estimates ATT(g,t) for every group×time,")
    print(f"   then aggregates. This avoids TWFE contamination.")
