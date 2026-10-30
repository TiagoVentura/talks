# CLAUDE.md — Template

**Superseded (Oct 2026).** New decks use the hero template from the NYU Humaness / UPenn CIND talks: `twitter_ban/custom_quarto_upenn.scss` + `twitter_ban/upenn_cind.qmd` as the reference, with copies in the `presentation` Claude Code skill (`~/.claude/skills/presentation/template_deck.qmd`). House rules: no `::: aside` (findings go in a plain `[...]{.midgrey}` paragraph under the figure), no `--`/`---`/em-dashes in titles or text, hero title and closing slides, `rq-divider` section breaks. The notes below describe the older dark-divider template and only matter for re-rendering old decks.

Base template for new talks. Modeled on `twitter_ban/twitter_ban_western.qmd`.

## Files

- `template.qmd` — skeleton deck. Quarto reveal.js, simple theme + custom.scss, 1200x900, incremental bullets, dark `#23395b` section dividers.
- `custom.scss`, `custom_quarto.scss`, `custom.css`, `mytheme-fonts.css` — shared styling copied from `twitter_ban/`.

## How to use

1. Copy this whole folder into the relevant project folder (e.g., `whatsapp_multicountry/`) and rename it after the venue (e.g., `mortara/` or just drop the `.qmd` directly into the project folder as `mortara.qmd`).
2. Edit the YAML header: `title`, `subtitle`, `author`, `date`, `footer`.
3. Build slides around assertion-driven titles — the title should state the point, the body should support it.
4. Drop figures into an `output/` subfolder and reference them with `![](output/filename.png)`.
5. After rendering, add the new talk to `talks/README.md` under the right year.

## Slide conventions baked into the template

- Section dividers use `# Section Name {background-color="#23395b"}`
- Two-column layouts use `:::: {.columns}` / `::: {.column width="50%"}`
- Reveal-style fragments via `::: {.fragment}`
- Captions / asides use `::: aside` with `[text]{.midgray}` for muted color
- Closing slide is the dark background with "Thank you" + contact

## Related

- The `presentation` Claude Code skill converts academic papers (`.tex`) into Quarto reveal.js decks following the Rhetoric of Decks philosophy. Use it as the starting point when turning a paper into a new talk, then copy this template's styling on top.
