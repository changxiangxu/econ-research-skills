"""
10_gardner_did2s.py — Gardner (2022) Two-Stage DID
Python equivalent of 10_gardner_did2s.do

Reference:
  Gardner, J. (2022). "Two-Stage Differences in Differences."

Manual implementation — conceptually identical to BJS imputation.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects, plot_event_study

import numpy as np
import pandas as pd
import statsmodels.formula.api as smf


def run_gardner_did2s(df, pre_periods=5, post_periods=5):
    """
    Gardner Two-Stage DID:
    
    Stage 1: Estimate Y = α_i + γ_t + ε using UNTREATED obs only
    Stage 2: Compute residuals Ỹ = Y - α̂_i - γ̂_t for ALL obs
             Regress Ỹ on treatment indicators
    
    This is very similar to BJS imputation but framed as residualization.
    """
    df = df.copy()
    
    # Stage 1: Estimate FE on untreated obs
    untreated = df[df['D'] == 0].copy()
    model_s1 = smf.ols('Y ~ C(i) + C(t)', data=untreated).fit()
    
    # Predict Y(0) for ALL observations
    df['Y0_hat'] = model_s1.predict(df)
    df['Y_tilde'] = df['Y'] - df['Y0_hat']  # residualized outcome
    
    # Stage 2: Regress Y_tilde on event-time dummies
    # Overall ATT
    treated_resid = df.loc[df['D'] == 1, 'Y_tilde']
    att_overall = treated_resid.mean()
    se_overall = treated_resid.std() / np.sqrt(len(treated_resid))
    
    # Event study
    estimates = {}
    ci_lower = {}
    ci_upper = {}
    
    for k in range(-pre_periods, post_periods + 1):
        obs_k = df[df['K'] == k]
        if len(obs_k) > 0:
            mean_k = obs_k['Y_tilde'].mean()
            se_k = obs_k['Y_tilde'].std() / np.sqrt(len(obs_k))
            estimates[k] = mean_k
            ci_lower[k] = mean_k - 1.96 * se_k
            ci_upper[k] = mean_k + 1.96 * se_k
    
    return estimates, ci_lower, ci_upper, att_overall, se_overall


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    print("=" * 60)
    print("Gardner (2022) Two-Stage DID")
    print("=" * 60)
    
    estimates, ci_lo, ci_hi, att, se = run_gardner_did2s(df)
    
    print(f"\n  Overall ATT = {att:.4f} (SE = {se:.4f})")
    print(f"  True avg ATT = {np.mean(list(true_att.values())):.4f}")
    
    print(f"\nEvent Study:")
    for k in sorted(estimates.keys()):
        true_val = true_att.get(k, 0)
        print(f"  K={k:+d}: τ̂ = {estimates[k]:.4f}  (true: {true_val:.4f})")
    
    os.makedirs(os.path.join(os.path.dirname(__file__), 'output'), exist_ok=True)
    plot_event_study(estimates, ci_lo, ci_hi, true_values=true_att,
                     title="Gardner (2022) Two-Stage DID",
                     save_path=os.path.join(os.path.dirname(__file__), 
                                            'output', '10_gardner.png'))
    
    print(f"\n📌 Gardner's two-stage: residualize Y using untreated FE,")
    print(f"   then regress residuals on treatment. Same idea as BJS.")
