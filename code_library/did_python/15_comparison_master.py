"""
15_comparison_master.py — Run all methods and produce comparison plot
Python equivalent of 15_comparison_master.do

Runs: TWFE, CS, SA, BJS, Gardner, Stacked, ETWFE on same data.
Produces combined event study plot.
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from importlib.machinery import SourceFileLoader
import importlib

_dir = os.path.dirname(__file__)

# Import shared DGP
shared_dgp = SourceFileLoader("shared_dgp", os.path.join(_dir, "00_shared_dgp.py")).load_module()
generate_did_data = shared_dgp.generate_did_data
compute_true_effects = shared_dgp.compute_true_effects

# Import all methods (numeric prefixes require importlib)
def _load(name, filename):
    return SourceFileLoader(name, os.path.join(_dir, filename)).load_module()

mod01 = _load("twfe", "01_classic_twfe.py")
mod02 = _load("cs", "02_callaway_santanna.py")
mod03 = _load("sa", "03_sun_abraham.py")
mod04 = _load("bjs", "04_imputation_bjs.py")
mod10 = _load("gardner", "10_gardner_did2s.py")
mod11 = _load("stacked", "11_stacked_did.py")
mod12 = _load("etwfe", "12_wooldridge_etwfe.py")


def run_all_methods():
    """Run all DID methods and produce comparison."""
    df = generate_did_data()
    true_att = compute_true_effects(df)
    
    results = {}
    
    # 1. TWFE (biased baseline)
    print("Running TWFE...")
    est, _, _ = mod01.run_twfe_event_study(df)
    results['TWFE OLS'] = est
    
    # 2. Callaway-Sant'Anna
    print("Running CS...")
    est = mod02.run_cs_manual(df)
    results['CS (2021)'] = {k: v for k, v in est.items() if -5 <= k <= 5}
    
    # 3. Sun-Abraham
    print("Running SA...")
    est = mod03.run_sun_abraham(df)
    results['SA (2021)'] = est
    
    # 4. BJS Imputation
    print("Running BJS...")
    est, _, _ = mod04.run_bjs_imputation(df)
    results['BJS (2024)'] = est
    
    # 5. Gardner
    print("Running Gardner...")
    est, _, _, _, _ = mod10.run_gardner_did2s(df)
    results['Gardner (2022)'] = est
    
    # 6. Stacked DID
    print("Running Stacked...")
    est, _, _ = mod11.run_stacked_did(df)
    results['Stacked'] = est
    
    # 7. Wooldridge ETWFE
    print("Running ETWFE...")
    est, _, _, _ = mod12.run_wooldridge_etwfe(df)
    results['ETWFE (2021)'] = est
    
    return results, true_att


def plot_comparison(results, true_att, save_path=None):
    """Combined event study plot comparing all methods."""
    fig, ax = plt.subplots(figsize=(14, 8))
    
    colors = {
        'TWFE OLS': 'red',
        'CS (2021)': 'navy',
        'SA (2021)': 'forestgreen',
        'BJS (2024)': 'darkorange',
        'Gardner (2022)': 'purple',
        'Stacked': 'brown',
        'ETWFE (2021)': 'teal'
    }
    
    markers = {
        'TWFE OLS': 'x',
        'CS (2021)': 'o',
        'SA (2021)': 's',
        'BJS (2024)': 'D',
        'Gardner (2022)': '^',
        'Stacked': 'v',
        'ETWFE (2021)': 'P'
    }
    
    # Plot true values
    true_k = sorted(true_att.keys())
    true_v = [true_att[k] for k in true_k]
    ax.plot(true_k, true_v, 'k+', markersize=15, markeredgewidth=2, 
            label='True value', zorder=10)
    
    # Plot each method with slight horizontal offset
    offsets = np.linspace(-0.3, 0.3, len(results))
    for (name, est), offset in zip(results.items(), offsets):
        periods = sorted([k for k in est.keys() if -5 <= k <= 5])
        vals = [est[k] for k in periods]
        shifted = [k + offset for k in periods]
        ax.scatter(shifted, vals, marker=markers.get(name, 'o'), 
                   color=colors.get(name, 'gray'), s=40, alpha=0.8,
                   label=name, zorder=5)
    
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.axvline(x=-0.5, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Periods since treatment', fontsize=12)
    ax.set_ylabel('Average causal effect', fontsize=12)
    ax.set_title('DID Estimator Comparison (400 units, 15 periods)\n'
                 'Same Borusyak DGP with heterogeneous τ = t − Ei', fontsize=14)
    ax.legend(loc='upper left', fontsize=10)
    ax.set_xticks(range(-5, 6))
    plt.tight_layout()
    
    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"\nSaved: {save_path}")
    
    plt.close()
    return fig


# ═══════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("=" * 60)
    print("DID METHOD COMPARISON — ALL ON SAME DATA")
    print("=" * 60)
    
    results, true_att = run_all_methods()
    
    outdir = os.path.join(os.path.dirname(__file__), 'output')
    os.makedirs(outdir, exist_ok=True)
    
    plot_comparison(results, true_att, 
                    save_path=os.path.join(outdir, '00_comparison.png'))
    
    # Summary table
    print(f"\n{'Method':<20} {'K=0':>8} {'K=1':>8} {'K=2':>8} {'K=3':>8} {'K=4':>8} {'K=5':>8}")
    print("-" * 68)
    print(f"{'True value':<20}", end='')
    for k in range(6):
        print(f" {true_att.get(k, 0):>7.3f}", end='')
    print()
    
    for name, est in results.items():
        print(f"{name:<20}", end='')
        for k in range(6):
            val = est.get(k, float('nan'))
            print(f" {val:>7.3f}", end='')
        print()
    
    print(f"\n📌 Robust methods (CS, SA, BJS, Gardner, Stacked, ETWFE)")
    print(f"   should all be close to the true value.")
    print(f"   TWFE OLS should show visible bias.")
