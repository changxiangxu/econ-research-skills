# ==============================================================================
# 05_bacon_decomposition.R — Goodman-Bacon (2021)
# Uses: bacondecomp::bacon() — OFFICIAL package
# Reference: JoE 2021
# ==============================================================================

source("00_shared_dgp.R")
library(bacondecomp)
library(ggplot2)

df <- generate_did_data()

# ═══════════════════════════════════════════════════════════
# Bacon Decomposition (OFFICIAL bacondecomp package)
# ═══════════════════════════════════════════════════════════
bacon_out <- bacon(Y ~ D, data = df, id_var = "i", time_var = "t")

cat("═══ Bacon Decomposition (2021) ═══\n")
print(bacon_out)

# Summary by type
cat("\nSummary by comparison type:\n")
agg <- aggregate(cbind(estimate, weight) ~ type, data = bacon_out, FUN = mean)
print(agg)

# TWFE coefficient = weighted sum
twfe_coef <- sum(bacon_out$estimate * bacon_out$weight)
cat(sprintf("\nTWFE coefficient (weighted sum) = %.4f\n", twfe_coef))

# Plot
dir.create("output", showWarnings = FALSE)
p <- ggplot(bacon_out, aes(x = weight, y = estimate, color = type)) +
    geom_point(size = 3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray") +
    labs(
        title = "Bacon Decomposition: TWFE = weighted sum of 2×2 DDs",
        x = "Weight", y = "2×2 DD Estimate", color = "Comparison Type"
    ) +
    theme_minimal(base_size = 14)

ggsave("output/05_bacon.png", p, width = 10, height = 6, dpi = 150)
cat("  Saved: output/05_bacon.png\n")

cat("\n📌 If 'Later vs Earlier' has large weight → TWFE is biased.\n")
cat("   Always run Bacon as a diagnostic FIRST.\n")
