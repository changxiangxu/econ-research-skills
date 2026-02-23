# 📚 Econ Research Skills

> **A Complete AI Skill System & Step-by-Step Roadmap for Empirical Economics Research**
> From Topic Selection to Journal Submission — 8 Skill Modules, 38 Tasks, 6-Stage Roadmap

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Code-Stata%20%7C%20R%20%7C%20Python-blue)](.)
[![Stage](https://img.shields.io/badge/Stage-v2.0-green)](.)

## 🎯 What Is This?

A **world-class toolkit** for economics PhD students and researchers conducting empirical research. It combines:

1. **8 AI Skill Modules** (38 tasks) — structured prompts that guide AI tools through every stage of research
2. **6-Stage Roadmap** — a complete 10-month action plan from topic selection to submission
3. **Curated GitHub Repos** — the best open-source tools, templates, and replication packages
4. **Code Library** — ready-to-use Stata/R/Python code for DID, IV, RD, data cleaning, and more
5. **Checklists** — endogeneity, robustness, pre-submission, and more

Built on Stanford CS146S *"Power Prompting for LLMs"* methodology (System Prompts, Chain-of-Thought, Reflexion).

---

## 🗺️ 10-Month Roadmap

```
Month 1-2          Month 3-5           Month 6-8          Month 9        Month 10
┌──────────┐    ┌──────────────┐    ┌──────────────┐   ┌──────────┐   ┌──────────┐
│ 📖 Topic  │ →  │ 🔧 Data &    │ →  │ 📊 Full      │ → │ ✍️ Write  │ → │ 📤 Submit │
│ & Lit     │    │ Cleaning     │    │ Analysis     │   │ & Polish │   │ & Replic │
│ Review    │    │ & Baseline   │    │ DID/IV/Rob   │   │          │   │ Package  │
└──────────┘    └──────────────┘    └──────────────┘   └──────────┘   └──────────┘
  Stage 1-2          Stage 3            Stage 4           Stage 5        Stage 6
```

| Stage | Duration | Key Activities | Output |
|-------|----------|---------------|--------|
| **0. Setup** | 1 week | Tool stack, folder structure, Git | Project repo + master script |
| **1. Topic & Literature** | 2-4 weeks | Topic search, 10-15 papers, literature matrix | Topic brief (1-2 pages) |
| **2. Theory & Background** | 1-2 weeks | Theoretical framework, DAGs, policy background | Theory section draft |
| **3. Data** | 3-6 weeks | Acquire, clean, construct variables, codebook | `cleaned.dta` + data dictionary |
| **4. Analysis** | 4-8 weeks | Baseline → Robustness → Heterogeneity → Mechanism → DID | All tables & figures |
| **5. Writing** | 4-6 weeks | Draft all sections, iterate introduction & conclusion | Complete manuscript |
| **6. Submission** | Ongoing | Replication package, pre-print, journal submission | Published paper 🎉 |

---

## 📦 Repository Structure

```
econ-research-skills/
├── 📁 skills/                 # 8 AI Skill Modules (38 tasks)
├── 📁 code_library/           # Ready-to-use method code
│   ├── did/                   # DID full suite (7 methods)
│   ├── data_cleaning/         # Winsorize, missing values, panel balance
│   └── tables_figures/        # Event study plots, coefficient plots
├── 📁 templates/              # Project templates (Stata & R)
│   ├── stata/                 # Master.do + 8 sub-files
│   └── r/                     # Master.R equivalent
├── 📁 references/             # Textbook index + frontier papers + GitHub repos
├── 📁 checklists/             # Endogeneity, robustness, pre-submission
└── 📁 examples/               # Complete DID example with public data
```

---

## 🤖 AI Skill Modules (`skills/`)

| Module | Tasks | Core Capabilities |
|--------|-------|-------------------|
| 🎯 [Topic_Selector](skills/Topic_Selector/) | 3 | Brainstorming · Background Brief · Feasibility Assessment |
| 📚 [Literature_Navigator](skills/Literature_Navigator/) | 4 | Deep Reading · Literature Matrix · Review Writing · Gap Identification |
| ⚗️ [Causal_Inference_Guide](skills/Causal_Inference_Guide/) | 6 | DID Encyclopedia (7 methods) · Endogeneity Tests · Robustness Menu · Textbook Index · Model Selection |
| 🏛️ [Theoretical_Framework](skills/Theoretical_Framework/) | 3 | Framework Recommendation · Hypothesis Development · 30+ Theory Index |
| 🔧 [Data_Pipeline](skills/Data_Pipeline/) | 5 | Data Discovery · Cleaning · Management Standards · Variable Description · Data Dictionary |
| 💻 [Code_Project_Manager](skills/Code_Project_Manager/) | 5 | Master Script · Regression Pipeline · Code Review · Documentation · Replication Code |
| 📊 [Results_Manager](skills/Results_Manager/) | 5 | Results Interpretation · Heterogeneity Design · Mechanism Analysis · Table Formatting · Archiving |
| ✍️ [Academic_Paper_Writer](skills/Academic_Paper_Writer/) | 7 | Drafting · Polishing · Reviewer Response · Abstract · Introduction · Conclusion · Language Refinement |

---

## 📖 Essential Reading (Recommended Order)

| # | Book | Author | Level | Free? | Best For |
|---|------|--------|-------|-------|----------|
| 1 | [*Causal Inference: The Mixtape*](https://mixtape.scunning.com/) | Scott Cunningham | ⭐⭐ | ✅ Free online | DID, IV, RD with full Stata/R/Python code |
| 2 | *Mastering 'Metrics* | Angrist & Pischke | ⭐ | ❌ | Gentle intro to causal inference |
| 3 | [*The Effect*](https://theeffectbook.net/) | Nick Huntington-Klein | ⭐⭐ | ✅ Free online | Research design, DAGs, modern DID |
| 4 | *Mostly Harmless Econometrics* | Angrist & Pischke | ⭐⭐ | ❌ | The causal inference bible |
| 5 | [*Causal Inference: What If*](https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/) | Hernán & Robins | ⭐⭐⭐ | ✅ Free PDF | Potential outcomes, mechanism analysis |
| 6 | *Causal Inference for Statistics...* | Imbens & Rubin | ⭐⭐⭐ | ❌ | Mathematical foundations |

---

## 🔗 Curated GitHub Repositories

### 🏗️ Project Templates (Fork One to Start!)

| Repository | Description | Stars |
|-----------|-------------|-------|
| [OpenSourceEconomics/econ-project-templates](https://github.com/OpenSourceEconomics/econ-project-templates) | **Best-in-class** reproducible research template with Snakemake, auto-tables, one-click replication | ⭐⭐⭐ |
| [lachlandeer/snakemake-econ-r](https://github.com/lachlandeer/snakemake-econ-r) | Snakemake pipeline template for R users | ⭐⭐ |
| [aeturrell/coding-for-economists](https://github.com/aeturrell/coding-for-economists) | Complete coding guide + project structure for economists | ⭐⭐⭐ |

### ⚗️ Causal Inference Code & Data

| Repository | Description | Language |
|-----------|-------------|----------|
| [scunning1975/mixtape](https://github.com/scunning1975/mixtape) | All Mixtape chapters — full code + data | Stata/R/Python |
| [NickCH-K/causaldata](https://github.com/NickCH-K/causaldata) | All example datasets from Mixtape + The Effect + What If | R/Stata/Python |
| [vikjam/mostly-harmless-replication](https://github.com/vikjam/mostly-harmless-replication) | Full replication of all MHE tables & figures | Stata/R/Python/Julia |
| [matheusfacure/python-causality-handbook](https://github.com/matheusfacure/python-causality-handbook) | Causal inference handbook with Python | Python |

### 📐 DID Methods (Modern)

| Repository | Description | Method |
|-----------|-------------|--------|
| [bcallaway11/did](https://github.com/bcallaway11/did) | **Official** Callaway & Sant'Anna package | R |
| [friosavila/csdid](https://github.com/friosavila/csdid) | Callaway & Sant'Anna for Stata | Stata |
| [lsun20/eventstudyinteract](https://github.com/lsun20/eventstudyinteract) | Sun & Abraham interaction-weighted estimator | Stata |
| [borusyak/did_imputation](https://github.com/borusyak/did_imputation) | Borusyak, Jaravel & Spiess imputation | Stata/R |
| [asheshrambachan/HonestDiD](https://github.com/asheshrambachan/HonestDiD) | Rambachan & Roth sensitivity analysis | R/Stata |
| [pedrohcgs/CS_RR](https://github.com/pedrohcgs/CS_RR) | CS + Rambachan-Roth sensitivity extension | R |
| [Mixtape-Sessions](https://github.com/Mixtape-Sessions) | Cunningham's DID workshop materials + code | Multi |
| [kylebutts/did2s](https://github.com/kylebutts/did2s) | Gardner two-step DID estimator | R/Stata |

### 🔎 Resource Collections

| Repository | Description |
|-----------|-------------|
| [matteocourthoud/awesome-causal-inference](https://github.com/matteocourthoud/awesome-causal-inference) | **Most comprehensive** causal inference resource list |
| [ledwindra/replication-code-economics](https://github.com/ledwindra/replication-code-economics) | Index of top journal replication packages on GitHub |
| [NickCH-K/TheEffectAssignments](https://github.com/NickCH-K/TheEffectAssignments) | The Effect assignments + DAG drawing code |

---

## ✅ Checklists (`checklists/`)

Quick-reference checklists for critical stages:

- [**Endogeneity Testing Checklist**](checklists/endogeneity_checklist.md) — Placebo, pre-trends, IV tests, Oster bounds
- [**Robustness Checks Checklist**](checklists/robustness_checklist.md) — 15 types of robustness checks
- [**Pre-Submission Checklist**](checklists/before_submission.md) — Final review before sending to journal
- [**Reviewer Response Template**](checklists/response_to_reviewers.md) — Structured response format

---

## 🛠️ Tool Stack

| Category | Recommended | Notes |
|----------|------------|-------|
| **Data & Regression** | Stata (most stable) / R (free, ggplot2) / Python (pandas + linearmodels) | Pick one as primary |
| **Version Control** | Git + GitHub | Non-negotiable |
| **References** | Zotero + Better BibTeX | Free, integrates with Word/LaTeX |
| **Writing** | Overleaf (LaTeX) or Word + Grammarly | LaTeX preferred for journals |
| **Tables** | `estout`/`esttab` (Stata) / `modelsummary` (R) / `stargazer` (Python) | Auto-export to .tex |
| **Reproducibility** | `master.do` (Stata) / `renv` + Quarto (R) / `venv` + Jupyter (Python) | One-click replication |

---

## 🚀 Quick Start

### Option 1: Use with AI Tools
Place the `skills/` folder in your project directory. AI tools will automatically discover and follow the instructions.

### Option 2: Fork as Project Template
1. Fork this repo
2. Replace `examples/` with your data
3. Follow the 6-stage roadmap
4. Use `code_library/` templates for your analysis

### Option 3: Reference Manual
Read individual `SKILL.md` files and `checklists/` as structured guides.

---

## 🤝 Contributing

Contributions welcome! You can:
- Add code templates to `code_library/`
- Improve or translate Skill modules
- Add new checklists
- Share replication examples

## 📄 License

MIT License — free to use, modify, and distribute.
