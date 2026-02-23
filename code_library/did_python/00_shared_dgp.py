"""
DID Code Library — Python Version
00_shared_dgp.py: Shared Data Generating Process (Borusyak verified DGP)

All 15 DID methods use the SAME simulated data for comparability.
Source: Borusyak five_estimators_example.do / wenddymacro staggered_did_13

DGP:
  - 400 units × 15 periods (balanced panel)
  - Staggered treatment rollout: Ei ~ Uniform{10,...,16}
  - Heterogeneous treatment effects: τ_it = t - Ei (when treated)
  - Y_it = α_i + 3t + τ_it * D_it + ε_it
  - TWFE is biased by design → robust methods should recover truth
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

def generate_did_data(I=400, T=15, seed=10):
    """Generate the Borusyak/wenddymacro verified DGP.
    
    Returns:
        pd.DataFrame with columns: i, t, Ei, K, D, tau, Y, gvar
    """
    np.random.seed(seed)
    
    # Panel structure
    df = pd.DataFrame({
        'i': np.repeat(range(1, I+1), T),
        't': np.tile(range(1, T+1), I)
    })
    
    # Treatment rollout: Ei ~ Uniform{10,...,16}
    unit_ei = np.ceil(np.random.uniform(size=I) * 7) + T - 6
    df['Ei'] = df['i'].map(dict(zip(range(1, I+1), unit_ei)))
    
    # Relative time and treatment indicator
    df['K'] = df['t'] - df['Ei']
    df['D'] = ((df['K'] >= 0) & df['Ei'].notna()).astype(int)
    
    # Heterogeneous treatment effects: τ = t - Ei
    df['tau'] = np.where(df['D'] == 1, df['t'] - df['Ei'], 0)
    
    # Outcome: Y = unit_FE + 3*t + τ*D + ε
    df['unit_fe'] = df['i']  # α_i = i
    df['eps'] = np.random.normal(size=len(df))
    df['Y'] = df['unit_fe'] + 3 * df['t'] + df['tau'] * df['D'] + df['eps']
    
    # Group variable (for CS): 0 for never-treated
    df['gvar'] = np.where(df['Ei'] > T, 0, df['Ei']).astype(int)
    
    # Never-treated indicator
    df['never_treated'] = (df['Ei'] > T).astype(int)
    
    return df


def compute_true_effects(df, max_horizon=5):
    """Compute true average treatment effects by relative time."""
    true_att = {}
    for h in range(max_horizon + 1):
        mask = df['K'] == h
        if mask.sum() > 0:
            true_att[h] = df.loc[mask, 'tau'].mean()
    return true_att


def plot_event_study(estimates, ci_lower=None, ci_upper=None, 
                     true_values=None, title="Event Study",
                     save_path=None):
    """Standard event study plot with optional confidence intervals and true values."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    periods = sorted(estimates.keys())
    est = [estimates[p] for p in periods]
    
    ax.scatter(periods, est, color='navy', s=40, zorder=5, label='Estimate')
    
    if ci_lower is not None and ci_upper is not None:
        lo = [ci_lower[p] for p in periods]
        hi = [ci_upper[p] for p in periods]
        ax.vlines(periods, lo, hi, color='navy', alpha=0.5, linewidth=1.5)
    
    if true_values is not None:
        true_periods = sorted(true_values.keys())
        true_vals = [true_values[p] for p in true_periods]
        ax.scatter(true_periods, true_vals, color='red', marker='+', 
                   s=100, zorder=6, label='True value')
    
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.axvline(x=-0.5, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Periods since treatment')
    ax.set_ylabel('Average causal effect')
    ax.set_title(title)
    ax.legend()
    plt.tight_layout()
    
    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"  Saved: {save_path}")
    
    plt.close()
    return fig


# ═══════════════════════════════════════════════════════════
# Quick test
# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    print(f"Panel: {df['i'].nunique()} units × {df['t'].nunique()} periods = {len(df)} obs")
    print(f"Treatment cohorts: {sorted(df['Ei'].unique())}")
    print(f"Treated obs: {df['D'].sum()} ({df['D'].mean():.1%})")
    
    true_att = compute_true_effects(df)
    print(f"\nTrue ATT by relative time:")
    for k, v in true_att.items():
        print(f"  K={k}: τ = {v:.3f}")
