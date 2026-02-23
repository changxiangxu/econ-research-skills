"""
04_imputation_bjs.py — Borusyak, Jaravel & Spiess (2024) Imputation
Python equivalent of 04_imputation_bjs.do

Reference:
  Borusyak, K., Jaravel, X. & Spiess, J. (2024). "Revisiting Event-Study 
  Designs: Robust and Efficient Estimation." Review of Economic Studies.

Manual implementation of the imputation approach.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


def run_bjs_imputation(df, pre_periods=5, post_periods=5):
    """
    BJS Imputation Estimator:
    
    Step 1: Identify untreated observations
            (pre-treatment for treated + all for never-treated)
    Step 2: Estimate Y = α_i + γ_t + ε on untreated obs ONLY
    Step 3: Predict Ŷ(0) for treated observations  
    Step 4: τ̂_it = Y_it - Ŷ(0)_it
    Step 5: Average by relative time K
    """
    df = df.copy()
    
    # Step 1: Split into untreated and treated observations
    df['is_treated_obs'] = df['D']  # D=1 means currently treated
    untreated = df[df['is_treated_obs'] == 0].copy()
    treated = df[df['is_treated_obs'] == 1].copy()
    
    print(f"  Untreated obs: {len(untreated)} | Treated obs: {len(treated)}")
    
    # Step 2: Estimate unit + time FE on untreated ONLY
    model = smf.ols('Y ~ C(i) + C(t)', data=untreated).fit()
    
    # Step 3: Predict Y(0) for treated observations
    treated['Y0_hat'] = model.predict(treated)
    
    # Step 4: Individual treatment effects
    treated['tau_hat'] = treated['Y'] - treated['Y0_hat']
    
    # Step 5: Average by relative time
    estimates = {}
    ci_lower = {}
    ci_upper = {}
    
    for k in range(-pre_periods, post_periods + 1):
        obs_k = treated[treated['K'] == k] if k >= 0 else untreated[untreated['K'] == k]
        
        if k >= 0:
            # Post-treatment: use imputed effects
            obs_k = treated[treated['K'] == k]
            if len(obs_k) > 0:
                mean_tau = obs_k['tau_hat'].mean()
                se_tau = obs_k['tau_hat'].std() / np.sqrt(len(obs_k))
                estimates[k] = mean_tau
                ci_lower[k] = mean_tau - 1.96 * se_tau
                ci_upper[k] = mean_tau + 1.96 * se_tau
        else:
            # Pre-treatment: test parallel trends
            # Predict Y(0) for pre-treatment and check residuals
            pre_obs = untreated[(untreated['K'] == k) & (untreated['never_treated'] == 0)]
            if len(pre_obs) > 0:
                pre_obs = pre_obs.copy()
                pre_obs['Y0_hat'] = model.predict(pre_obs)
                pre_obs['resid'] = pre_obs['Y'] - pre_obs['Y0_hat']
                mean_r = pre_obs['resid'].mean()
                se_r = pre_obs['resid'].std() / np.sqrt(len(pre_obs))
                estimates[k] = mean_r
                ci_lower[k] = mean_r - 1.96 * se_r
                ci_upper[k] = mean_r + 1.96 * se_r
    
    return estimates, ci_lower, ci_upper


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("BJS Imputation (2024)")
    print("=" * 60)
    
    estimates, ci_lo, ci_hi = run_bjs_imputation(df)
    
    print(f"\nEvent Study (Imputation):")
    for k in sorted(estimates.keys()):
        true_val = true_att.get(k, 0)
        print(f"  K={k:+d}: τ̂ = {estimates[k]:.4f}  (true: {true_val:.4f})")
    
    # Overall ATT
    post_effects = [v for k, v in estimates.items() if k >= 0]
    print(f"\n  Overall ATT = {np.mean(post_effects):.4f}")
    print(f"  True avg ATT = {np.mean(list(true_att.values())):.4f}")
    
    os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
    plot_event_study(estimates, ci_lo, ci_hi, true_values=true_att,
                     title="BJS Imputation (2024)",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '04_bjs.png'))
    
    print(f"\n📌 Imputation uses ONLY untreated obs to estimate FE,")
    print(f"   then predicts counterfactual Y(0) for treated obs.")
