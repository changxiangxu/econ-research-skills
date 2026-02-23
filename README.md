# 📚 Econ Research Skills

> **AI Skills + Code Templates for Empirical Economics Research**
> 8 Skill Modules · 38 Tasks · 7 DID Methods · Stata Code Library

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Code-Stata-blue)](.)

---

## What Is This?

Two things that don't exist anywhere else:

1. **8 AI Skill Modules** — structured prompts covering the entire research workflow (topic selection → paper submission). Drop into your project, your AI assistant follows them automatically.
2. **Code Library** — ready-to-run Stata `.do` files for every major method. Self-contained, with simulated data inside — no downloads needed.

---

## 🤖 AI Skills (`skills/`)

| Module | Tasks | What It Does |
|--------|-------|-------------|
| 🎯 [Topic Selector](skills/Topic_Selector/) | 3 | Brainstorming · Background Brief · Feasibility Check |
| 📚 [Literature Navigator](skills/Literature_Navigator/) | 4 | Deep Reading · Literature Matrix · Review Writing · Gap ID |
| 🏛️ [Theoretical Framework](skills/Theoretical_Framework/) | 3 | Framework Matching · Hypothesis Development · 30+ Theory Index |
| 🔧 [Data Pipeline](skills/Data_Pipeline/) | 5 | Data Discovery · Cleaning · Management · Variable Description · Codebook |
| ⚗️ [Causal Inference Guide](skills/Causal_Inference_Guide/) | 6 | DID Encyclopedia · Endogeneity · Robustness Menu · Model Selection |
| 💻 [Code Project Manager](skills/Code_Project_Manager/) | 5 | Master Script · Regression Pipeline · Code Review · Replication |
| 📊 [Results Manager](skills/Results_Manager/) | 5 | Interpretation · Heterogeneity Design · Mechanism · Table Formatting |
| ✍️ [Academic Paper Writer](skills/Academic_Paper_Writer/) | 7 | Drafting · Polishing · Reviewer Response · Abstract · Intro · Conclusion · Language |

---

## 💻 Code Library (`code_library/`)

### DID Methods (7 files) ✅

Each file: simulated data → estimation → event study plot → table export. Line-by-line comments.

```
Which DID? → 01 (classic) → 05 (diagnose) → 02/03/04 (robust) → 07 (sensitivity)
```

| File | Method | Reference |
|------|--------|-----------|
| [01_classic_twfe.do](code_library/did/01_classic_twfe.do) | Classic TWFE | Angrist & Pischke (2009) |
| [02_callaway_santanna.do](code_library/did/02_callaway_santanna.do) | Callaway & Sant'Anna | *JoE* 2021 |
| [03_sun_abraham.do](code_library/did/03_sun_abraham.do) | Sun & Abraham | *JoE* 2021 |
| [04_imputation_bjs.do](code_library/did/04_imputation_bjs.do) | BJS Imputation | *ReStud* 2024 |
| [05_bacon_decomposition.do](code_library/did/05_bacon_decomposition.do) | Bacon Decomposition | *JoE* 2021 |
| [06_dcdh.do](code_library/did/06_dcdh.do) | de Chaisemartin & D'Haultfœuille | *AER* 2020 |
| [07_honestdid.do](code_library/did/07_honestdid.do) | Rambachan & Roth Sensitivity | *ReStud* 2023 |

### Coming Soon

| Module | Files | Content |
|--------|-------|---------|
| `iv/` | 4 | 2SLS · Weak Instruments · Over-ID · Shift-Share |
| `rdd/` | 3 | Sharp · Fuzzy · McCrary Diagnostics |
| `robustness/` | 7 | Placebo · Oster · Permutation · Alt Specs |
| `heterogeneity/` | 3 | Split-Sample · Interaction · Triple-Diff |
| `mechanism/` | 2 | Channel Variables · Mediation |
| `endogeneity/` | 3 | Pre-Trends · PSM-DID · Heckman |
| `tables_figures/` | 4 | Descriptive Table · Regression Table · Event Study · Coefplot |

---

## ✅ Checklists (`checklists/`)

| Checklist | Use When |
|-----------|----------|
| [Endogeneity](checklists/endogeneity_checklist.md) | After baseline regression |
| [Robustness](checklists/robustness_checklist.md) | Before writing robustness section |
| [Pre-Submission](checklists/before_submission.md) | Before sending to journal |
| [Reviewer Response](checklists/response_to_reviewers.md) | After receiving referee report |

---

## 📖 References

- [Textbook Chapter Index](references/textbook_index.md) — Which chapter of Mixtape / MHE / The Effect for each method
- [Master .do template](templates/stata/00_master.do) — One-click replication script
- [Master .R template](templates/r/00_master.R) — R equivalent

---

## 🚀 Quick Start

**Use with AI**: Copy `skills/` into your project → AI auto-discovers the instructions.

**Use the code**: Open any `.do` file in Stata → run it → works immediately.

**Use as reference**: Read `checklists/` before submission.

---

## 📄 License

MIT — free to use, modify, and distribute.
