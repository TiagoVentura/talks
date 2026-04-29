# Instructions for Building the Presentation

## Goal

Build a xaringan slide deck about how I (Tiago Ventura, Georgetown University) use Claude Code in my academic research workflow. The talk is for **academic colleagues in my department** — assume they are social scientists who may or may not have used LLM coding tools. The tone should be **honest and reflective**: what works, what doesn't, and what I've learned.

**Two intro slides before the case studies** — framing what an agentic coding model is and a three-dimension evaluation framework:

1. **What is an Agentic Coding Model?** — Drawing from Sol Messing's presentation: an LLM that generates code, edits files, executes code, and evaluates results. Key distinction from a chatbot: it acts autonomously within your project. Examples: Claude Code, GitHub Copilot Agent, Cursor, Windsurf.

2. **A Framework for Evaluation** — Three dimensions:
   - Research Productivity: Does it let me move faster, fail fast, scale?
   - Scientific Integrity: Hallucinations, AI slop, p-hacking temptation, false confidence?
   - Technical Capability: What can it handle? What's impressive vs. what falls short?
   - Key tension: the same speed that helps you fail fast enables p-hacking. Impressive output can mask errors.
   - Teaser: "I'll evaluate each case study through these three lenses."

The framework is introduced here and revisited in the cross-cutting lessons at the end. No per-case-study mini-scorecards.

## Slide Template

Use the xaringan template from `../twitter_ban/apsa_2025.Rmd` as the base. Copy its YAML header, CSS stack (`xaringan-themer.css`, `custom.css`, `mytheme-fonts.css`), setup chunks, and footer structure. Update the title, author, date, and footer text for this talk.

## How to Research My Usage

Search my Claude Code conversation history and run `/insights` to understand my usage patterns. Use this data to populate each case study with real examples — actual prompts I used, actual outputs Claude produced. Take screenshots or copy representative excerpts. Be extensive; I can trim later.

## Structure: Four Case Studies

Each case study is a separate section of the talk. For each, build slides covering:

1. **The problem** — what research task I needed to accomplish
2. **The prompt / instructions** — show the actual prompt or instruction file I gave Claude (can be a screenshot or key excerpt)
3. **The inputs** — what data/files/context Claude received
4. **The outputs** — what Claude produced (screenshots, code, text, files)
5. **What worked and what didn't** — honest assessment

---

### Case Study 1: Tournament for Selecting a Replication Paper

**Project location**: `/Users/tb186/Dropbox/artigos/replication_tournement/`

**Problem**: I needed to identify the best published survey experiment to replicate for the Coppock & McGrath (2026) Replication+Novel competition. This required searching hundreds of papers across 8 journals, scoring them on a rubric, and running a structured competition.

**What I did**: Wrote a detailed multi-phase instruction file (`instructions.md`) that guided Claude through:
- Phase 0: Deep reading of the RFP and deriving evaluation criteria
- Phase 1: Profiling the research team (Ventura + Asimovic) to define fit criteria
- Phase 2: Systematic search for survey experiments across 4+ journals (2010-2025) — found ~285 papers
- Phase 3: Hard-filter screening, deep evaluations, soft scoring on 8 weighted criteria
- Phase 4: Multi-agent tournament — 18-paper shortlist competing in round-robin debates with Claude as champion agents and both Claude + GPT as judges

**Key design features of the prompt to highlight**:
- Mandatory stop-and-check points (checkpoints where Claude must wait for human approval)
- Multi-model design: Claude Opus for judgment, Sonnet for coding, GPT-5 for cross-validation
- Three independent trials with different models/filters to test robustness of results
- Structured output: CSV databases, markdown evaluations, tournament bracket transcripts

**Outputs**: 3 complete trials, each with a different champion paper. Cross-trial analysis showed P176 (Druckman et al. 2022) was the most robust candidate (top 3 in all 3 trials). See `trials_summary.md` for the cross-trial comparison.

