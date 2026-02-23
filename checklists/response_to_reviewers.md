# 📋 Response to Reviewers Template

A structured template for responding to referee reports.

---

## General Principles

1. **Be grateful**: Thank the reviewer genuinely, even for harsh comments
2. **Be specific**: Quote the exact comment, then respond point-by-point
3. **Show changes**: Include revised text with page/line references
4. **Never dismiss**: If you disagree, explain why respectfully with evidence
5. **Over-deliver**: If asked for 1 robustness check, provide 2

---

## Template

```
Dear Editor,

We are grateful for the opportunity to revise our manuscript "[Title]" 
(Manuscript No. XXXX). We thank the editor and [two/three] anonymous 
referees for their constructive and insightful comments, which have 
substantially improved our paper.

Below, we provide a detailed, point-by-point response to each comment. 
Reviewer comments are in **bold**, and our responses follow. All changes 
in the manuscript are highlighted in [blue/red].

---

# Response to Reviewer 1

## Comment 1.1
**[Paste the reviewer's exact comment here]**

**Response**: We thank the reviewer for this important observation. 
[Your response addressing the concern].

**Action Taken**: [Describe specific changes made to the manuscript].

> *Revised text (p. X, lines Y-Z)*:
> "The new text that was added or modified in the manuscript, 
> showing exactly what changed."

---

## Comment 1.2
**[Next comment]**

**Response**: [Your response].

**Action Taken**: [Changes made].

> *See revised Table X / Section Y / Appendix Z*

---

# Response to Reviewer 2

## Comment 2.1
...

---

# Summary of Changes

| Section | Change | Motivation |
|---------|--------|-----------|
| Introduction, p.3 | Added policy context paragraph | Reviewer 1, Comment 1.1 |
| Table 3 | Added Province×Year FE specification | Reviewer 2, Comment 2.3 |
| Appendix A | New robustness check (Oster bounds) | Reviewer 1, Comment 1.5 |
| Section 5.2 | Rewrote mechanism analysis | Reviewer 2, Comment 2.1 |

---

We believe these revisions have substantially strengthened the paper 
and addressed all concerns raised by the reviewers. We hope the 
revised manuscript is now suitable for publication in [Journal Name].

Sincerely,
[Authors]
```

---

## Common Scenarios & Response Strategies

| Reviewer Says | Strategy |
|--------------|----------|
| "Endogeneity concern" | Add IV / placebo / Oster bounds; explain identification |
| "Parallel trends violated" | Show event study, run HonestDiD, add leads |
| "Why not use [X method]?" | Either adopt it or explain why current method is more appropriate |
| "Sample too small/narrow" | Discuss external validity; add robustness with broader sample if possible |
| "Writing needs improvement" | Substantial language editing; shorten; restructure |
| "Literature review incomplete" | Add specific missing references; rewrite relevant paragraphs |
| "Results not convincing" | Add robustness checks, economic significance, effect size comparison |
