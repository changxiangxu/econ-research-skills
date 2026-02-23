"""
05_bacon_decomposition.py — Goodman-Bacon (2021) TWFE Decomposition
Python equivalent of 05_bacon_decomposition.do

Reference:
  Goodman-Bacon, A. (2021). "Difference-in-Differences with Variation 
  in Treatment Timing." Journal of Econometrics.

Uses: manual implementation (decompose TWFE into 2x2 comparisons)
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from shared_dgp import generate_did_data, compute_true_effects

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def bacon_decomposition(df):
    """
    Decompose the TWFE DD coefficient into weighted 2x2 comparisons.
    
    Types of 2x2 comparisons:
    1. Treated(early) vs Never-treated
    2. Treated(late) vs Never-treated  
    3. Treated(early) vs Treated(late) — BIASED!
    4. Treated(late) vs Treated(early) — BIASED!
    """
    df = df.copy()
    cohorts = sorted(df.loc[df['gvar'] > 0, 'gvar'].unique())
    T = df['t'].max()
    
    comparisons = []
    
    for i, g1 in enumerate(cohorts):
        # Early vs Never-treated (if any never-treated exist)
        never = df[df['gvar'] == 0]
        if len(never) > 0:
            treated_g1 = df[df['gvar'] == g1]
            
            # Pre: t < g1, Post: t >= g1
            pre_treat = treated_g1[treated_g1['t'] < g1]['Y'].mean()
            post_treat = treated_g1[treated_g1['t'] >= g1]['Y'].mean()
            pre_ctrl = never[never['t'] < g1]['Y'].mean()
            post_ctrl = never[never['t'] >= g1]['Y'].mean()
            
            dd = (post_treat - pre_treat) - (post_ctrl - pre_ctrl)
            n_treat = treated_g1['i'].nunique()
            n_ctrl = never['i'].nunique()
            
            comparisons.append({
                'type': 'Treated vs Never-treated',
                'treated_cohort': g1,
                'control_cohort': 'Never',
                'dd_estimate': dd,
                'n_treated': n_treat,
                'n_control': n_ctrl
            })
        
        # Early vs Late comparisons
        for j, g2 in enumerate(cohorts):
            if g1 >= g2:
                continue
            
            treated_early = df[df['gvar'] == g1]
            treated_late = df[df['gvar'] == g2]
            
            # Comparison 1: Early treated vs Late treated (pre = t<g1, post = g1<=t<g2)
            mid_period = (df['t'] >= g1) & (df['t'] < g2)
            pre_period = df['t'] < g1
            
            if pre_period.sum() > 0 and mid_period.sum() > 0:
                pre_e = treated_early[treated_early['t'] < g1]['Y'].mean()
                post_e = treated_early[mid_period[treated_early.index]]['Y'].mean() if mid_period[treated_early.index].sum() > 0 else np.nan
                pre_l = treated_late[treated_late['t'] < g1]['Y'].mean()
                post_l = treated_late[mid_period[treated_late.index]]['Y'].mean() if mid_period[treated_late.index].sum() > 0 else np.nan
                
                if not np.isnan(post_e) and not np.isnan(post_l):
                    dd = (post_e - pre_e) - (post_l - pre_l)
                    comparisons.append({
                        'type': 'Early vs Late (clean)',
                        'treated_cohort': g1,
                        'control_cohort': g2,
                        'dd_estimate': dd,
                        'n_treated': treated_early['i'].nunique(),
                        'n_control': treated_late['i'].nunique()
                    })
            
            # Comparison 2: Late treated vs Already-treated (PROBLEMATIC)
            post_both = df['t'] >= g2
            if mid_period.sum() > 0 and post_both.sum() > 0:
                pre_l2 = treated_late[mid_period[treated_late.index]]['Y'].mean() if mid_period[treated_late.index].sum() > 0 else np.nan
                post_l2 = treated_late[post_both[treated_late.index]]['Y'].mean() if post_both[treated_late.index].sum() > 0 else np.nan
                pre_e2 = treated_early[mid_period[treated_early.index]]['Y'].mean() if mid_period[treated_early.index].sum() > 0 else np.nan
                post_e2 = treated_early[post_both[treated_early.index]]['Y'].mean() if post_both[treated_early.index].sum() > 0 else np.nan
                
                if not any(np.isnan(x) for x in [pre_l2, post_l2, pre_e2, post_e2]):
                    dd = (post_l2 - pre_l2) - (post_e2 - pre_e2)
                    comparisons.append({
                        'type': 'Late vs Already-treated ⚠️',
                        'treated_cohort': g2,
                        'control_cohort': f'{g1} (already treated)',
                        'dd_estimate': dd,
                        'n_treated': treated_late['i'].nunique(),
                        'n_control': treated_early['i'].nunique()
                    })
    
    return pd.DataFrame(comparisons)


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    df = generate_did_data()
    
    print("=" * 60)
    print("Bacon Decomposition (2021)")
    print("=" * 60)
    
    result = bacon_decomposition(df)
    
    print(f"\n2×2 Comparisons:")
    print(result[['type', 'treated_cohort', 'control_cohort', 'dd_estimate']].to_string(index=False))
    
    print(f"\nSummary by type:")
    summary = result.groupby('type')['dd_estimate'].agg(['mean', 'count'])
    print(summary)
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = {'Treated vs Never-treated': 'navy',
              'Early vs Late (clean)': 'forestgreen',
              'Late vs Already-treated ⚠️': 'red'}
    
    for comp_type in result['type'].unique():
        subset = result[result['type'] == comp_type]
        ax.scatter(range(len(subset)), subset['dd_estimate'], 
                   label=comp_type, color=colors.get(comp_type, 'gray'), s=60)
    
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Comparison index')
    ax.set_ylabel('2×2 DD estimate')
    ax.set_title('Bacon Decomposition: TWFE = weighted sum of 2×2 comparisons')
    ax.legend()
    plt.tight_layout()
    
    outdir = os.path.join(os.path.dirname(__file__), 'output')
    os.makedirs(outdir, exist_ok=True)
    fig.savefig(os.path.join(outdir, '05_bacon.png'), dpi=150, bbox_inches='tight')
    print(f"\n  Saved: output/05_bacon.png")
    plt.close()
    
    print(f"\n📌 Red dots (Late vs Already-treated) are BIASED.")
    print(f"   If they have large weight, TWFE is unreliable.")
