# ==============================================================================
# 13_synth_did.R — Synthetic DID (Arkhangelsky et al. 2021)
# Uses: synthdid — OFFICIAL package by the authors (Stanford/Google)
# Reference: AER 2021
# ==============================================================================

source("00_shared_dgp.R")
library(synthdid)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# Synthetic DID (OFFICIAL synthdid package)
# ═══════════════════════════════════════════════════════════
# synthdid requires a panel matrix format
# and a single treatment time, so we use a simplified setup

# For demo: use cohort 10 as treated, rest as control, treat at t=10
df_sub <- df[df$gvar %in% c(0, 10), ] # cohort 10 + never-treated
df_sub$treated <- as.integer(df_sub$gvar == 10 & df_sub$t >= 10)

# Reshape to wide panel matrix
Y_wide <- reshape(df_sub[, c("i", "t", "Y")],
    idvar = "i", timevar = "t", direction = "wide"
)
Y_mat <- as.matrix(Y_wide[, -1])
rownames(Y_mat) <- Y_wide$i

# Treatment indicator matrix
W_wide <- reshape(df_sub[, c("i", "t", "treated")],
    idvar = "i", timevar = "t", direction = "wide"
)
W_mat <- as.matrix(W_wide[, -1])

# Setup
setup <- panel.matrices(Y_mat, W_mat)

# Estimate
tau_sdid <- synthdid_estimate(setup$Y, setup$N0, setup$T0)

cat("═══ Synthetic DID (2021) ═══\n")
cat(sprintf("  SDID estimate: %.4f\n", tau_sdid))
cat(sprintf("  SE: %.4f\n", attr(tau_sdid, "se")))

# Plot
dir.create("output", showWarnings = FALSE)
png("output/13_synthdid.png", width = 1200, height = 800, res = 150)
plot(tau_sdid, main = "Synthetic DID (Arkhangelsky et al. 2021)")
dev.off()
cat("  Saved: output/13_synthdid.png\n")

cat("\n📌 synthdid combines DID + SCM. Official package by Athey et al.\n")
cat("   Best for: few treated units, questionable parallel trends.\n")
