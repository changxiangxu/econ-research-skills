# ==============================================================================
# 07_honestdid.R — Rambachan & Roth (2023) Sensitivity Analysis
# Uses: HonestDiD — OFFICIAL package by the authors
# Reference: ReStud 2023
# ==============================================================================

source("00_shared_dgp.R")
library(fixest)
library(HonestDiD)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# Step 1: Get event study estimates (using fixest)
# ═══════════════════════════════════════════════════════════
df$K_trim <- pmax(pmin(df$K, 5), -5)
df$K_trim[is.na(df$K)] <- -1

est <- feols(Y ~ i(K_trim, ref = -1) | i + t, data = df, cluster = ~i)

# ═══════════════════════════════════════════════════════════
# Step 2: HonestDiD sensitivity analysis
# ═══════════════════════════════════════════════════════════
# Extract coefficients and variance-covariance matrix
betahat <- coef(est)
sigma <- vcov(est)

# Identify pre and post periods
pre_indices <- grep("K_trim::-", names(betahat))
post_indices <- grep("K_trim::[0-9]", names(betahat))

# Sensitivity analysis: relative magnitudes
delta_rm <- createSensitivityResults_relativeMagnitudes(
    betahat        = betahat,
    sigma          = sigma,
    numPrePeriods  = length(pre_indices),
    numPostPeriods = length(post_indices),
    Mbarvec        = seq(0, 2, by = 0.5)
)

cat("═══ HonestDiD Sensitivity (Relative Magnitudes) ═══\n")
print(delta_rm)

# Plot
dir.create("output", showWarnings = FALSE)
png("output/07_honestdid.png", width = 1200, height = 800, res = 150)
createSensitivityPlot_relativeMagnitudes(delta_rm,
    originalResults = constructOriginalCS(betahat, sigma,
        numPrePeriods = length(pre_indices),
        numPostPeriods = length(post_indices)
    )
)
dev.off()
cat("  Saved: output/07_honestdid.png\n")

cat("\n📌 HonestDiD tests: 'How badly can parallel trends be violated")
cat("\n   before my results break?' Essential for robustness.\n")
