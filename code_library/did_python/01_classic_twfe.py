"""
01_classic_twfe.py — Classic Two-Way Fixed Effects (TWFE)
Python equivalent of 01_classic_twfe.do

Uses: linearmodels.PanelOLS or statsmodels

📌 TWFE is BIASED with heterogeneous treatment effects.
   This file demonstrates the bias so you can compare with robust methods.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


def run_twfe_static(df):
    """Static TWFE: Y ~ D + unit_FE + time_FE"""
    df = df.copy()
    df['i_cat'] = pd.Categorical(df['i'])
    df['t_cat'] = pd.Categorical(df['t'])
    
    # TWFE with dummies (equivalent to reghdfe Y D, absorb(i t))
    model = smf.ols('Y ~ D + C(i) + C(t)', data=df).fit(
        cov_type='cluster', cov_kwds={'groups': df['i']}
    )
    
    att = model.params['D']
    se = model.bse['D']
    ci_lo = att - 1.96 * se
    ci_hi = att + 1.96 * se
    
    return {'att': att, 'se': se, 'ci': (ci_lo, ci_hi)}


def run_twfe_event_study(df, pre_periods=5, post_periods=5):
    """Dynamic TWFE event study: Y ~ Σ β_k * 1{K=k} + unit_FE + time_FE"""
    df = df.copy()
    
    # Create event-time dummies (drop K=-1 as reference)
    for k in range(-pre_periods, post_periods + 1):
        if k == -1:
            continue  # reference period
        col = f'K_{k}' if k < 0 else f'K{k}'
        df[col] = (df['K'] == k).astype(int)
    
    # Event-time dummy columns (excluding K=-1)
    k_cols = [c for c in df.columns if c.startswith('K_') or c.startswith('K')]
    k_cols = [c for c in k_cols if c not in ['K']]
    k_formula_cols = [c for c in k_cols if c.startswith('K_') or (c.startswith('K') and c != 'K')]
    
    # Build formula
    formula = 'Y ~ ' + ' + '.join(k_formula_cols) + ' + C(i) + C(t)'
    model = smf.ols(formula, data=df).fit(
        cov_type='cluster', cov_kwds={'groups': df['i']}
    )
    
    # Extract coefficients
    estimates = {-1: 0.0}  # reference period
    ci_lower = {-1: 0.0}
    ci_upper = {-1: 0.0}
    
    for k in range(-pre_periods, post_periods + 1):
        if k == -1:
            continue
        col = f'K_{k}' if k < 0 else f'K{k}'
        if col in model.params:
            estimates[k] = model.params[col]
            ci_lower[k] = model.params[col] - 1.96 * model.bse[col]
            ci_upper[k] = model.params[col] + 1.96 * model.bse[col]
    
    return estimates, ci_lower, ci_upper


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    # Static TWFE
    result = run_twfe_static(df)
    print("=" * 60)
    print("TWFE Static ATT")
    print("=" * 60)
    print(f"  ATT = {result['att']:.4f}  (SE = {result['se']:.4f})")
    print(f"  95% CI: [{result['ci'][0]:.4f}, {result['ci'][1]:.4f}]")
    print(f"  True average ATT ≈ {np.mean(list(true_att.values())):.4f}")
    print(f"  📌 TWFE is BIASED due to heterogeneous effects!")
    
    # Event study TWFE
    estimates, ci_lo, ci_hi = run_twfe_event_study(df)
    
    print(f"\nTWFE Event Study Coefficients:")
    for k in sorted(estimates.keys()):
        marker = "⚠️ biased" if k >= 0 else ""
        print(f"  K={k:+d}: β = {estimates[k]:.4f}  {marker}")
    
    # Plot
    plot_event_study(estimates, ci_lo, ci_hi, true_values=true_att,
                     title="TWFE OLS Event Study (BIASED)",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '01_twfe.png'))
