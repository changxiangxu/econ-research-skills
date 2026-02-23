# ══════════════════════════════════════════════════════════
#  Project:  [Your Project Name]
#  Author:   [Your Name]
#  Date:     [Date Created]
#  Purpose:  Master script — one-click replication of all analyses
#
#  INSTRUCTIONS:
#    1. Open this file in RStudio
#    2. Modify ONLY the root path on line 18 below
#    3. Source this file: source("00_master.R")
#    4. All tables, figures, and logs will auto-generate
#
#  Requirements:
#    - R 4.0+ with packages: fixest, modelsummary, ggplot2, dplyr,
#      did, HonestDiD, haven, readr, broom, kableExtra
# ══════════════════════════════════════════════════════════

# ═══ ONLY PATH TO MODIFY ═══════════════════════════════
root <- "D:/Research/YourProjectName"
# ════════════════════════════════════════════════════════

# ─── Derived Paths ──────────────────────────────────────
paths <- list(
  raw     = file.path(root, "00_RawData"),
  code    = file.path(root, "01_Code"),
  clean   = file.path(root, "02_CleanData"),
  output  = file.path(root, "03_Output"),
  tables  = file.path(root, "03_Output", "Tables"),
  figures = file.path(root, "03_Output", "Figures"),
  logs    = file.path(root, "03_Output", "Logs")
)

# ─── Create Directories ────────────────────────────────
for (p in paths) dir.create(p, showWarnings = FALSE, recursive = TRUE)

# ─── Load Packages ─────────────────────────────────────
required_packages <- c(
  "fixest",        # Fast FE regression (feols, feglm, fepois)
  "modelsummary",  # Beautiful regression tables
  "ggplot2",       # Publication-quality figures
  "dplyr",         # Data manipulation
  "tidyr",         # Data reshaping
  "haven",         # Read .dta files
  "readr",         # Read .csv files
  "broom",         # Tidy regression output
  "did",           # Callaway & Sant'Anna DID
  "HonestDiD",     # Rambachan & Roth sensitivity
  "did2s",         # Gardner two-stage DID
  "kableExtra",    # Table formatting
  "ggthemes",      # Extra ggplot themes
  "patchwork"      # Combine ggplots
)

# Install missing packages
new_pkgs <- required_packages[!required_packages %in% installed.packages()[, "Package"]]
if (length(new_pkgs) > 0) install.packages(new_pkgs)

# Load all
lapply(required_packages, library, character.only = TRUE)

# ─── Set Theme ─────────────────────────────────────────
theme_set(
  theme_minimal(base_size = 12, base_family = "serif") +
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
)

# ═══════════════════════════════════════════════════════
# RUN ANALYSIS PIPELINE
# ═══════════════════════════════════════════════════════

start_time <- Sys.time()

cat("══════════════════════════════════════════════════\n")
cat("  Project: [Your Project Name]\n")
cat("  Date:   ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("  R:      ", R.version.string, "\n")
cat("══════════════════════════════════════════════════\n\n")

# ─── Step 1: Data Cleaning ─────────────────────────────
cat("▶ Step 1: Data Cleaning\n")
source(file.path(paths$code, "01_clean.R"))

# ─── Step 2: Variable Construction ─────────────────────
cat("▶ Step 2: Variable Construction\n")
source(file.path(paths$code, "02_construct.R"))

# ─── Step 3: Descriptive Statistics ────────────────────
cat("▶ Step 3: Descriptive Statistics\n")
source(file.path(paths$code, "03_descriptive.R"))

# ─── Step 4: Baseline Regression ──────────────────────
cat("▶ Step 4: Baseline Regression\n")
source(file.path(paths$code, "04_baseline.R"))

# ─── Step 5: Robustness Checks ───────────────────────
cat("▶ Step 5: Robustness Checks\n")
source(file.path(paths$code, "05_robustness.R"))

# ─── Step 6: Heterogeneity Analysis ──────────────────
cat("▶ Step 6: Heterogeneity Analysis\n")
source(file.path(paths$code, "06_heterogeneity.R"))

# ─── Step 7: Mechanism Analysis ──────────────────────
cat("▶ Step 7: Mechanism Analysis\n")
source(file.path(paths$code, "07_mechanism.R"))

# ─── Step 8: Tables & Figures Export ─────────────────
cat("▶ Step 8: Tables & Figures Export\n")
source(file.path(paths$code, "08_tables_figures.R"))

# ═══════════════════════════════════════════════════════

elapsed <- difftime(Sys.time(), start_time, units = "secs")

cat("\n══════════════════════════════════════════════════\n")
cat("  ✅ ALL ANALYSES COMPLETE!\n")
cat("  Total time:", round(as.numeric(elapsed), 1), "seconds\n")
cat("  Tables saved to:", paths$tables, "\n")
cat("  Figures saved to:", paths$figures, "\n")
cat("══════════════════════════════════════════════════\n")
