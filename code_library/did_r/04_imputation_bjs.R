# ==============================================================================
# 04_imputation_bjs.R — Borusyak, Jaravel & Spiess (2024)
# Uses: didimputation::did_imputation() — OFFICIAL package
# Reference: ReStud 2024
# ==============================================================================

source("00_shared_dgp.R")
library(didimputation)
library(fixest)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# BJS Imputation (OFFICIAL didimputation package)
# ═══════════════════════════════════════════════════════════
est <- did_imputation(
    data          = df,
    yname         = "Y",
    gname         = "Ei_na", # first treatment (NA for never-treated)
    tname         = "t",
    idname        = "i",
    horizon       = 0:5, # post-treatment periods
    pretrends     = -5:-1 # pre-treatment periods to test
)

cat("═══ BJS Imputation (2024) ═══\n")
print(est)

# Plot
dir.create("output", showWarnings = FALSE)
png("output/04_bjs.png", width = 1200, height = 800, res = 150)
plot(est, main = "BJS Imputation (2024)")
dev.off()
cat("  Saved: output/04_bjs.png\n")

cat("\n📌 didimputation is Borusyak's OWN R package.\n")
cat("   Imputes Y(0) from untreated obs, then τ = Y - Ŷ(0).\n")
