# CLAUDE.md — Talks

Source materials for talks and presentations from my post-PhD career. Published at `tiagoventura.github.io/talks/`.

## Structure

Talks are organized by **research project / topic**, not by venue. Each topic folder holds multiple presentations rendered for different venues (one `.qmd` per venue).

- `twitter_ban/` — Twitter/X ban in Brazil
- `whatsapp_multicountry/` — WhatsApp multicountry study
- `whatsapp_deact/` — WhatsApp deactivation experiment
- `ai_elections/` — Generative AI, misinformation, and 2024 elections
- `survey_professionals/` — Survey professionals project
- `ite/` — Prior exposure vs. PMR (individual treatment effects)
- `agentic_ai/` — Agentic AI / Claude Code talks
- `sciencespo_conference/`, `training_css/`, `reu/`, `abcp/`, `l2/` — venue- or program-specific decks
- `template/` — base template (`template.qmd` + shared SCSS/CSS) for new talks, modeled on `twitter_ban/twitter_ban_western.qmd`. See [[template/CLAUDE]].

`README.md` is the public index of talks by year. `_extensions/`, `custom.css`, `custom.scss`, `mytheme-fonts.css` provide shared Quarto/reveal.js styling.

## Conventions

- Talks are built with **Quarto reveal.js** (`.qmd` source files).
- When adding a new talk for an existing project, copy an existing `.qmd` in that project folder and rename it after the venue (e.g., `apsa_2025.qmd`, `western.qmd`). Do not start from scratch.
- Use the shared CSS/SCSS at the repo root rather than redefining theme styles per talk.
- After adding a new talk, update `README.md` under the correct year.
- Slide style follows the "Rhetoric of Decks" philosophy — assertion-driven titles, one idea per slide.
- The **`presentation` Claude Code skill** converts a paper (`.tex`) into a Quarto reveal.js deck. Use it as the starting point when turning a paper into a new talk, then layer the `template/` styling on top.

## When working here

- Writing rules from [[../context/WritingStyle]] apply to all slide text.
- Coding rules from [[../context/Coding]] apply to any R/tidyverse code chunks in the decks.
