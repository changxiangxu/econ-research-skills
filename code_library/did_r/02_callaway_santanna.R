# ==============================================================================
# 02_callaway_santanna.R — Callaway & Sant'Anna (2021)
# Uses: did::att_gt() — THE OFFICIAL R PACKAGE by the authors
# Reference: JoE 2021
# ==============================================================================

source("00_shared_dgp.R")
library(did)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# CS Estimation (OFFICIAL did package)
# ═══════════════════════════════════════════════════════════
# att_gt() estimates ATT(g,t) for every group g and time t
out <- att_gt(
    yname = "Y", # outcome
    tname = "t", # time period
    idname = "i", # unit id
    gname = "gvar", # first treatment period (0 = never-treated)
    data = df,
    control_group = "nevertreated" # or "notyettreated"
)

cat("═══ Callaway-Sant'Anna ATT(g,t) ═══\n")
summary(out)

# ═══════════════════════════════════════════════════════════
# Aggregation: Event Study
# ═══════════════════════════════════════════════════════════
es <- aggte(out, type = "dynamic")
cat("\n═══ CS Event Study ═══\n")
summary(es)

# Plot
ggdid(es, title = "Callaway-Sant'Anna (2021)")

# Save
dir.create("output", showWarnings = FALSE)
png("output/02_cs.png", width = 1200, height = 800, res = 150)
ggdid(es, title = "Callaway-Sant'Anna (2021)")
dev.off()
cat("  Saved: output/02_cs.png\n")

# ═══════════════════════════════════════════════════════════
# Other Aggregations
# ═══════════════════════════════════════════════════════════
# Simple ATT (overall average)
simple <- aggte(out, type = "simple")
cat("\n═══ Simple ATT ═══\n")
summary(simple)

# Group ATT (by cohort)
group <- aggte(out, type = "group")
cat("\n═══ Group ATT ═══\n")
summary(group)

# Calendar ATT (by calendar time)
calendar <- aggte(out, type = "calendar")
cat("\n═══ Calendar ATT ═══\n")
summary(calendar)

cat("\n📌 CS first estimates ATT(g,t) for every group×time,")
cat("\n   then aggregates flexibly. No contamination.\n")