**What worked**: The phased checkpoint structure kept Claude on track across a very long task. Multi-model judging revealed real disagreements (Claude favored theoretical ambition; GPT favored execution certainty). The tournament format produced a defensible, well-documented decision.

**What didn't work / lessons**: Sensitivity to model choice was higher than expected — each trial had a different champion. Deep evaluations via web search sometimes hallucinated paper details (had to add explicit verification steps). The prompt was ~900 lines, which is probably too long for most use cases but necessary here.

---

### Case Study 2: Full Paper Writing — High-Speed Internet and Mental Health

**Project location**: `/Users/tb186/Dropbox/artigos/_Died/AV_internet_speed_politics/`
**Prompt file**: `_Died/AV_internet_speed_politics/instructions.md`

**Problem**: I had data on mobile internet coverage in Brazil (ANATEL regulatory data with a 30,000-inhabitant threshold creating a natural experiment) and wanted to estimate causal effects on mental health using a fuzzy regression discontinuity design. The goal was to produce a complete PNAS paper.

**What I did**: Wrote a complete instruction file (`instructions.md`) specifying:
- Phase 1: Literature review (with verification — every citation must be confirmed real)
- Phase 2: Build the instrument (first-stage RD plots, covariate balance, McCrary tests)
- Phase 3: Download mental health outcome data from DataSUS
- Phase 4: Merge datasets at municipality level
- Phase 5: Estimate fuzzy RD using `rdrobust` in R, plus robustness checks
- Phase 6: Write the paper (Significance Statement, Abstract, Intro, Results, Discussion, Methods) in LaTeX
- Phase 7: Organize code and final validation

