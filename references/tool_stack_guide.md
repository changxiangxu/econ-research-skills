# 🛠️ Stata / R / Python: Selection & Setup Guide

> Choose your primary tool, then set it up for reproducible research.

---

## Decision Tree: Which Should I Use?

```
What is your situation?
│
├── PhD student at a Chinese university?
│   └── ✅ Stata (most supervisors use it, most Chinese journals accept it)
│       + Learn R as secondary (for graphs and modern DID packages)
│
├── PhD student at a US/EU university?
│   └── ✅ R (free, most modern methods available first in R)
│       + Stata as secondary (for replication of Chinese papers)
│
├── Working with very large data (>10GB)?
│   └── ✅ Python (pandas + dask for big data)
│       + Stata/R for final regressions
│
├── Want the fastest path to a first paper?
│   └── ✅ Stata (shortest learning curve for regressions)
│
└── Not sure?
    └── ✅ Start with Stata, add R later
```

---

## Head-to-Head Comparison

| Dimension | Stata | R | Python |
|-----------|-------|---|--------|
| **Learning Curve** | ⭐ Easiest | ⭐⭐ Medium | ⭐⭐⭐ Steepest |
| **Cost** | 💰 Paid ($125-$595/yr student) | Free | Free |
| **Regression** | ⭐⭐⭐ Best (`reghdfe`, `estout`) | ⭐⭐⭐ Excellent (`fixest`, `modelsummary`) | ⭐⭐ Good (`linearmodels`, `statsmodels`) |
| **Modern DID** | ⭐⭐⭐ All methods available | ⭐⭐⭐ All methods available (often first) | ⭐⭐ Most available |
| **IV/RDD** | ⭐⭐⭐ `ivreg2`, `rdrobust` | ⭐⭐⭐ `ivreg`, `rdrobust` | ⭐⭐ `linearmodels` |
| **Graphs** | ⭐⭐ Decent | ⭐⭐⭐ Best (`ggplot2`) | ⭐⭐⭐ Best (`matplotlib`, `seaborn`) |
| **Tables** | ⭐⭐⭐ `esttab` → LaTeX | ⭐⭐⭐ `modelsummary` → LaTeX | ⭐⭐ `stargazer` |
| **Data Cleaning** | ⭐⭐ Good | ⭐⭐⭐ Excellent (`dplyr`) | ⭐⭐⭐ Excellent (`pandas`) |
| **Big Data** | ⭐ Limited (RAM) | ⭐⭐ Medium (`data.table`) | ⭐⭐⭐ Best (`dask`, `polars`) |
| **Job Market** | Academia (China) | Academia (US/EU) | Industry + Tech |
| **Replication** | Most Chinese papers | Most US/EU papers | Growing |
| **Community** | 连享会, Statalist | StackOverflow, RStudio | StackOverflow, GitHub |

---

## Stata Setup

