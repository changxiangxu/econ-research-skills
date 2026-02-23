# 📋 Robustness Checks Checklist

A minimum of **5 robustness checks** is expected for any empirical paper. Top journals often expect 8-15.

---

## 🔴 Core Robustness Checks (Minimum 5)

### 1. Alternative Variable Definitions
- [ ] **Replace dependent variable** with alternative measure
  - e.g., `ln(investment)` → `investment/assets` ratio
- [ ] **Replace key explanatory variable** with alternative measure
  - e.g., binary treatment → continuous treatment intensity

### 2. Alternative Sample
- [ ] **Winsorization**: Compare 1% vs 5% winsorization
  - Stata: `winsor2 y, cuts(1 99) replace`
- [ ] **Exclude special observations**: Drop specific regions/industries/years
  - e.g., exclude municipalities, exclude financial sector
- [ ] **Change sample window**: ±1 or ±2 years around treatment
- [ ] **Exclude policy transition year**: Drop the year of policy implementation

### 3. Alternative Specification
- [ ] **Change fixed effects**: e.g., firm+year FE → firm+industry×year FE
- [ ] **Change clustering level**: e.g., `cluster(firm)` → `cluster(city)` → `cluster(province)`
- [ ] **Bootstrap standard errors**: `bootstrap, rep(500) cluster(city)`

### 4. Placebo Tests
- [ ] **Randomize treatment group** (Permutation / Fisher exact test): 500 random reassignments
- [ ] **Fake treatment timing**: Pretend policy enacted 2-3 years earlier

### 5. Coefficient Stability
- [ ] **Oster (2019) bounds**: Report δ — if δ > 1, result is robust to omitted variables
  - Stata: `psacalc delta y d, rmax(1.3)`
  - R: `oster` package

---

## 🟡 Recommended Additional Checks

### 6. Alternative Estimator
- [ ] Use different DID estimator: `csdid` vs `did_imputation` vs `eventstudyinteract`
- [ ] OLS vs Poisson for count/non-negative outcomes
- [ ] LPM vs Probit/Logit for binary outcomes

### 7. Confound Exclusion
- [ ] **Control for concurrent policies**: Add dummy variables for other policies enacted nearby
- [ ] **Add region/industry time trends**: `absorb(region#c.year)` or `i.region#c.year`

### 8. Subsample Stability
- [ ] **Leave-one-out**: Drop each province/industry one at a time
- [ ] **Split by time period**: Pre-2010 vs post-2010 (or similar)
- [ ] **Balanced panel only**: Restrict to firms observed in all years

### 9. Functional Form
- [ ] **Log vs Level**: Compare `ln(y)` vs `y`
- [ ] **Quadratic terms**: Test for non-linear effects
- [ ] **Alternative lag structure**: Use different lag lengths

### 10. Measurement
- [ ] **Alternative data source**: If available, replicate with different database
- [ ] **Multiple imputation**: For missing data, compare deletion vs imputation

---

## Quick Summary Table Template

Use this format to present robustness checks:

```markdown
| # | Test | Specification Change | Core β | Sig. | Consistent? |
|---|------|---------------------|--------|------|-------------|
| 1 | Winsorize 5% | Top/bottom 5% | 0.045 | *** | ✅ |
| 2 | Alt. dep. var | Investment/assets | 0.032 | ** | ✅ |
| 3 | Excl. municipalities | Drop Beijing/Shanghai/Tianjin/Chongqing | 0.048 | *** | ✅ |
| 4 | Province×Year FE | Replace Year FE | 0.041 | *** | ✅ |
| 5 | Cluster at province | Province-level clustering | 0.047 | ** | ✅ |
| 6 | Oster δ | δ = 2.3 > 1 | — | — | ✅ |
| 7 | Placebo (t-3) | Fake timing | 0.003 | n.s. | ✅ |
| 8 | CS estimator | Callaway-Sant'Anna | 0.039 | *** | ✅ |
```