**Key design features of the prompt to highlight**:
- Model selection rules: Opus for intellectual tasks (writing, interpretation), Sonnet for coding
- Explicit handling of null results: "If the analysis finds no significant effects, write the paper with null findings"
- Checkpoint architecture same as Case Study 1
- The project is in the `_Died` folder — highlight this as an example of Claude helping you quickly assess whether an idea is worth pursuing (sometimes the answer is no, and that's valuable)

**Outputs**: Literature review, RD plots, analysis code, draft paper sections.

**What actually happened (corrected narrative)**:
1. DataSUS data downloaded successfully — no access problems
2. Claude ran the first estimation **wrong**: used 30,000 as a bandwidth parameter instead of running a fuzzy RDD around the 30,000 population threshold. Claude executed confidently but incorrectly.
3. I caught the mistake (required domain expertise to spot) and corrected the approach
4. Corrected estimation showed **null results** — Claude delivered this much faster than doing it manually
5. Project killed → moved to `_Died` folder

**The estimation mistake** is the key story: Claude used 30,000 as a bandwidth (a smoothing parameter) instead of using it as the cutoff for the fuzzy RDD. This is a subtle but fundamental misunderstanding of the research design. It executed the wrong specification confidently and without flagging uncertainty. Catching this required knowing what a fuzzy RD should look like.

**P-hacking on steroids**: The speed that helps you "fail fast" also makes it tempting to keep re-running specifications. Claude makes it trivially easy to tweak bandwidths, add covariates, try different outcomes until something is significant. The same tool that efficiently delivered null results could also be used to p-hack your way to a false positive. This is a CS2-specific concern — the acceleration of the research pipeline amplifies both good practices (failing fast) and bad ones (specification searching).

**What worked**: The phased approach meant I could evaluate intermediate results before investing more time. After the correction, null results were delivered fast. This is a case where Claude helped me fail fast.

**What didn't work / lessons**: Claude executed the wrong estimation confidently — domain expertise is essential for catching methodological errors. The Opus/Sonnet split is a useful heuristic for judgment vs. coding tasks.

---

### Case Study 3: Coding Tasks, Plan Mode & Custom Skills — Global Social Media Study & APSR Tables

**Project location**: `/Users/tb186/Dropbox/artigos/Global_deactivation/gsm_second_stage_code/`
**Skill location**: `/Users/tb186/.claude/skills/apsr-tables/`
**Plan mode example**: `/Users/tb186/Dropbox/artigos/SVTR_twitter_ban/plans/missing_data_analysis.md`

**Problem**: Three related coding workflows:
1. The Global Social Media Study (a 23-country field experiment on social media reduction, registered report at Nature) required repetitive country-by-country data processing scripts — download from Qualtrics, clean, screen, assign treatment, etc.
2. Using Claude for coding verification tasks — running consistency checks on country data (e.g., verifying participant counts match across waves), having Claude verify if numbers in code output match expectations, testing if the pipeline works end-to-end before replicating across countries.
3. Academic papers need appendix regression tables, but the main figures are visualizations. Converting figure code back into tables is tedious.

**What I did**:

*For the GSM project — CLAUDE.md*: Set up a CLAUDE.md with project context (the country-folder pattern, shared `utils.R`, numbered script pipeline `00_` through `05_`). Then used Claude to replicate the pipeline across countries — once the UK pilot worked, Claude could adapt it for Australia, Denmark, India, Netherlands, etc. The CLAUDE.md is one bullet in the broader workflow, not the centerpiece — it makes onboarding instant but the real value is in the coding tasks.

*For the GSM project — Coding Tasks*: Beyond pipeline replication, Claude handled verification tasks: running consistency checks on country data (e.g., verifying participant counts match across waves), checking if numbers in code output match expectations, testing if the pipeline works correctly end-to-end before replicating across countries. These are tedious-but-critical tasks where Claude excels.

*For Plan Mode — Missing Data Analysis*: Used Claude's Plan Mode to structure a complex analysis. Claude wrote a structured plan before coding (see `SVTR_twitter_ban/plans/missing_data_analysis.md`). The plan has a 5-module structure:
- Module 1: Data Loading & Match Indicator Construction
- Module 2: Summary Statistics & Balance Table
- Module 3: Statistical Tests
- Module 4: Visualizations
- Module 5: Additional Analysis
Each module specifies inputs, steps, outputs, and verification. The plan produced `code/09_missing_data_analysis.R` (541 lines, 5 modules), with built-in verification steps after each module. Plan Mode is valuable for non-trivial analyses where you want Claude to think through the structure before writing code.

*For APSR tables*: Built a reusable Claude Code skill (`/Users/tb186/.claude/skills/apsr-tables/SKILL.md`) that automates the conversion:
- Scans the manuscript `.tex` file for figures
- Locates the figure-producing R code
- Traces back to the underlying regression models
- Generates appendix tables using `modelsummary` with proper LaTeX formatting
- Key rule: use `modelsummary(output = "path.tex")` directly, never `save_kable`

**Key design features to highlight**:
- CLAUDE.md as project documentation: makes Claude immediately productive (one bullet, not the whole story)
- Coding tasks and verification: consistency checks, output matching, end-to-end testing
- Plan Mode: structured planning before coding for complex analyses
- Custom skills as reusable workflows: the `apsr-tables` skill can be invoked on any paper project
- Code reuse across countries: write once for the pilot, replicate across 23 countries

**Outputs**: Country-specific data pipelines, missing data analysis (541-line R script from plan), appendix tables, clean LaTeX output.

**What worked**: The country-folder pattern + CLAUDE.md made it trivial to onboard Claude to each new country. Plan Mode produced a well-structured analysis script. The `apsr-tables` skill saves hours per paper and produces consistent output. Claude is excellent at repetitive-but-slightly-different coding tasks and tedious verification.

**What didn't work / lessons**: Claude sometimes over-engineers solutions when you need a simple copy-paste-modify. The `utils.R` shared file occasionally caused namespace issues when Claude modified it for one country without realizing it affected others.

---

### Case Study 4: Peer Review with the Meta-Reviewer Skill

**Skill location**: `/Users/tb186/.claude/skills/` (meta-review, substantive-review, writing-review, technical-review)
**Example review output**: `SVTR_twitter_ban/review/MAIN_MOST_UPDATED_technical_review.md`

**Problem**: Peer reviewing manuscripts is time-consuming and requires checking multiple dimensions simultaneously — substantive theory, statistical methods, writing quality, and consistency between code/figures/text.

**What I did**: Built a four-skill review system:

1. **`/substantive-review`** — Evaluates theory, causal inference, design, statistics, and transparency. Produces mentor-style feedback organized by screening domains (theory & contribution, literature, design/measurement, causal identification, statistical modeling, sampling, outcome reporting, presentation, transparency). Output: `_substantive_review.md`

2. **`/writing-review`** — Surface-level only: typos, grammar, spelling, punctuation, clarity. Explicitly forbidden from touching substance. Output: `_writing_review.md`

3. **`/technical-review`** — Verifies consistency between the paper and its artifacts: do figures match descriptions? Do table numbers match text claims? Does the code produce what the paper says it produces? Output: `_technical_review.md`

4. **`/meta-review`** — Orchestrates all three above, reads their outputs, and synthesizes a unified prioritized action plan with verdict, must-fix/should-fix/optional items, and cross-cutting themes. Output: `_meta_review.md`

**Concrete technical review findings** (from `SVTR_twitter_ban/review/MAIN_MOST_UPDATED_technical_review.md`):
- **Clustering issue**: "The paper mentions that errors are 'clustered at the user level'... the choice of clustering level affects the standard errors. The paper should justify why user-level clustering is sufficient and whether two-way clustering would be more appropriate."
- **Numerical error**: "Text claims 'long-term 17% increase' in likes share, but the numbers given are 73% (before) and 80% (after) = 7pp increase, not 17%."
- **Code bug**: "Code line 529: `1.26-1.30/sd(...)` has operator precedence issue (division before subtraction). Makes the '0.94 standard deviations' claim unverifiable."
- **Unverifiable statistics**: "Multiple key numbers (beta=1.76, z=12.6, user counts) are only computed as console output and not saved to any artifact."

**Key design features to highlight**:
- Separation of concerns: each skill has a narrow scope, preventing the "do everything at once" failure mode
- The meta-reviewer as orchestrator: runs the three specialized skills, then synthesizes
- Input/output contract: each skill takes a manuscript path + code directory, outputs a markdown file
- The writing reviewer is explicitly told NOT to comment on substance (this prevents scope creep)

**Outputs**: Four markdown review files per manuscript. Show example output from each.

**What worked**: The separation into specialized reviewers produces more thorough, less muddled feedback than asking for "a review." The technical reviewer catches things humans often miss (figure-text inconsistencies, code bugs, numerical errors). The meta-reviewer's prioritized action list is immediately actionable.

**What didn't work / lessons**: The substantive reviewer sometimes hedges too much ("this could be improved" instead of "this is wrong"). The technical reviewer needs access to the actual code directory — if the code is messy or undocumented, the review quality drops. The meta-reviewer occasionally gives contradictory advice when the sub-reviews disagree.

---

### Case Study 5: Building a Self-Updating Slide Deck — A custom skill that captures new case studies as they happen

**Skill location**: `~/.claude/skills/add-case-study/SKILL.md`

**Problem**: The talk grows every time I try something new with Claude Code, but manually adding case studies means copying exact xaringan formatting, finding insertion points, updating counts — easy to break things with 50+ existing slides.

**What I did**: Wrote a ~150-line implementation plan specifying the skill's behavior — input modes (freeform vs. structured), insertion strategy (anchor strings not line numbers), formatting rules (match existing xaringan patterns), a 7-step workflow (gather → read state → generate → preview → insert → update notes → report), and safety rules (preview before editing, never touch Cross-Cutting Lessons).

Claude Code built the full SKILL.md from this plan in a single pass.

**Key design features to highlight**:
- Anchor-string insertion: grep for unique strings (`# Cross-Cutting Lessons`, `## Roadmap`, `## General Slide Design Notes`) instead of fragile line numbers
- Preview-before-edit: the skill shows all generated slides for human approval before touching any file
- Number word mapping (Four → Five → Six...) so the title and roadmap update automatically
- Two input modes: can extract structure from conversation context (freeform) or ask follow-up questions (structured)

**Outputs**: A working `/add-case-study` skill that can be invoked from any Claude Code conversation to add a new case study to the slide deck.

**What worked**: The plan-first approach meant the skill matched exact formatting conventions on the first try. Anchor-string insertion is robust regardless of slide count. The skill has access to conversation context, so it can capture experiences right when they happen.

**What didn't work / lessons**: N/A — first invocation. Will update as the skill gets more use.

---

### Case Study 6: The Obsidian Vault as a Retrieval System — Structured literature notes that keep Claude honest with reviewers

**Project location**: `_art/literature/`, `_art/context/lit_review.md`, `artigos/VMLTT_WhatsApp_Multicountry/`

**Problem**: AJPS Reviewer 3 challenged the theoretical backbone of the WhatsApp multicountry paper and named specific papers (Gursky et al. 2022, Nizaruddin 2021, Ozawa et al.) that needed to be engaged. The risk: Claude citing from training data, paraphrasing without reading, inventing page numbers.

**What I did**: The vault's `context/lit_review.md` protocol (notes first, web second) is wired into CLAUDE.md. When the reviewer named specific papers not yet in the vault, the workflow was: download PDF → write structured vault note → synthesize from the note. One session: 29 Claude prompts, 14 new literature notes created, each with YAML frontmatter, verbatim quotes with page numbers, and a `## Relevance to AJPS Reviewer 3 Concerns` section. Notes tagged `context/ajps-rr-reviewer3` for scoped retrieval.

**Key design features to highlight**:
- `context/lit_review.md` as an explicit override in CLAUDE.md — 4-step protocol (README → grep frontmatter → read notes → only then web)
- Verbatim quotes with page numbers as the grounding mechanism
- Task-scoped frontmatter tags (`context/ajps-rr-reviewer3`) for grepable retrieval
- The supervison moment: catching Claude writing notes without downloading PDFs

**Outputs**: 14 new annotated literature notes ready to ground the reviewer response memo; Overleaf edits to `r1_ajps.tex` driven by those notes.

**What worked**: The protocol forces grounding before synthesis. Tagging by revision task keeps retrieval scoped. The vault compounds — each R&R adds notes that stay useful for future papers.

**What didn't work / lessons**: Claude will shortcut the grounding step if not supervised — it tried to write notes without reading the PDFs. "Notes first, web second" must be explicit and enforced, not assumed.

---

## General Slide Design Notes

- Use `.red[]` for emphasis on key terms
- Use `.midgrey[]` for de-emphasized references
- Use `knitr::include_graphics()` for screenshots — save all screenshots to `output/`
- Use panelset tabs (from xaringanExtra) when showing multiple related pieces (e.g., prompt → input → output)
- Keep code excerpts short — show the key 5-10 lines, not the full file
- For each case study, include at least one "prompt excerpt" slide and one "output" slide

## Rules

**YOU MUST FOLLOW THESE RULES. THEY ARE NON-NEGOTIABLE.**

1. **NEVER claim something works without running a test to prove it.** After writing any code, immediately write and run a test. If you cannot test it, say so explicitly.

2. **Work modularly.** Complete one module at a time. After each module, report what you built, show test results, and wait for confirmation before proceeding.

3. **Iterate and fix errors yourself.** Do not rely on the user to report errors back to you. Run the code, observe the output, and fix problems before presenting results.

4. **Be explicit about unknowns.** If you're uncertain about something, say so. Don't guess.
