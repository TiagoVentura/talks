##############################################################################
# File-Name: fig_partisan_slide.R
# Purpose: Slide-sized version of Figure 4 (partisan congruence in AI-AI pairs).
#          Same data, glmer model, and avg_predictions as
#          pnas_replication_package/code/09_logit.R, redrawn for the GenAI &
#          Social Science talk: signed axis and bar labels, larger text, shared
#          y-axis across parties.
# Output: output/fig_partisan_slide.png
##############################################################################

pacman::p_load(tidyverse, lme4, marginaleffects)

repl <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data"
out  <- "~/Dropbox/_art/talks/ai_humanness/output/fig_partisan_slide.png"

# Data: AI-AI pairs, as in 09_logit.R ----------------------------------------
d_ai_ai <- read_csv(file.path(repl, "pairs_survey_clean.csv"), show_col_types = FALSE) |>
  filter(att_check_sum == 0) |>
  mutate(source_num = ifelse(source == "Human", 1, 0)) |>
  group_by(response_id, order, platform) |>
  mutate(sum_source = sum(source_num)) |>
  ungroup() |>
  filter(sum_source == 0) |>
  mutate(persona = str_to_lower(persona))

d_model <- d_ai_ai |>
  filter(!is.na(party_id_imputation), !is.na(persona), !is.na(binary_response),
         party_id_imputation %in% c("Democrat", "Republican"))

# Model: same specification as Figure 4 --------------------------------------
mod <- glmer(binary_response ~ persona * party_id_imputation + (1 | order) + (1 | response_id),
             data = d_model, family = binomial,
             control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5)))

persona_map <- c("progressivecommentator"         = "Progressive",
                 "liberalcommentator"             = "Liberal",
                 "moderatecommentator"            = "Moderate",
                 "conservativecommentator"        = "Conservative",
                 "libertarianpopulistcommentator" = "Libertarian\nPopulist")

n_party <- d_ai_ai |>
  filter(party_id_imputation %in% c("Democrat", "Republican")) |>
  distinct(party_id_imputation, response_id) |>
  count(party_id_imputation)

res <- avg_predictions(mod, by = c("party_id_imputation", "persona")) |>
  as_tibble() |>
  left_join(n_party, by = "party_id_imputation") |>
  mutate(persona  = factor(persona_map[persona], levels = persona_map),
         party    = paste0(party_id_imputation, "s (n = ", n, ")"),
         # binary_response = picked as AI; flip so positive = seen as more human
         pct_diff = (1 - estimate - 0.5) * 100,
         lb95     = pct_diff - 1.96 * std.error * 100,
         up95     = pct_diff + 1.96 * std.error * 100,
         label    = sprintf("%+.1f", pct_diff))

print(res |> select(party, persona, pct_diff, lb95, up95))

# Plot -----------------------------------------------------------------------
party_colors <- c("#2b83ba", "#c0392b")
names(party_colors) <- sort(unique(res$party))

direction <- tibble(party = sort(unique(res$party))[1],
                    y = c(11.5, -11.5), label = c("More human-like", "More AI-like"))

p <- ggplot(res, aes(x = persona, y = pct_diff, fill = party)) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.6) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = lb95, ymax = up95), width = 0.15, color = "gray45", linewidth = 0.8) +
  geom_text(aes(label = label, y = if_else(pct_diff >= 0, up95 + 0.6, lb95 - 0.6),
                vjust = if_else(pct_diff >= 0, 0, 1), color = party),
            fontface = "bold", size = 6.5) +
  geom_text(data = direction, aes(x = 0.55, y = y, label = label), inherit.aes = FALSE,
            hjust = 0, size = 6, color = "gray45") +
  scale_fill_manual(values = party_colors) +
  scale_color_manual(values = party_colors) +
  scale_y_continuous(limits = c(-12.5, 12.5), breaks = seq(-10, 10, 5),
                     labels = function(x) paste0(ifelse(x > 0, "+", ""), x, " pp")) +
  facet_wrap(~party, nrow = 1) +
  labs(x = "AI persona", y = "Deviation from chance\n(percentage points)") +
  theme_minimal(base_size = 22) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.spacing.x = unit(1.2, "lines"),
        strip.text = element_text(size = 26, face = "bold"),
        axis.text.x = element_text(size = 16, color = "#22211d", lineheight = 0.9),
        axis.text.y = element_text(size = 18),
        axis.title = element_text(size = 20),
        axis.title.x = element_text(margin = margin(t = 10)))

ggsave(out, p, width = 17, height = 7, dpi = 300, bg = "white")
message("Saved: ", out)
