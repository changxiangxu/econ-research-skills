# 📖 Textbook Chapter Index & Frontier Papers

A quick-reference guide to find the right chapter for any method.

---

## 🟢 Introductory Level

### Angrist & Pischke — *Mastering 'Metrics* (2014)

| Chapter | Topic | When to Consult |
|---------|-------|-----------------|
| Ch.1 | Randomized Controlled Trials | Understanding the gold standard |
| Ch.2 | Regression | When OLS has causal interpretation |
| Ch.3 | Instrumental Variables | IV intuition and LATE |
| Ch.4 | Regression Discontinuity | Sharp and Fuzzy RD |
| Ch.5 | Difference-in-Differences | Basic DID logic |

---

## 🟡 Intermediate Level

### Angrist & Pischke — *Mostly Harmless Econometrics* (2009)

| Chapter | Topic | When to Consult |
|---------|-------|-----------------|
| Ch.2 | Conditional Independence Assumption | Causal interpretation of regression |
| Ch.3 | Making Regression Make Sense | Control strategies, bad controls |
| Ch.4 | Instrumental Variables in Action | 2SLS, weak instruments, LATE |
| Ch.5 | Panel Data and DID | FE vs FD, parallel trends |
| Ch.6 | Regression Discontinuity | Sharp vs Fuzzy, bandwidth |
| Ch.8 | Nonlinear Models | Marginal effects, Logit/Probit |

### Cunningham — *Causal Inference: The Mixtape* (2021) — [Free Online](https://mixtape.scunning.com/)

| Chapter | Topic | When to Consult |
|---------|-------|-----------------|
| Ch.3 | Directed Acyclic Graphs (DAG) | Causal pathway visualization |
| Ch.4 | Potential Outcomes | Treatment effects framework |
| Ch.5 | Matching & Subclassification | PSM theory and practice |
| Ch.7 | Instrumental Variables | LATE, homogeneity, exclusion |
| Ch.8 | Regression Discontinuity | Bandwidth, McCrary, donut-hole |
| Ch.9 | Difference-in-Differences | Classic + modern DID methods |
| Ch.10 | Synthetic Control | SCM for few treated units |

### Huntington-Klein — *The Effect* (2022) — [Free Online](https://theeffectbook.net/)

| Chapter | Topic | When to Consult |
|---------|-------|-----------------|
| Part II | Research Design | Design-based thinking |
| Ch.16 | Fixed Effects | FE intuition and practice |
| Ch.18 | Difference-in-Differences | Including modern DID |
| Ch.19 | Regression Discontinuity | Practical implementation |
| Ch.20 | Instrumental Variables | Practical implementation |
| All | R Code | All methods come with R examples |

---

## 🔴 Advanced / Reference

### Imbens & Rubin — *Causal Inference for Statistics, Social, and Biomedical Sciences* (2015)
- Complete potential outcomes framework
- Fisher exact tests, Neyman inference
- Mathematical foundations for all methods

### Hernán & Robins — *Causal Inference: What If* (2024) — [Free PDF](https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/)
- Target trial emulation
- Time-varying treatments
- Mechanism analysis and mediation

---

## 📐 Frontier Methodological Papers

### DID Methods (Must-Cite)

| Paper | Year | Journal | Key Contribution |
|-------|------|---------|-----------------|
| Callaway & Sant'Anna | 2021 | *JoE* | Group-time ATTs for staggered treatment |
| Sun & Abraham | 2021 | *JoE* | Interaction-weighted estimator |
| Borusyak, Jaravel & Spiess | 2024 | *ReStud* | Imputation estimator |
| de Chaisemartin & D'Haultfœuille | 2020 | *AER* | TWFE bias with heterogeneous effects |
| Goodman-Bacon | 2021 | *JoE* | TWFE decomposition diagnostic |
| Roth | 2023 | *AER: Insights* | Pre-test with caution |
| Rambachan & Roth | 2023 | *ReStud* | Sensitivity analysis for parallel trends |
| Roth, Sant'Anna, Bilinski & Poe | 2023 | *JoE* | Survey of modern DID literature |
| Gardner | 2022 | *Working Paper* | Two-stage DID estimator |

### IV / RD / SCM

| Paper | Year | Journal | Key Contribution |
|-------|------|---------|-----------------|
| Andrews, Stock & Sun | 2019 | *Annu. Rev. Econ* | Weak instruments survey |
| Lee & Lemieux | 2010 | *JEL* | RD design practical guide |
| Abadie, Diamond & Hainmueller | 2010 | *JASA* | Synthetic Control Method |
| Goldsmith-Pinkham, Sorkin & Swift | 2020 | *AER* | Bartik / Shift-Share instruments |

### Sensitivity Analysis

| Paper | Year | Journal | Key Contribution |
|-------|------|---------|-----------------|
| Oster | 2019 | *JBES* | Coefficient stability bounds (δ) |
| Cinelli & Hazlett | 2020 | *JRSS-B* | Sensitivity to omitted variables |
| Altonji, Elder & Taber | 2005 | *JPE* | Selection on observables = unobservables |
