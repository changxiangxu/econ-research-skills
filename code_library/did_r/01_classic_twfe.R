# ==============================================================================
# 01_classic_twfe.R — Classic Two-Way Fixed Effects
# Uses: fixest::feols()
# 📌 TWFE is BIASED with heterogeneous effects — this demonstrates the bias.
# ==============================================================================

source("00_shared_dgp.R")
library(fixest)

df <- generate_did_data()
true_att <- compute_true_effects(df)

# ═══════════════════════════════════════════════════════════
# Static TWFE: Y ~ D | i + t
# ═══════════════════════════════════════════════════════════
est_static <- feols(Y ~ D | i + t, data = df, cluster = ~i)
cat("═══ TWFE Static ═══\n")
summary(est_static)
cat(sprintf("\n  TWFE ATT = %.4f\n", coef(est_static)["D"]))
cat(sprintf("  True avg ATT = %.4f\n", mean(true_att)))
cat("  📌 TWFE is BIASED due to heterogeneous treatment effects!\n")

# ═══════════════════════════════════════════════════════════
# Event Study TWFE: Y ~ i(K, ref = -1) | i + t
# ═══════════════════════════════════════════════════════════
# Trim K to [-5, 5] for cleaner plot
df$K_trim <- pmax(pmin(df$K, 5), -5)
df$K_trim[is.na(df$K)] <- -1 # never-treated → reference

est_es <- feols(Y ~ i(K_trim, ref = -1) | i + t, data = df, cluster = ~i)
cat("\n═══ TWFE Event Study ═══\n")
summary(est_es)

# Plot
iplot(est_es,
    main = "TWFE OLS Event Study (BIASED)",
    xlab = "Periods since treatment", ylab = "OLS coefficient"
)
abline(h = 0, lty = 2, col = "gray")

# Save
png("output/01_twfe.png", width = 1200, height = 800, res = 150)
iplot(est_es,
    main = "TWFE OLS Event Study (BIASED)",
    xlab = "Periods since treatment", ylab = "OLS coefficient"
)
abline(h = 0, lty = 2, col = "gray")
dev.off()
cat("\n  Saved: output/01_twfe.png\n")
