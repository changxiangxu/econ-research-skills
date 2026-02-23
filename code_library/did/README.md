# DID Methods Code Library v2.0 (2026 Frontier)

A complete, self-contained code library covering **15 DID methods**.
Each file generates its own simulated data and runs independently.

Inspired by [许文立 (wenddymacro)](https://github.com/wenddymacro/straggered_did_13) and [Asjad Naqvi's DID Notes](https://github.com/asjadnaqvi/Diff-in-Diff-Notes).

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

## Complete File List

| # | File | Method | Author/Year | Use Case | Install |
|---|------|--------|-------------|----------|---------|
| 01 | `01_classic_twfe.do` | Classic TWFE | Angrist & Pischke | Simple 2×2 | `reghdfe` |
| 02 | `02_callaway_santanna.do` | Group-Time ATT | Callaway & Sant'Anna (2021) | Staggered | `csdid` |
| 03 | `03_sun_abraham.do` | Interaction-Weighted | Sun & Abraham (2021) | Staggered | `eventstudyinteract` |
| 04 | `04_imputation_bjs.do` | Imputation | Borusyak, Jaravel & Spiess (2024) | Staggered | `did_imputation` |
| 05 | `05_bacon_decomposition.do` | TWFE Decomposition | Goodman-Bacon (2021) | Diagnostic | `bacondecomp` |
| 06 | `06_dcdh.do` | Heterogeneous FE | de Chaisemartin & D'Haultfœuille (2020) | Non-absorbing | `did_multiplegt` |
| 07 | `07_honestdid.do` | Sensitivity Analysis | Rambachan & Roth (2023) | Robustness | `honestdid` |
| 08 | `08_did_multiplegt_dyn.do` | Dynamic Non-Binary | dCDH (2024) | Switching treatment | `did_multiplegt_dyn` |
| 09 | `09_did_multiplegt_stat.do` | Continuous + Stayers | dCDH (2024) | Continuous dose | `did_multiplegt_stat` |
| 10 | `10_gardner_did2s.do` | Two-Stage | Gardner (2022) | Large samples | `did2s` |
| 11 | `11_stacked_did.do` | Stacked Regression | Wing et al. (2024) | TWFE-compatible | `reghdfe` |
| 12 | `12_wooldridge_etwfe.do` | Extended TWFE | Wooldridge (2021) | Simple fix | `jwdid` |
| 13 | `13_synth_did.do` | Synthetic DID | Arkhangelsky et al. (2021) | Weak parallel trends | `sdid` |
| 14 | `14_continuous_did.do` | Continuous Treatment | Callaway et al. (2024) | Dose-response | manual |
| 15 | `15_comparison_master.do` | All Methods Comparison | — | Robustness appendix | all |
