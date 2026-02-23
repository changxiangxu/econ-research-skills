# 🔄 Git + GitHub Basics for Economists

> Version control is **non-negotiable** for reproducible research.
> This guide covers everything you need — nothing more, nothing less.

---

## Why Git? (30-Second Pitch)

| Without Git | With Git |
|-------------|----------|
| `paper_v1.docx`, `paper_v2_final.docx`, `paper_v2_final_REAL.docx` | One file, full history |
| "Which version had the correct Table 3?" | `git log` → find any past version |
| Laptop dies → everything lost | GitHub = cloud backup |
| Co-author overwrites your changes | Merge conflicts detected automatically |
| Referee asks "show me the old specification" | `git diff` → instant comparison |

---

## Setup (One-Time, 5 Minutes)

### Step 1: Install Git
- **Windows**: Download from [git-scm.com](https://git-scm.com/download/win), install with defaults
- **Mac**: `xcode-select --install` (or `brew install git`)
- **Linux**: `sudo apt install git`

### Step 2: Configure Your Identity
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@university.edu"
```

### Step 3: Create GitHub Account
1. Go to [github.com](https://github.com) → Sign up (free)
2. Create your first repository (click "New" → name it → "Create repository")

### Step 4: Connect Git to GitHub
```bash
# Option A: HTTPS (easier, asks for password)
# Just clone and it works

# Option B: SSH (recommended, no password needed after setup)
ssh-keygen -t ed25519 -C "your.email@university.edu"
# Copy the public key:
cat ~/.ssh/id_ed25519.pub
# Paste it at: GitHub → Settings → SSH Keys → New SSH Key
```

---

## The 4 Commands You Need (90% of All Git Usage)

```
Working Directory     Staging Area          Local Repo           GitHub
    (your files)      (ready to commit)     (saved history)     (cloud backup)
        │                   │                    │                   │
        ├── git add ──────→ │                    │                   │
        │                   ├── git commit ────→ │                   │
        │                   │                    ├── git push ─────→ │
        │                   │                    │                   │
        │←──────────────────│←───────────────────│←── git pull ──────│
```

### 1. `git add` — Stage Changes
```bash
git add .                    # Stage ALL changed files
git add analysis.do          # Stage one specific file
git add code_library/        # Stage an entire folder
```

### 2. `git commit` — Save a Snapshot
```bash
git commit -m "Add baseline regression results"
```

**Good commit messages** (follow conventions):
```
feat: add baseline DID regression
fix: correct clustering level from firm to city
data: update cleaned dataset with 2024 observations
docs: add variable codebook
refactor: split analysis.do into baseline + robustness
```

### 3. `git push` — Upload to GitHub
```bash
git push                     # Push to default branch
git push origin main         # Explicit: push to main branch
```

### 4. `git pull` — Download Updates
```bash
git pull                     # Get latest changes from GitHub
```

---

## Complete Workflow: Start a New Research Project

```bash
# Step 1: Create project folder
mkdir MyResearchProject
cd MyResearchProject

# Step 2: Initialize Git
git init

# Step 3: Create standard folder structure
mkdir 00_RawData 01_Code 02_CleanData 03_Output 04_Paper

# Step 4: Create .gitignore (IMPORTANT!)
# Copy from our template: econ-research-skills/.gitignore

# Step 5: First commit
git add .
git commit -m "Initial project structure"

# Step 6: Connect to GitHub
# (Create repo on github.com first, then:)
git remote add origin https://github.com/yourusername/your-repo.git
git branch -M main
git push -u origin main

# Step 7: Daily workflow (repeat this every session)
# ... do your work ...
git add .
git commit -m "feat: add robustness checks"
git push
```

---

## Daily Workflow Cheat Sheet

```
Morning:
  git pull                          ← Get latest (if co-author pushed)

Work Session:
  [edit files, run regressions]

End of Day:
  git add .                         ← Stage all changes
  git status                        ← Check what's staged
  git commit -m "descriptive msg"   ← Save snapshot
  git push                          ← Upload to GitHub
```

---

## Useful Commands Reference

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `git status` | Show what's changed | Before committing (sanity check) |
| `git log --oneline -10` | Show last 10 commits | Review recent history |
| `git diff` | Show line-by-line changes | See exactly what you modified |
| `git checkout -- file.do` | Undo changes to a file | Made a mistake, want to revert |
| `git stash` | Temporarily shelve changes | Need to switch tasks quickly |
| `git branch feature-x` | Create a new branch | Experimenting with alternative specs |
| `git clone URL` | Download a repo | Getting someone else's code |

---

## What NOT to Put in Git

| ❌ Don't Track | ✅ Do Track |
|---------------|------------|
| Raw data files (`.dta`, `.csv` > 50MB) | Code (`.do`, `.R`, `.py`) |
| Output files (`.pdf`, `.png`, `.log`) | Documentation (`.md`, `.tex`) |
| Temporary files (`.smcl`, `__pycache__`) | Configuration (`.gitignore`, `README`) |
| Sensitive data (passwords, API keys) | Small reference data (< 10MB) |

> **Rule of thumb**: If a file is *generated* by your code, don't track it.
> If a file is *too large* (> 50MB), don't track it — use a README to explain how to get it.
> Everything else → track it.

---

## Common Problems & Solutions

| Problem | Solution |
|---------|----------|
| "I committed something I shouldn't have" | `git reset HEAD~1` (undo last commit, keep files) |
| "Git says there's a merge conflict" | Open the file, look for `<<<<<<<` markers, choose which version to keep |
| "I want to see an old version of a file" | `git show HEAD~3:code/analysis.do` (3 commits ago) |
| "I accidentally deleted a file" | `git checkout -- filename` |
| "Push is rejected" | `git pull` first, then `git push` |
| "I want to ignore a file that's already tracked" | `git rm --cached filename` then add to `.gitignore` |

---

## GitHub for Collaboration (With Co-Authors)

```
You:         git push ────→ GitHub ←──── git pull :Co-author
Co-author:   git push ────→ GitHub ←──── git pull :You
```

**Basic collaboration rules:**
1. Always `git pull` before starting work
2. Always `git push` when you finish
3. Commit frequently with clear messages
4. Never force push (`git push -f`) on shared branches
