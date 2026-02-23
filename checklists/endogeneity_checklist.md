# 📋 Endogeneity Testing Checklist

Use this checklist for every empirical paper. Check off each test as you complete it.

---

## 🔴 Required Tests (Must-Have)

### Placebo Tests
- [ ] **Fake Treatment Timing**: Assume policy enacted N periods earlier/later → coefficient should be insignificant
- [ ] **Fake Treatment Group**: Assign treatment to a group that shouldn't be affected → coefficient should be insignificant
- [ ] **Fake Outcome Variable**: Use an outcome that shouldn't be affected by treatment → coefficient should be insignificant

### Pre-Trend Tests
- [ ] **Event Study Plot**: Pre-treatment coefficients ≈ 0 (visually and statistically)
- [ ] **Joint F-test**: All pre-treatment coefficients jointly equal zero (p > 0.10)
- [ ] **No Anticipation Check**: No significant effects 1-2 periods before treatment

---

## 🟡 Recommended Tests

### Bacon Decomposition (if Staggered DID)
- [ ] Run `bacondecomp` (Stata) or `bacon()` (R)
- [ ] Check if 2×2 DID sub-components have consistent signs
- [ ] Report the share of "bad comparisons" (late-to-early treated)

### IV Tests (if using Instrumental Variables)
- [ ] **Weak Instrument Test**: First-stage F-statistic > 10 (Stock & Yogo, 2005)
- [ ] **Over-identification Test**: Hansen J / Sargan test (if multiple instruments)
- [ ] **Exclusion Restriction Argument**: Written narrative for why instrument only affects Y through D
- [ ] **Reduced Form**: Report reduced-form regression (Z → Y directly)

### Selection Bias Tests
- [ ] **Heckman Two-Step** (if sample selection present): First-stage Probit + second-stage correction
- [ ] **PSM-DID**: Propensity score matching then DID, report post-matching balance tests
- [ ] **Covariate Balance Test**: Compare treatment and control group pre-treatment characteristics

---

## 🟢 Bonus Tests (Impressive to Referees)

### Sensitivity Analysis
- [ ] **HonestDiD** (Rambachan & Roth, 2023): Robustness to violations of parallel trends
  - Stata: `honestdid` | R: `HonestDiD` package
- [ ] **Oster (2019) Coefficient Stability**: Bounds on bias from unobservables
  - Stata: `psacalc delta y d` | R: `oster` package
  - Report δ (delta) — if δ > 1, results are robust

### Other
- [ ] **Leave-One-Out Test**: Drop each province/industry/year one at a time; check stability
- [ ] **Permutation Test / Fisher Exact Test**: 500+ random reassignments of treatment
- [ ] **Randomization Inference**: Exact p-values under sharp null

---

## Quick Reference: Endogeneity Sources

| Source | How to Detect | Solution |
|--------|--------------|----------|
| Omitted Variable Bias | Oster δ, added controls change β significantly | Add controls / FE / IV |
| Reverse Causality | Theory + timing argument | IV / lagged D / DID |
| Sample Selection | Heckman test, attrition analysis | Heckman / bounds |
| Measurement Error | Reliability analysis, multiple indicators | IV / SIMEX |
| Simultaneity | Theory | Structural equations / IV |

---

## Stata Quick Commands

```stata
* Placebo test (fake timing)
gen fake_post = (year >= 2008)  // actual policy: 2010
reghdfe y treat#fake_post controls, absorb(id year) cluster(city)

* Event study
reghdfe y lead3 lead2 lag0 lag1 lag2 lag3 controls, absorb(id year) cluster(city)
coefplot, keep(lead* lag*) vertical yline(0)

* Oster bounds
psacalc delta y d, controls(x1 x2 x3) rmax(1.3)

* Bacon decomposition
bacondecomp y d, ddetail
```
