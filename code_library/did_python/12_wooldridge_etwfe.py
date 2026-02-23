"""
12_wooldridge_etwfe.py — Wooldridge (2021) Extended TWFE
Python equivalent of 12_wooldridge_etwfe.do

Reference:
  Wooldridge, J.M. (2021). "Two-Way Fixed Effects, the Two-Way 
  Mundlak Regression, and Difference-in-Differences Estimators."

Key insight: Just add cohort × post interaction terms to TWFE.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


def run_wooldridge_etwfe(df, post_periods=5):
    """
    Wooldridge ETWFE:
    Y = α_i + γ_t + Σ_g Σ_k δ_{g,k} * 1{cohort=g, K=k} + ε
    
    This is just TWFE with cohort×time-since-treatment interactions.
    """
    df = df.copy()
    cohorts = sorted(df.loc[(df['gvar'] > 0) & (df['gvar'] < 16), 'gvar'].unique())
    
    # Create cohort × post interaction dummies
    for g in cohorts:
        for k in range(0, post_periods + 1):
            col = f'g{g}_k{k}'
            df[col] = ((df['gvar'] == g) & (df['K'] == k)).astype(int)
    
    # Regression with all interactions
    interact_cols = [c for c in df.columns if c.startswith('g') and '_k' in c]
    formula = 'Y ~ ' + ' + '.join(interact_cols) + ' + C(i) + C(t)'
    
    model = smf.ols(formula, data=df).fit(
        cov_type='cluster', cov_kwds={'groups': df['i']}
    )
    
    # Extract cohort-specific effects
    cohort_effects = {}
    for g in cohorts:
        for k in range(0, post_periods + 1):
            col = f'g{g}_k{k}'
            if col in model.params:
                cohort_effects[(g, k)] = {
                    'coef': model.params[col],
                    'se': model.bse[col]
                }
    
    # Aggregate to event-study: average across cohorts for each k
    estimates = {}
    ci_lower = {}
    ci_upper = {}
    
    for k in range(0, post_periods + 1):
        effects_k = [cohort_effects[(g, k)]['coef'] for g in cohorts 
                     if (g, k) in cohort_effects]
        if effects_k:
            mean_k = np.mean(effects_k)
            se_k = np.std(effects_k) / np.sqrt(len(effects_k))
            estimates[k] = mean_k
            ci_lower[k] = mean_k - 1.96 * se_k
            ci_upper[k] = mean_k + 1.96 * se_k
    
    # Add pre-treatment zeros
    for k in range(-5, 0):
        estimates[k] = 0.0
        ci_lower[k] = 0.0
        ci_upper[k] = 0.0
    
    return estimates, ci_lower, ci_upper, cohort_effects


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("Wooldridge ETWFE (2021)")
    print("=" * 60)
    
    estimates, ci_lo, ci_hi, cohort_fx = run_wooldridge_etwfe(df)
    
    print(f"\nCohort-specific effects:")
    cohorts = sorted(set(g for g, k in cohort_fx.keys()))
    for g in cohorts:
        effects = [f"K{k}: {cohort_fx[(g,k)]['coef']:.3f}" 
                   for k in range(6) if (g,k) in cohort_fx]
        print(f"  Cohort {g}: {', '.join(effects)}")
    
    print(f"\nAggregated Event Study:")
    for k in sorted(estimates.keys()):
        true_val = true_att.get(k, 0)
        print(f"  K={k:+d}: β = {estimates[k]:.4f}  (true: {true_val:.4f})")
    
    os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
    plot_event_study(estimates, ci_lo, ci_hi, true_values=true_att,
                     title="Wooldridge ETWFE (2021)",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '12_etwfe.png'))
    
    print(f"\n📌 Wooldridge's fix: add cohort×post interactions to TWFE.")
    print(f"   'Don't abandon TWFE — just enrich it.'")
