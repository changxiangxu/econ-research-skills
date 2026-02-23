# ==============================================================================
# 10_gardner_did2s.R — Gardner (2022) Two-Stage DID
# Uses: did2s::did2s() — OFFICIAL package by Kyle Butts
# Reference: Gardner (2022)
# ==============================================================================

source("00_shared_dgp.R")
library(did2s)
library(fixest)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# Gardner did2s (OFFICIAL package)
# ═══════════════════════════════════════════════════════════
# did2s(data, yname, first_stage, second_stage, treatment, cluster_var)
est <- did2s(
    data         = df,
    yname        = "Y",
    first_stage  = ~ 0 | i + t, # unit + time FE for counterfactual
    second_stage = ~ i(K_trim, ref = -1), # event study
    treatment    = "D",
    cluster_var  = "i"
)

# Need K_trim
df$K_trim <- pmax(pmin(df$K, 5), -5)
df$K_trim[is.na(df$K)] <- -1

est <- did2s(
    data         = df,
    yname        = "Y",
    first_stage  = ~ 0 | i + t,
    second_stage = ~ i(K_trim, ref = -1),
    treatment    = "D",
    cluster_var  = "i"
)

cat("═══ Gardner did2s (2022) ═══\n")
summary(est)

# Plot
dir.create("output", showWarnings = FALSE)
png("output/10_gardner.png", width = 1200, height = 800, res = 150)
iplot(est,
    main = "Gardner (2022) Two-Stage DID",
    xlab = "Periods since treatment", ylab = "Average causal effect"
)
abline(h = 0, lty = 2, col = "gray")
dev.off()
cat("  Saved: output/10_gardner.png\n")

# Simple ATT (single coefficient)
est_simple <- did2s(
    data         = df,
    yname        = "Y",
    first_stage  = ~ 0 | i + t,
    second_stage = ~D,
    treatment    = "D",
    cluster_var  = "i"
)
cat(sprintf("\n  Gardner ATT = %.4f\n", coef(est_simple)["D"]))

cat("\n📌 did2s is the official R package by Kyle Butts.\n")
cat("   Stage 1: estimate FE on untreated. Stage 2: regress residuals.\n")
