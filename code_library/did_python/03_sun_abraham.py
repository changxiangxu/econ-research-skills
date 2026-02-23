"""
03_sun_abraham.py — Sun & Abraham (2021) Interaction-Weighted Estimator
Python equivalent of 03_sun_abraham.do

Reference:
  Sun, L. & Abraham, S. (2021). "Estimating Dynamic Treatment Effects 
  in Event Studies with Heterogeneous Treatment Effects." JoE.

Manual implementation — no standard Python package exists.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from itertools import product


def run_sun_abraham(df, pre_periods=5, post_periods=5):
    """
    Sun-Abraham interaction-weighted estimator.
    
    Key idea: 
    1. Run TWFE event study WITHIN each cohort (using never/last-treated as control)
    2. Take weighted average across cohorts (weight = share of cohort at each K)
    
    This removes the contamination from other cohorts' treatment effects.
    """
    df = df.copy()
    
    # Identify cohorts and control group
    cohorts = sorted(df.loc[df['gvar'] > 0, 'gvar'].unique())
    max_cohort = max(cohorts)  # latest-treated = control cohort
    
    # For each relative time k, estimate cohort-specific effects
    cohort_estimates = {}
    
    for g in cohorts:
        if g == max_cohort:
            continue  # skip control cohort
        
        # Subset: cohort g + control cohort
        sub = df[(df['gvar'] == g) | (df['gvar'] == max_cohort)].copy()
        sub['treated_g'] = (sub['gvar'] == g).astype(int)
        
        for k in range(-pre_periods, post_periods + 1):
            # Create indicator: 1 if treated unit at relative time k
            sub[f'interact'] = (sub['treated_g'] * (sub['K'] == k)).astype(int)
        
            # Simple DiD for this (g, k) cell
            if k == -1:
                cohort_estimates[(g, k)] = 0.0
                continue
            
            # Need two periods: k and reference (-1)
            t_k = g + k      # calendar time for relative time k
            t_ref = g - 1     # calendar time for reference (K=-1)
            
            if t_k < 1 or t_k > 15 or t_ref < 1:
                continue
            
            sub_2period = sub[sub['t'].isin([t_k, t_ref])]
            if len(sub_2period) < 4:
                continue
            
            # DiD = (Y_g,t_k - Y_g,t_ref) - (Y_ctrl,t_k - Y_ctrl,t_ref)
            y_g_k = sub_2period.loc[(sub_2period['treated_g']==1) & (sub_2period['t']==t_k), 'Y'].mean()
            y_g_ref = sub_2period.loc[(sub_2period['treated_g']==1) & (sub_2period['t']==t_ref), 'Y'].mean()
            y_c_k = sub_2period.loc[(sub_2period['treated_g']==0) & (sub_2period['t']==t_k), 'Y'].mean()
            y_c_ref = sub_2period.loc[(sub_2period['treated_g']==0) & (sub_2period['t']==t_ref), 'Y'].mean()
            
            did = (y_g_k - y_g_ref) - (y_c_k - y_c_ref)
            cohort_estimates[(g, k)] = did
    
    # Aggregate: interaction-weighted average across cohorts for each k
    estimates = {}
    for k in range(-pre_periods, post_periods + 1):
        effects = [cohort_estimates[(g, k)] for g in cohorts 
                   if g != max_cohort and (g, k) in cohort_estimates]
        if effects:
            # Weight by cohort size (equal weights for simplicity)
            estimates[k] = np.mean(effects)
    
    return estimates


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("Sun-Abraham (2021) — Interaction-Weighted Estimator")
    print("=" * 60)
    
    estimates = run_sun_abraham(df)
    
    print(f"\nEvent Study Coefficients:")
    for k in sorted(estimates.keys()):
        true_val = true_att.get(k, 0)
        bias = estimates[k] - true_val
        print(f"  K={k:+d}: β = {estimates[k]:.4f}  (true: {true_val:.4f}, bias: {bias:+.4f})")
    
    os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
    plot_event_study(estimates, true_values=true_att,
                     title="Sun-Abraham (2021) Interaction-Weighted",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '03_sa.png'))
    
    print(f"\n📌 SA re-weights TWFE to remove cross-cohort contamination.")
    print(f"   Each cohort's effect is estimated separately, then averaged.")
