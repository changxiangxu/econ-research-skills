# 🔗 Curated GitHub Repositories for Empirical Economics

Organized by research stage. All free and open-source.

---

## 🏗️ Project Templates (Fork One to Start!)

| Repository | Language | Description |
|-----------|----------|-------------|
| [OpenSourceEconomics/econ-project-templates](https://github.com/OpenSourceEconomics/econ-project-templates) | Multi | **Best-in-class** reproducible research template with Snakemake workflow, auto-tables, one-click replication |
| [lachlandeer/snakemake-econ-r](https://github.com/lachlandeer/snakemake-econ-r) | R | Snakemake pipeline for R-based research projects |
| [trr266/trer](https://github.com/trr266/trer) | R | TRR 266 reproducible empirical research template |
| [aeturrell/coding-for-economists](https://github.com/aeturrell/coding-for-economists) | Python | Complete coding guide with project structure for economists |

---

## ⚗️ Causal Inference Textbook Code

| Repository | Book | Languages |
|-----------|------|-----------|
| [scunning1975/mixtape](https://github.com/scunning1975/mixtape) | *Causal Inference: The Mixtape* | Stata/R/Python |
| [NickCH-K/causaldata](https://github.com/NickCH-K/causaldata) | All example datasets (Mixtape + The Effect + What If) | R/Stata/Python |
| [vikjam/mostly-harmless-replication](https://github.com/vikjam/mostly-harmless-replication) | *Mostly Harmless Econometrics* full replication | Stata/R/Python/Julia |
| [NickCH-K/TheEffectAssignments](https://github.com/NickCH-K/TheEffectAssignments) | *The Effect* assignments + DAG code | R |
| [matheusfacure/python-causality-handbook](https://github.com/matheusfacure/python-causality-handbook) | Python Causal Inference Handbook | Python |

---

## 📐 DID Methods — Official Implementations

| Repository | Method | Author | Language |
|-----------|--------|--------|----------|
| [bcallaway11/did](https://github.com/bcallaway11/did) | Callaway & Sant'Anna (2021) | Brantly Callaway | R |
| [friosavila/csdid](https://github.com/friosavila/csdid) | Callaway & Sant'Anna for Stata | Fernando Rios-Avila | Stata |
| [lsun20/eventstudyinteract](https://github.com/lsun20/eventstudyinteract) | Sun & Abraham (2021) | Liyang Sun | Stata |
| [borusyak/did_imputation](https://github.com/borusyak/did_imputation) | Borusyak, Jaravel & Spiess (2024) | Kirill Borusyak | Stata/R |
| [kylebutts/did2s](https://github.com/kylebutts/did2s) | Gardner Two-Stage DID | Kyle Butts | R/Stata |
| [chaisemartinDehwordfeuille/did_multiplegt](https://github.com/chaisemartinDehwordfeuille/did_multiplegt) | de Chaisemartin & D'Haultfœuille (2020) | Authors | Stata/R |
| [asheshrambachan/HonestDiD](https://github.com/asheshrambachan/HonestDiD) | Rambachan & Roth (2023) sensitivity | Ashesh Rambachan | R/Stata |
| [pedrohcgs/CS_RR](https://github.com/pedrohcgs/CS_RR) | CS + Rambachan-Roth extension | Pedro Sant'Anna | R |

---

## 📊 DID Workshop Materials

| Repository | Content |
|-----------|---------|
| [Mixtape-Sessions](https://github.com/Mixtape-Sessions) | Scott Cunningham's DID workshop — full slides + code + exercises |

---

## 🔎 Resource Collections

| Repository | Description |
|-----------|-------------|
| [matteocourthoud/awesome-causal-inference](https://github.com/matteocourthoud/awesome-causal-inference) | **Most comprehensive** causal inference resource list (books, papers, code, courses) |
| [ledwindra/replication-code-economics](https://github.com/ledwindra/replication-code-economics) | Index of top journal (AER/QJE/JPE/REStud) replication packages on GitHub |

---

## 💡 How to Use These Repos

### Starting a New Project
1. **Fork** [econ-project-templates](https://github.com/OpenSourceEconomics/econ-project-templates)
2. Replace their example code with your analysis scripts
3. Follow the folder structure → instant reproducibility

### Learning a Method
1. Clone [scunning1975/mixtape](https://github.com/scunning1975/mixtape) or [vikjam/mostly-harmless-replication](https://github.com/vikjam/mostly-harmless-replication)
2. Find the chapter for your method
3. Run the code with example data → understand the mechanics
4. Adapt to your own data

### Running Modern DID
1. Install the package: `ssc install csdid` (Stata) or `install.packages("did")` (R)
2. Clone the official repo for vignettes and examples
3. Follow the vignette step-by-step with your data
4. Add HonestDiD sensitivity analysis
