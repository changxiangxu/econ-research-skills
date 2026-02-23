# DID Methods — R Code Library

> Same DID methods as the Stata version, using **official R packages** from original authors.
> Uses the **same verified Borusyak DGP** (400 units × 15 periods, `seed=10`).

## 🔑 Key Advantage: Official R Packages

Unlike Python (which requires manual implementations), **every method here uses the original author's R package**:

| Method | R Package | Author |
|--------|-----------|--------|
| TWFE + Event Study | `fixest` | Laurent Bergé |
| Callaway-Sant'Anna | `did` | **Callaway & Sant'Anna** |
| Sun-Abraham | `fixest::sunab()` | Built into fixest |
| BJS Imputation | `didimputation` | **Kirill Borusyak** |
| Bacon Decomposition | `bacondecomp` | **Goodman-Bacon** |
| dCDH | `DIDmultiplegt` | **de Chaisemartin** |
| HonestDiD | `HonestDiD` | **Rambachan & Roth** |
| Gardner did2s | `did2s` | **Kyle Butts** |
| Synthetic DID | `synthdid` | **Athey, Arkhangelsky et al.** |

## Install All Packages

```r
source("00_shared_dgp.R")
install_all_packages()
```

## File List

| # | File | Method | R Package |
|---|------|--------|-----------|
| 00 | `00_shared_dgp.R` | Shared DGP + installer | base R |
| 01 | `01_classic_twfe.R` | Classic TWFE | `fixest` |
| 02 | `02_callaway_santanna.R` | CS (2021) | `did` |
| 03 | `03_sun_abraham.R` | SA (2021) | `fixest` |
| 04 | `04_imputation_bjs.R` | BJS (2024) | `didimputation` |
| 05 | `05_bacon_decomposition.R` | Bacon (2021) | `bacondecomp` |
| 06 | `06_dcdh.R` | dCDH (2020) | `DIDmultiplegt` |
| 07 | `07_honestdid.R` | Sensitivity (2023) | `HonestDiD` |
| 10 | `10_gardner_did2s.R` | Gardner (2022) | `did2s` |
| 13 | `13_synth_did.R` | SDID (2021) | `synthdid` |
| 15 | `15_comparison_master.R` | All Methods | all |

## Quick Start

```r
# Run any single method:
source("02_callaway_santanna.R")

# Run all methods and get comparison plot:
source("15_comparison_master.R")
```

## Stata ↔ R Equivalence

| Stata | R | Notes |
|-------|---|-------|
| `reghdfe Y D, a(i t)` | `feols(Y ~ D \| i + t)` | fixest is faster |
| `csdid Y, ivar(i) time(t) gvar(g)` | `att_gt(yname="Y", ...)` | Same authors |
| `eventstudyinteract Y ...` | `feols(Y ~ sunab(Ei, t) \| i + t)` | One line! |
| `did_imputation Y i t Ei` | `did_imputation(data, ...)` | Same author |
| `bacondecomp Y D` | `bacon(Y ~ D, data, ...)` | Same author |
| `did_multiplegt Y i t D` | `did_multiplegt(df, ...)` | Same author |
| `event_plot` | `iplot()` / `ggdid()` | Built-in |
