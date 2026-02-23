# ==============================================================================
# DID Code Library — R Version
# 00_shared_dgp.R: Shared Data Generating Process (Borusyak verified DGP)
#
# All DID methods use the SAME simulated data.
# Source: Borusyak five_estimators_example.do / wenddymacro staggered_did_13
#
# DGP: 400 units × 15 periods, Ei ~ U{10,...,16}, τ = t − Ei
# ==============================================================================

generate_did_data <- function(I = 400, T = 15, seed = 10) {
    set.seed(seed)

    # Panel structure
    df <- expand.grid(i = 1:I, t = 1:T)
    df <- df[order(df$i, df$t), ]

    # Treatment rollout: Ei ~ Uniform{10,...,16}
    unit_ei <- data.frame(
        i = 1:I,
        Ei = ceiling(runif(I) * 7) + T - 6
    )
    df <- merge(df, unit_ei, by = "i")
    df <- df[order(df$i, df$t), ]

    # Relative time and treatment indicator
    df$K <- df$t - df$Ei
    df$D <- as.integer(df$K >= 0 & !is.na(df$Ei))

    # Heterogeneous treatment effects: τ = t - Ei
    df$tau <- ifelse(df$D == 1, df$t - df$Ei, 0)

    # Outcome: Y = unit_FE + 3*t + τ*D + ε
    df$eps <- rnorm(nrow(df))
    df$Y <- df$i + 3 * df$t + df$tau * df$D + df$eps

    # Group variable (for CS): 0 for never-treated
    df$gvar <- ifelse(df$Ei > T, 0L, as.integer(df$Ei))

    # First treatment period (NA for never-treated, for did_imputation)
    df$Ei_na <- ifelse(df$Ei > T, NA, df$Ei)

    return(df)
}

compute_true_effects <- function(df, max_horizon = 5) {
    true_att <- sapply(0:max_horizon, function(h) {
        mean(df$tau[df$K == h], na.rm = TRUE)
    })
    names(true_att) <- paste0("K", 0:max_horizon)
    return(true_att)
}

# ═══════════════════════════════════════════════════════════
# Install all required packages (run once)
# ═══════════════════════════════════════════════════════════
install_all_packages <- function() {
    pkgs <- c(
        "fixest", # TWFE, Sun-Abraham
        "did", # Callaway-Sant'Anna (OFFICIAL)
        "did2s", # Gardner (OFFICIAL)
        "bacondecomp", # Bacon (OFFICIAL)
        "DIDmultiplegt", # dCDH (OFFICIAL)
        "HonestDiD", # Rambachan-Roth (OFFICIAL)
        "synthdid", # Synthetic DID (OFFICIAL, by Athey et al.)
        "didimputation", # BJS Imputation (OFFICIAL)
        "staggered", # Roth-Sant'Anna efficient estimator
        "ggplot2", # Plots
        "dplyr", # Data wrangling
        "tidyr" # Data reshaping
    )

    for (pkg in pkgs) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
            cat("Installing:", pkg, "\n")
            install.packages(pkg, repos = "https://cran.r-project.org")
        }
    }
    cat("All packages installed!\n")
}

# Quick test
if (sys.nframe() == 0) {
    df <- generate_did_data()
    cat(sprintf(
        "Panel: %d units × %d periods = %d obs\n",
        length(unique(df$i)), length(unique(df$t)), nrow(df)
    ))
    cat(sprintf("Cohorts: %s\n", paste(sort(unique(df$Ei)), collapse = ", ")))
    cat(sprintf("Treated obs: %d (%.1f%%)\n", sum(df$D), mean(df$D) * 100))

    true_att <- compute_true_effects(df)
    cat("\nTrue ATT by relative time:\n")
    print(round(true_att, 3))
}
