# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a subdirectory of a larger **academic talks and presentations repository** by Tiago Ventura (Georgetown University, McCourt School of Public Policy). The `ai_elections/` folder contains xaringan slide decks on AI, misinformation, social media, and elections.

Presentations are hosted via GitHub Pages at `https://tiagoventura.github.io/talks/ai_elections/`.

## Technology Stack

- **R Markdown (`.Rmd`)** with the **xaringan** package for HTML slide presentations
- **xaringanthemer** for slide theme generation (produces `xaringan-themer.css` — do not edit directly)
- **xaringanExtra** for tile view and panelset features
- CSS files: `custom.css` (layout/colors), `mytheme-fonts.css` (typography via Google Fonts: Lora, Lato, Source Sans Pro), `fontsrladies.css`

## Build Commands

Render any presentation to HTML:
```r
rmarkdown::render("filename.Rmd")
```

Or from the command line:
```bash
Rscript -e 'rmarkdown::render("gtpi.Rmd")'
```

Rendered HTML files and their `_cache`/`_files` directories are kept in the repo for GitHub Pages hosting.

## Slide Conventions

- All `.Rmd` files share the same YAML structure and setup chunks (see `template.Rmd` for the canonical template)
- Theme colors: base `#23395b` (dark blue), links `#C93312` (red), background white
- Footer format: author name + event name in `<div class="my-footer">`
- Slides use `layout: true` with the footer div applied globally
- Common slide classes: `middle`, `center`, `inverse` (for section dividers)
- Images go in `output/` and are included via `knitr::include_graphics()`
- Caching is enabled by default (`cache=TRUE` in knitr opts)

## Creating a New Talk

1. Copy `template.Rmd` and update the YAML front matter (title, author, date, event)
2. Update the footer div text
3. Add images to `output/`
4. Render with `rmarkdown::render()`

## Existing Presentations

- `gtpi.Rmd` — Generative AI, Misinformation and 2024 Elections (GTPI, March 2024)
- `ilcss.Rmd` — The Global Social Media Experiment (iLCSS, March 2024)
- `mewe.Rmd` — Effects of Social Media / Role of Experimentation (Mewe & Georgetown, March 2024)
