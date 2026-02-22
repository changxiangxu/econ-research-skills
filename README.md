# 📚 Econ Research Skills

> A Complete AI Skill System for Empirical Economics Research — From Topic Selection to Publication

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🎯 What Is This?

A set of AI skill instructions (Skills) designed for **economics PhD students**, covering the **entire lifecycle** of an empirical paper — from topic selection to journal submission.

Built on the methodology from Stanford CS146S *"Power Prompting for LLMs"*, leveraging System Prompts, Chain-of-Thought, and Reflexion techniques.

## 🏗️ System Architecture

```
Topic → Literature → Theory → Methods → Data → Code → Results → Writing
 🎯        📚          🏛️       ⚗️        🔧      💻      📊        ✍️
```

## 📦 Contents

### `skills/` — 8 AI Skill Modules (38 Tasks)

| Module | Tasks | Core Capabilities |
|--------|-------|-------------------|
| 🎯 [Topic_Selector](skills/Topic_Selector/) | 3 | Brainstorming · Background Brief · Feasibility Assessment |
| 📚 [Literature_Navigator](skills/Literature_Navigator/) | 4 | Deep Reading · Literature Matrix · Review Writing · Gap Identification |
| ⚗️ [Causal_Inference_Guide](skills/Causal_Inference_Guide/) | 6 | DID Encyclopedia (7 methods) · Endogeneity Tests · Robustness Checks · Textbook Index |
| 🏛️ [Theoretical_Framework](skills/Theoretical_Framework/) | 3 | Framework Recommendation · Hypothesis Development · 30+ Theory Index |
| 🔧 [Data_Pipeline](skills/Data_Pipeline/) | 5 | Data Discovery · Cleaning · Management Standards · Variable Description · Data Dictionary |
| 💻 [Code_Project_Manager](skills/Code_Project_Manager/) | 5 | Master Script · Regression Pipeline · Code Review · Replication Code |
| 📊 [Results_Manager](skills/Results_Manager/) | 5 | Results Interpretation · Heterogeneity Design · Mechanism Analysis · Table Formatting |
| ✍️ [Academic_Paper_Writer](skills/Academic_Paper_Writer/) | 7 | Drafting · Polishing · Reviewer Response · Abstract · Introduction · Conclusion · Language Refinement |

### `code_library/` — Method Code Library
- `did/` — DID Full Suite (TWFE, CS, SA, Imputation, Bacon, HonestDiD)
- `data_cleaning/` — Winsorization, Missing Values, Panel Balancing
- `tables_figures/` — Event Study Plots, Coefficient Plots, Table Export

### `templates/` — Reusable Project Templates
- `stata/` — Standard Stata Project Template (Master.do + 8 sub-files)
- `r/` — Standard R Project Template

### `references/` — Textbook & Literature Index
- Chapter-level index for 6 classic causal inference textbooks
- Frontier paper lists for DID/IV/RD methods

### `checklists/` — Ready-to-Use Checklists
- Endogeneity Testing · Robustness Checks · Pre-Submission Checklist

## 🚀 Quick Start

### Option 1: Use with AI Coding Tools
Place the `skills/` folder in your project directory. AI tools will automatically discover and follow the instructions.

### Option 2: Use as Reference Manual
Read individual `SKILL.md` files as structured guides for academic writing and research methodology.

## 📖 Recommended Textbooks

| Textbook | Author | Level | Online Resources |
|----------|--------|-------|-----------------|
| *Mastering Metrics* | Angrist & Pischke | ⭐ Intro | [Website](https://www.masteringmetrics.com/) |
| *Mostly Harmless Econometrics* | Angrist & Pischke | ⭐⭐ Intermediate | — |
| *Causal Inference: The Mixtape* | Cunningham | ⭐⭐ Intermediate | [Free Online](https://mixtape.scunning.com/) |
| *The Effect* | Huntington-Klein | ⭐⭐ Intermediate | [Free Online](https://theeffectbook.net/) |
| *Causal Inference* | Imbens & Rubin | ⭐⭐⭐ Advanced | — |

## 🤝 Contributing

Contributions via Pull Requests are welcome — whether it's code, bug fixes, or new Skill modules.

## 📄 License

MIT License — free to use, modify, and distribute.