### Installation
1. Purchase from [stata.com](https://www.stata.com/) (student price ~$125/year for SE)
2. **Recommended version**: Stata/SE 17+ (supports `reghdfe`, `csdid`, etc.)
3. Stata/MP if your data > 5GB or you need speed

### Essential Packages (Run Once)
```stata
* ─── Core Regression ─────────────────────────────
ssc install reghdfe, replace       // Multi-way FE regression (THE standard)
ssc install ftools, replace        // Required by reghdfe
ssc install estout, replace        // Export tables to LaTeX/Word/CSV

* ─── DID Methods ────────────────────────────────
ssc install csdid, replace         // Callaway & Sant'Anna (2021)
ssc install drdid, replace         // Doubly-robust DID (required by csdid)
ssc install did_imputation, replace // Borusyak, Jaravel & Spiess (2024)
ssc install eventstudyinteract, replace // Sun & Abraham (2021)
ssc install did_multiplegt, replace // de Chaisemartin & D'Haultfœuille (2020)
ssc install bacondecomp, replace   // Goodman-Bacon decomposition
ssc install event_plot, replace    // Event study plotting
ssc install did2s, replace         // Gardner two-stage DID
ssc install honestdid, replace     // Rambachan & Roth sensitivity

* ─── IV & RDD ───────────────────────────────────
ssc install ivreg2, replace        // Enhanced 2SLS
ssc install ranktest, replace      // Required by ivreg2
ssc install rdrobust, replace      // RDD: MSE-optimal bandwidth
ssc install rddensity, replace     // McCrary density test
ssc install rdlocrand, replace     // RDD local randomization

* ─── Data Cleaning ──────────────────────────────
ssc install winsor2, replace       // Winsorization
ssc install distinct, replace      // Count distinct values
ssc install mdesc, replace         // Missing data diagnostics

* ─── Graphs ─────────────────────────────────────
ssc install coefplot, replace      // Coefficient plots
ssc install grstyle, replace       // Graph style customization
ssc install palettes, replace      // Color palettes
ssc install colrspace, replace     // Required by palettes
ssc install blindschemes, replace  // Colorblind-friendly schemes

* ─── Other Useful ───────────────────────────────
ssc install outreg2, replace       // Alternative table export
ssc install psacalc, replace       // Oster (2019) bounds
ssc install psmatch2, replace      // Propensity score matching
ssc install avar, replace          // Heteroskedasticity-robust variance
```

### Recommended Settings (Add to `profile.do`)
```stata
* File: C:\ado\profile.do (Windows) or ~/ado/profile.do (Mac/Linux)
* This runs automatically every time you open Stata

set more off, permanently          // Never pause output
set maxvar 32767, permanently      // Max variables (SE/MP only)
set matsize 11000, permanently     // Larger matrix size
set scheme s2color, permanently    // Clean graph scheme
```

### Verify Installation
```stata
* Run this to check all packages are installed:
which reghdfe
which csdid
which rdrobust
which coefplot
di "✅ All packages installed!"
```

---

## R Setup

### Installation
1. Install R from [r-project.org](https://www.r-project.org/)
2. Install RStudio from [posit.co](https://posit.co/download/rstudio-desktop/)
3. Both are **free**

### Essential Packages
```r
# ─── Core ──────────────────────────────────────
install.packages(c(
  "fixest",          # Fast FE regression (fastest in R!)
  "modelsummary",    # Beautiful regression tables
  "broom",           # Tidy regression output
  "sandwich",        # Robust standard errors
  "lmtest"           # Hypothesis testing
))

# ─── DID Methods ──────────────────────────────
install.packages(c(
  "did",             # Callaway & Sant'Anna (2021)
  "did2s",           # Gardner two-stage DID
  "HonestDiD",       # Rambachan & Roth sensitivity
  "bacondecomp",     # Goodman-Bacon decomposition
  "staggered"        # Roth & Sant'Anna staggered DID
))

# ─── IV & RDD ─────────────────────────────────
install.packages(c(
  "ivreg",           # Instrumental variables
  "rdrobust",        # RDD: MSE-optimal bandwidth
  "rddensity",       # McCrary density test
  "rdlocrand"        # RDD local randomization
))

# ─── Data Wrangling ───────────────────────────
install.packages(c(
  "tidyverse",       # dplyr + ggplot2 + tidyr + readr + ...
  "haven",           # Read .dta files
  "data.table",      # Fast data manipulation
  "janitor"          # Data cleaning utilities
))

# ─── Graphs ───────────────────────────────────
install.packages(c(
  "ggplot2",         # (included in tidyverse)
  "ggthemes",        # Extra themes
  "patchwork",       # Combine plots
  "scales"           # Axis formatting
))

# ─── Reproducibility ─────────────────────────
install.packages(c(
  "renv",            # Project-level package management
  "here",            # Relative paths that just work
  "quarto"           # Reproducible documents
))
```

### Verify Installation
```r
# Run this to check:
library(fixest)
library(did)
library(rdrobust)
cat("✅ All packages installed!\n")
```

---

## Python Setup

### Installation
1. Install from [python.org](https://www.python.org/) (Python 3.10+)
2. Or install [Anaconda](https://www.anaconda.com/) (includes everything)
3. IDE: VS Code (free) or Jupyter Notebook

### Essential Packages
```bash
pip install pandas numpy scipy statsmodels linearmodels
pip install matplotlib seaborn plotly
pip install stargazer pyfixest
pip install rdrobust
pip install jupyter notebook
```

### Verify Installation
```python
import pandas as pd
import statsmodels.api as sm
import linearmodels as lm
print("✅ All packages installed!")
```

---

## Our Recommendation

> **For this skills package, all code examples are provided in Stata first.**
> R versions will be added as the package grows.
>
> If you only learn ONE tool: **Learn Stata.**
> If you learn TWO: **Stata + R** (use R for `ggplot2` graphs and cutting-edge DID).
> If you learn THREE: **Stata + R + Python** (add Python for big data and ML).

---

## Quick Reference: Package Equivalence Table

| Task | Stata | R | Python |
|------|-------|---|--------|
| FE Regression | `reghdfe` | `fixest::feols()` | `linearmodels.PanelOLS()` |
| Export Table | `esttab` | `modelsummary()` | `Stargazer()` |
| CS DID | `csdid` | `did::att_gt()` | `csdid` (limited) |
| Event Study | `coefplot` | `ggplot2` + manual | `matplotlib` |
| RDD | `rdrobust` | `rdrobust::rdrobust()` | `rdrobust` |
| 2SLS | `ivreg2` | `ivreg::ivreg()` | `linearmodels.IV2SLS()` |
| Winsorize | `winsor2` | `DescTools::Winsorize()` | `scipy.stats.mstats.winsorize()` |
| Read .dta | native | `haven::read_dta()` | `pd.read_stata()` |
