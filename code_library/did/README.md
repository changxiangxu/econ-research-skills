# DID Methods Code Library

A complete, self-contained code library for Difference-in-Differences methods.
Each file generates its own simulated data and runs independently — **no external data needed**.

Inspired by [许文立 (wenddymacro)](https://github.com/wenddymacro/straggered_did_13) and
[Asjad Naqvi's DID Notes](https://github.com/asjadnaqvi/Diff-in-Diff-Notes).

---

## Which DID Should I Use?

```
What is your setup?
│
├── Only 2 periods × 2 groups?
│   └── ✅ 01_classic_twfe.do — Classic TWFE, simplest
│
├── Staggered rollout (units treated at different times)?
│   ├── Step 1: Run 05_bacon_decomposition.do to diagnose TWFE bias
│   ├── Step 2: Choose a robust estimator:
│   │   ├── Want ATT(g,t) + flexible aggregation? → 02_callaway_santanna.do
│   │   ├── Want event study with interaction weights? → 03_sun_abraham.do
│   │   ├── Want imputation-based (cleanest)? → 04_imputation_bjs.do
│   │   └── Want minimal assumptions? → 06_dcdh.do
│   └── Step 3: Sensitivity analysis → 07_honestdid.do
│
└── Not sure?
    └── Start with 01 → 05 → then pick from 02-04
```

## File List

| File | Method | Key Reference | Required Package |
|------|--------|---------------|-----------------|
| `01_classic_twfe.do` | Classic Two-Way Fixed Effects | Angrist & Pischke (2009) | `reghdfe` |
| `02_callaway_santanna.do` | Callaway & Sant'Anna (2021) | *Journal of Econometrics* | `csdid` |
| `03_sun_abraham.do` | Sun & Abraham (2021) | *Journal of Econometrics* | `eventstudyinteract` |
| `04_imputation_bjs.do` | Borusyak, Jaravel & Spiess (2024) | *Review of Economic Studies* | `did_imputation` |
| `05_bacon_decomposition.do` | Goodman-Bacon (2021) | *Journal of Econometrics* | `bacondecomp` |
| `06_dcdh.do` | de Chaisemartin & D'Haultfœuille (2020) | *American Economic Review* | `did_multiplegt` |
| `07_honestdid.do` | Rambachan & Roth (2023) | *Review of Economic Studies* | `honestdid` |

## Data Generating Process

All files use a common simulated panel:
- **40 units** observed over **30 periods** (t = 1,...,30)
- **Staggered treatment**: units enter treatment at t ∈ {10, 15, 20}, some never treated
- **True ATT = 2.0** (known, so we can benchmark estimators)
- **Heterogeneous effects optional**: later cohorts may have larger/smaller effects

## How to Use

1. Copy any `.do` file to your Stata working directory
2. Run it — no data download needed, data is simulated inside the script
3. Read the comments to understand each step
4. Replace the simulated data section with your own data
