# DID Methods — Python Code Library

> Same 15 DID methods as the Stata version, implemented in Python.
> Uses the **same verified Borusyak DGP** (400 units × 15 periods, `seed=10`).

## Requirements

```bash
pip install numpy pandas matplotlib statsmodels
# Optional (for full `differences` package CS):
pip install differences
```

## File List

| # | File | Method | Implementation |
|---|------|--------|---------------|
| 00 | `00_shared_dgp.py` | Shared DGP + utils | numpy/pandas |
| 01 | `01_classic_twfe.py` | Classic TWFE | statsmodels OLS |
| 02 | `02_callaway_santanna.py` | Callaway-Sant'Anna (2021) | manual + `differences` |
| 03 | `03_sun_abraham.py` | Sun-Abraham (2021) | manual cohort-DiD |
| 04 | `04_imputation_bjs.py` | BJS Imputation (2024) | manual imputation |
| 05 | `05_bacon_decomposition.py` | Bacon Decomposition (2021) | manual 2×2 decomp |
| 10 | `10_gardner_did2s.py` | Gardner Two-Stage (2022) | manual residualization |
| 11 | `11_stacked_did.py` | Stacked DID (2019) | manual stacking |
| 12 | `12_wooldridge_etwfe.py` | Wooldridge ETWFE (2021) | statsmodels + interactions |
| 15 | `15_comparison_master.py` | All Methods Comparison | runs all above |

## Quick Start

```bash
# Run any single method:
python 01_classic_twfe.py

# Run all methods and get comparison plot:
python 15_comparison_master.py
```

All outputs (PNG plots) are saved to `output/`.

## Stata ↔ Python Equivalence

| Stata Package | Python Equivalent |
|--------------|-------------------|
| `reghdfe` | `statsmodels OLS + C(i) + C(t)` |
| `csdid` | `differences.att_gt()` or manual |
| `eventstudyinteract` | manual cohort-DiD |
| `did_imputation` | manual imputation |
| `bacondecomp` | manual 2×2 decomposition |
| `did2s` | manual residualization |
| `stackedev` | manual stacking |
| `jwdid` / `wooldid` | manual cohort×post interactions |
| `event_plot` | `matplotlib` custom |

## Note on Python DID Ecosystem

The Python DID ecosystem is **less mature** than Stata's. Most methods require manual implementation. The `differences` package provides CS estimation but is still developing. For **production research**, we recommend Stata or R. These Python scripts are for **learning and understanding** the methods.
