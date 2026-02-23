# ==============================================================================
# 15_comparison_master.R — Run all methods, produce comparison plot
# Runs: TWFE, CS, SA, BJS, Gardner on same data
# ==============================================================================

source("00_shared_dgp.R")
library(fixest)
library(did)
library(didimputation)
library(did2s)
library(ggplot2)
library(dplyr)

df <- generate_did_data()
true_att <- compute_true_effects(df)

# Add trimmed K
df$K_trim <- pmax(pmin(df$K, 5), -5)
df$K_trim[is.na(df$K)] <- -1

results <- list()

# ═══════════════════════════════════════════════════════════
# (1) TWFE OLS
# ═══════════════════════════════════════════════════════════
cat(">>> [1/5] TWFE OLS...\n")
est_twfe <- feols(Y ~ i(K_trim, ref = -1) | i + t, data = df, cluster = ~i)

# ═══════════════════════════════════════════════════════════
# (2) Sun-Abraham
# ═══════════════════════════════════════════════════════════
cat(">>> [2/5] Sun-Abraham...\n")
est_sa <- feols(Y ~ sunab(Ei, t) | i + t, data = df, cluster = ~i)

# ═══════════════════════════════════════════════════════════
# (3) Callaway-Sant'Anna
# ═══════════════════════════════════════════════════════════
cat(">>> [3/5] Callaway-Sant'Anna...\n")
out_cs <- att_gt(
    yname = "Y", tname = "t", idname = "i", gname = "gvar",
    data = df, control_group = "nevertreated"
)
es_cs <- aggte(out_cs, type = "dynamic")

# ═══════════════════════════════════════════════════════════
# (4) BJS Imputation
# ═══════════════════════════════════════════════════════════
cat(">>> [4/5] BJS Imputation...\n")
est_bjs <- did_imputation(
    data = df, yname = "Y", gname = "Ei_na",
    tname = "t", idname = "i",
    horizon = 0:5, pretrends = -5:-1
)

# ═══════════════════════════════════════════════════════════
# (5) Gardner did2s
# ═══════════════════════════════════════════════════════════
cat(">>> [5/5] Gardner did2s...\n")
est_did2s <- did2s(
    data = df, yname = "Y",
    first_stage = ~ 0 | i + t,
    second_stage = ~ i(K_trim, ref = -1),
    treatment = "D", cluster_var = "i"
)

# ═══════════════════════════════════════════════════════════
# COMBINED COMPARISON PLOT
# ═══════════════════════════════════════════════════════════
cat("\n>>> Building comparison plot...\n")

# Use fixest's built-in comparison plot
dir.create("output", showWarnings = FALSE)

png("output/00_comparison.png", width = 1600, height = 1000, res = 150)
iplot(
    list(
        "TWFE OLS" = est_twfe, "Sun-Abraham" = est_sa,
        "Gardner did2s" = est_did2s
    ),
    main = "DID Estimator Comparison (400 units, 15 periods)\nSame Borusyak DGP with heterogeneous τ = t − Ei",
    xlab = "Periods since treatment",
    ylab = "Average causal effect",
    ref.line = 0
)
dev.off()
cat("  Saved: output/00_comparison.png\n")

# Summary table
cat("\n═══════════════════════════════════════════\n")
cat("  COMPARISON SUMMARY\n")
cat("═══════════════════════════════════════════\n")
cat(sprintf("  True ATT: %s\n", paste(round(true_att, 3), collapse = ", ")))
cat(sprintf("  TWFE:     %s\n", paste(round(coef(est_twfe)[1:6], 3), collapse = ", ")))
cat(sprintf("  SA:       %s\n", paste(round(coef(est_sa)[1:6], 3), collapse = ", ")))
cat(sprintf("  Gardner:  %s\n", paste(round(coef(est_did2s)[1:6], 3), collapse = ", ")))

cat("\n📌 Robust methods should be close to true values.\n")
cat("   TWFE OLS should show visible bias.\n")
cat("\n  ALL DONE!\n")
