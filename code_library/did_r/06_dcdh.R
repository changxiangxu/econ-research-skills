# ==============================================================================
# 06_dcdh.R — de Chaisemartin & D'Haultfœuille (2020)
# Uses: DIDmultiplegt::did_multiplegt()
# Reference: AER 2020
# ==============================================================================

source("00_shared_dgp.R")
library(DIDmultiplegt)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# dCDH Estimation
# ═══════════════════════════════════════════════════════════
est <- did_multiplegt(
    df = df,
    Y = "Y",
    G = "i", # unit id
    T = "t", # time
    D = "D", # treatment
    dynamic = 5, # post-treatment periods
    placebo = 5, # pre-treatment periods
    brep = 30, # bootstrap reps
    cluster = "i" # cluster SE
)

cat("═══ dCDH (2020) ═══\n")
print(est)

cat("\n📌 dCDH adapts DID for switching (non-absorbing) treatments.\n")
cat("   R package DIDmultiplegt is from the original authors.\n")
