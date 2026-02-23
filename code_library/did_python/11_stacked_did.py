"""
11_stacked_did.py — Stacked DID (Cengiz et al. 2019)
Python equivalent of 11_stacked_did.do

Reference:
  Cengiz, D., Dube, A., Lindner, A., Zipperer, B. (2019). QJE.

Manual implementation: build stacked sub-experiments.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


def run_stacked_did(df, window=5):
    """
    Stacked DID:
    1. For each cohort g, create a sub-experiment:
       - Keep cohort g (treated) + never-treated (control)
       - Window: [g - window, g + window]
    2. Stack all sub-experiments
    3. Run TWFE with stack-specific unit and time FE
    """
    df = df.copy()
    cohorts = sorted(df.loc[(df['gvar'] > 0) & (df['gvar'] < 16), 'gvar'].unique())
    never_treated = df[df['gvar'] == 0].copy()
    
    stacked_dfs = []
    
    for g in cohorts:
        # Sub-experiment for cohort g
        cohort_g = df[df['gvar'] == g].copy()
        
        # Time window
        t_min = max(1, g - window)
        t_max = min(15, g + window)
        
        # Filter to window
        sub_treated = cohort_g[(cohort_g['t'] >= t_min) & (cohort_g['t'] <= t_max)].copy()
        sub_control = never_treated[(never_treated['t'] >= t_min) & (never_treated['t'] <= t_max)].copy()
        
        # Add stack identifier
        sub_treated['stack'] = g
        sub_control['stack'] = g
        sub_treated['treated_in_stack'] = 1
        sub_control['treated_in_stack'] = 0
        
        # Stack-specific IDs (to avoid confounding across stacks)
        sub_treated['stack_i'] = sub_treated['i'].astype(str) + '_' + str(g)
        sub_control['stack_i'] = sub_control['i'].astype(str) + '_' + str(g)
        
        # Relative time within stack
        sub_treated['rel_time'] = sub_treated['t'] - g
        sub_control['rel_time'] = sub_control['t'] - g
        
        stacked_dfs.append(pd.concat([sub_treated, sub_control]))
    
    stacked = pd.concat(stacked_dfs, ignore_index=True)
    
    # Create event-time dummies (drop K=-1)
    estimates = {}
    ci_lower = {}
    ci_upper = {}
    
    for k in range(-window, window + 1):
        stacked[f'rel_{k}'] = (stacked['rel_time'] == k).astype(int)
    
    # Drop reference period
    stacked.drop(columns=['rel_-1'], inplace=True, errors='ignore')
    
    # Run TWFE on stacked data with stack-specific FE
    rel_cols = [c for c in stacked.columns if c.startswith('rel_')]
    formula = 'Y ~ ' + ' + '.join(rel_cols) + ' + C(stack_i) + C(stack):C(t)'
    
    model = smf.ols(formula, data=stacked).fit(
        cov_type='cluster', cov_kwds={'groups': stacked['stack_i']}
    )
    
    estimates[-1] = 0.0
    ci_lower[-1] = 0.0
    ci_upper[-1] = 0.0
    
    for k in range(-window, window + 1):
        if k == -1:
            continue
        col = f'rel_{k}'
        if col in model.params:
            estimates[k] = model.params[col]
            ci_lower[k] = model.params[col] - 1.96 * model.bse[col]
            ci_upper[k] = model.params[col] + 1.96 * model.bse[col]
    
    return estimates, ci_lower, ci_upper


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("Stacked DID (Cengiz et al. 2019)")
    print("=" * 60)
    
    estimates, ci_lo, ci_hi = run_stacked_did(df)
    
    print(f"\nEvent Study:")
    for k in sorted(estimates.keys()):
        true_val = true_att.get(k, 0)
        print(f"  K={k:+d}: β = {estimates[k]:.4f}  (true: {true_val:.4f})")
    
    os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
    plot_event_study(estimates, ci_lo, ci_hi, true_values=true_att,
                     title="Stacked DID (Cengiz et al. 2019)",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '11_stacked.png'))
    
    print(f"\n📌 Stacking creates clean sub-experiments per cohort,")
    print(f"   avoiding cross-cohort contamination in TWFE.")
