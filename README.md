# 📚 Econ Research Skills

> **The Complete Empirical Economics Toolkit: From Topic Selection to Journal Submission**
> 6 Stages · 20+ Modules · 8 AI Skills · 7 DID Methods · Stata/R Code Library

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Code-Stata%20%7C%20R%20%7C%20Python-blue)](.)
[![Version](https://img.shields.io/badge/Version-v2.1-green)](.)

---

## What Is This?

A **complete, open-source toolkit** for anyone writing an empirical economics paper. Whether you're a PhD student running your first DID or a seasoned researcher polishing a paper for the AER, this repo has something for you.

**Three layers of content:**

| Layer | What It Is | How to Use |
|-------|-----------|------------|
| 🤖 **AI Skills** (`skills/`) | 8 structured prompt modules, 38 tasks | Copy into your project → AI follows instructions |
| 💻 **Code Library** (`code_library/`) | Ready-to-run Stata/R templates | Copy a `.do` file → replace data → run |
| 📋 **References & Checklists** | Guides, checklists, templates | Read before submission |

---

## 🗺️ Full Roadmap: 6 Stages of Empirical Research

### Stage 0: Project Setup
| Module | Content | Location |
|--------|---------|----------|
| 🛠️ Tool Stack | Stata/R/Python selection, installation, 30+ essential packages | [tool_stack_guide.md](references/tool_stack_guide.md) |
| 📁 Project Structure | Standard folder layout (`00_RawData → 03_Output`) | [templates/](templates/) |
| 🔄 Reproducibility | Master script (one-click replication) | [stata/00_master.do](templates/stata/00_master.do) · [r/00_master.R](templates/r/00_master.R) |

---

### Stage 1: Topic Selection & Literature
| Module | Content | Location |
|--------|---------|----------|
| 🎯 Topic Selection | Brainstorming · Background Brief · Feasibility Check | [Topic_Selector/](skills/Topic_Selector/) |
| 📚 Literature | Deep Reading · Matrix Generation · Review Writing · Gap ID | [Literature_Navigator/](skills/Literature_Navigator/) |

---

### Stage 2: Theory & Background
| Module | Content | Location |
|--------|---------|----------|
| 🏛️ Theoretical Framework | Framework Recommendation · Hypothesis Development · 30+ Theory Index | [Theoretical_Framework/](skills/Theoretical_Framework/) |

---

### Stage 3: Data
| Module | Content | Location |
|--------|---------|----------|
| 🔧 Data Pipeline | Discovery · Cleaning · Management · Variable Description · Codebook | [Data_Pipeline/](skills/Data_Pipeline/) |
| 📊 Data Cleaning Code | Import/merge · Missing values · Winsorize · Variable construction | `code_library/data_cleaning/` *(coming soon)* |

---

### Stage 4: Empirical Analysis
| Module | Content | Location |
|--------|---------|----------|
| ⚗️ **DID (7 methods)** | TWFE · Callaway-Sant'Anna · Sun-Abraham · BJS Imputation · Bacon Decomposition · dCDH · HonestDiD | [code_library/did/](code_library/did/) ✅ |
| 🔬 **IV** | 2SLS · Weak Instruments · Over-ID · Shift-Share | `code_library/iv/` *(coming soon)* |
| 📐 **RDD** | Sharp · Fuzzy · McCrary · Bandwidth | `code_library/rdd/` *(coming soon)* |
| 🛡️ **Robustness** | Placebo · Oster bounds · Permutation · Alt specs (7 tests) | `code_library/robustness/` *(coming soon)* |
| 🔀 **Heterogeneity** | Split-sample · Interaction · Triple-diff | `code_library/heterogeneity/` *(coming soon)* |
| ⚙️ **Mechanism** | Channel variables · Mediation (Baron-Kenny) | `code_library/mechanism/` *(coming soon)* |
| 🧪 **Endogeneity** | Pre-trends · PSM-DID · Heckman | `code_library/endogeneity/` *(coming soon)* |
| 🎯 Causal Inference Guide | DID Encyclopedia · Endogeneity Tests · Model Selection · Textbook Index | [Causal_Inference_Guide/](skills/Causal_Inference_Guide/) |
| 📊 Results Manager | Interpretation · Heterogeneity Design · Table Formatting · Archiving | [Results_Manager/](skills/Results_Manager/) |
| 💻 Code Project Manager | Master Script · Regression Pipeline · Code Review · Replication Code | [Code_Project_Manager/](skills/Code_Project_Manager/) |

---

### Stage 5: Paper Writing
| Module | Content | Location |
|--------|---------|----------|
| ✍️ Academic Paper Writer | Drafting · Polishing · Abstract · Introduction · Conclusion · Language Refinement · Reviewer Response | [Academic_Paper_Writer/](skills/Academic_Paper_Writer/) |
| 📊 Tables & Figures Code | Descriptive table · Regression table · Event study plot · Coefficient plot | `code_library/tables_figures/` *(coming soon)* |

---

### Stage 6: Submission & Beyond
| Module | Content | Location |
|--------|---------|----------|
| ✅ Pre-Submission Checklist | Manuscript · Tables · Rigor · References · Replication package | [before_submission.md](checklists/before_submission.md) |
| 🧪 Endogeneity Checklist | Placebo · Pre-trends · IV tests · Oster bounds · Permutation | [endogeneity_checklist.md](checklists/endogeneity_checklist.md) |
| 🛡️ Robustness Checklist | 10 categories, 15+ specific tests | [robustness_checklist.md](checklists/robustness_checklist.md) |
| 📝 Reviewer Response | Point-by-point template · Common scenarios | [response_to_reviewers.md](checklists/response_to_reviewers.md) |

---

## 💻 DID Code Library (Highlight)

The crown jewel of this repo — **7 complete, tutorial-style Stata do-files** covering every modern DID method. Each file is self-contained with simulated data, runs independently, and includes line-by-line comments explaining *why*, not just *how*.

```
Which DID should I use?
│
├── Simple 2×2 design? → 01_classic_twfe.do
├── Staggered rollout?
│   ├── Step 1: Diagnose → 05_bacon_decomposition.do
│   ├── Step 2: Estimate → 02 (CS) or 03 (SA) or 04 (BJS)
│   └── Step 3: Sensitivity → 07_honestdid.do
└── Treatment switches on/off? → 06_dcdh.do
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

---

## 📖 Essential Reading

| # | Book | Free? | Best For |
|---|------|-------|----------|
| 1 | [*Causal Inference: The Mixtape*](https://mixtape.scunning.com/) | ✅ | DID, IV, RD — full code |
| 2 | *Mastering 'Metrics* (Angrist & Pischke) | ❌ | Gentle intro |
| 3 | [*The Effect*](https://theeffectbook.net/) (Huntington-Klein) | ✅ | DAGs, modern DID |
| 4 | *Mostly Harmless Econometrics* (Angrist & Pischke) | ❌ | The bible |
| 5 | [*Causal Inference: What If*](https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/) (Hernán & Robins) | ✅ | Mechanism analysis |

See [textbook_index.md](references/textbook_index.md) for chapter-by-chapter index and [github_repos.md](references/github_repos.md) for 20+ curated GitHub repositories.

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/changxiangxu/econ-research-skills.git

# Try a DID method (no data needed — simulated inside)
# Open any .do file in Stata and run it
```

**Three ways to use this repo:**

1. **🤖 AI-Powered**: Copy `skills/` into your project → AI tools auto-discover the skill files
2. **💻 Code Templates**: Copy any `.do` file → replace simulated data with yours → run
3. **📖 Reference Manual**: Read `checklists/` and `references/` as structured guides

---

## 🤝 Contributing

Contributions welcome! You can:
- Add code templates (especially R versions of existing Stata files)
- Improve or translate skill modules
- Add new checklists or reference guides
- Share worked examples with public data

## 📄 License

MIT License — free to use, modify, and distribute.
