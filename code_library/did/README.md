# DID Methods Code Library v2.1 (Verified from Original Authors)

A complete code library covering **15 DID methods** in Stata.

## ⚠️ Code Provenance

All estimation commands and DGP are **adapted from verified, peer-reviewed sources**:

| Source | Author | Methods Covered | GitHub |
|--------|--------|----------------|--------|
| `five_estimators_example.do` | Kirill Borusyak (UCL) | BJS, CS, SA, dCDH, TWFE | [borusyak/did_imputation](https://github.com/borusyak/did_imputation) |
| `staggered_did_13` | 许文立 (wenddymacro) | 16 estimators | [wenddymacro/straggered_did_13](https://github.com/wenddymacro/straggered_did_13) |

**All files share the same verified DGP:**
- 400 units × 15 periods, `set seed 10`
- Staggered rollout: Ei ~ Uniform{10,...,16}
- Heterogeneous treatment effects: τ = t − Ei
- This DGP ensures TWFE is biased → you can see each method's correction

---

## Which DID Should I Use?

```
What is your setup?
│
├── Simple 2×2 design?
│   └── 01_classic_twfe.do
│
├── Staggered rollout (standard)?
│   ├── Diagnose: 05_bacon_decomposition.do
│   ├── Estimate: 02 (CS) / 03 (SA) / 04 (BJS) / 10 (Gardner) / 12 (ETWFE)
│   └── Sensitivity: 07_honestdid.do
│
├── Treatment switches on/off?
│   └── 06_dcdh.do or 08_did_multiplegt_dyn.do
│
├── Continuous treatment (dose/intensity)?
│   └── 09_did_multiplegt_stat.do or 14_continuous_did.do
│
├── Weak parallel trends?
│   └── 13_synth_did.do
│
└── Want to compare all methods?
    └── 15_comparison_master.do
```

## File List

| # | File | Method | Source | Install |
|---|------|--------|--------|---------|
| 01 | `01_classic_twfe.do` | Classic TWFE | Borusyak + wenddymacro | `reghdfe` |
| 02 | `02_callaway_santanna.do` | Callaway & Sant'Anna (2021) | Borusyak + wenddymacro | `csdid` |
| 03 | `03_sun_abraham.do` | Sun & Abraham (2021) | Borusyak + wenddymacro | `eventstudyinteract` |
| 04 | `04_imputation_bjs.do` | BJS Imputation (2024) | **Borusyak original** | `did_imputation` |
| 05 | `05_bacon_decomposition.do` | Bacon Decomposition (2021) | verified | `bacondecomp` |
| 06 | `06_dcdh.do` | dCDH (2020) | Borusyak + wenddymacro | `did_multiplegt` |
| 07 | `07_honestdid.do` | Rambachan & Roth (2023) | package docs | `honestdid` |
| 08 | `08_did_multiplegt_dyn.do` | dCDH Dynamic (2024) | package docs | `did_multiplegt_dyn` |
| 09 | `09_did_multiplegt_stat.do` | dCDH Continuous (2024) | package docs | `did_multiplegt_stat` |
| 10 | `10_gardner_did2s.do` | Gardner Two-Stage (2022) | wenddymacro | `did2s` |
| 11 | `11_stacked_did.do` | Stacked DID (Cengiz 2019) | wenddymacro | `stackedev` |
| 12 | `12_wooldridge_etwfe.do` | Wooldridge ETWFE (2021) | wenddymacro | `jwdid` + `wooldid` |
| 13 | `13_synth_did.do` | Synthetic DID (2021) | wenddymacro | `sdid` |
| 14 | `14_continuous_did.do` | Continuous DID (2024) | manual implementation | — |
| 15 | `15_comparison_master.do` | All Methods Comparison | Borusyak structure | all |
