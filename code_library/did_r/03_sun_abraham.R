# ==============================================================================
# 03_sun_abraham.R — Sun & Abraham (2021)
# Uses: fixest::sunab() — built into fixest (THE standard)
# Reference: JoE 2021
# ==============================================================================

source("00_shared_dgp.R")
library(fixest)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# Sun-Abraham via fixest::sunab()
# ═══════════════════════════════════════════════════════════
# sunab(cohort, period) inside feols formula
est <- feols(Y ~ sunab(Ei, t) | i + t, data = df, cluster = ~i)

cat("═══ Sun-Abraham (2021) ═══\n")
summary(est)

# Plot
iplot(est,
    main = "Sun-Abraham (2021) via fixest::sunab()",
    xlab = "Periods since treatment", ylab = "Average causal effect"
)
abline(h = 0, lty = 2, col = "gray")

# Save
dir.create("output", showWarnings = FALSE)
png("output/03_sa.png", width = 1200, height = 800, res = 150)
iplot(est,
    main = "Sun-Abraham (2021) via fixest::sunab()",
    xlab = "Periods since treatment", ylab = "Average causal effect"
)
abline(h = 0, lty = 2, col = "gray")
dev.off()
cat("  Saved: output/03_sa.png\n")

# Aggregated ATT
agg <- summary(est, agg = "ATT")
cat("\n═══ Aggregated ATT ═══\n")
print(agg)

cat("\n📌 fixest::sunab() is the easiest way to run SA in R.\n")
cat("   One line: feols(Y ~ sunab(Ei, t) | i + t)\n")
