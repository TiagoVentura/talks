##############################################################################
# File-Name: fig_detection_slide.R
# Purpose: Slide-sized version of SI Figure S5 (AI detection rate in human-AI
#          pairs, pooled and by platform). Same data prep and models as
#          pnas_replication_package/code/07_direct_pairs.R, redrawn with larger
#          text for the GenAI & Social Science talk.
# Output: output/fig_detection_slide.png
##############################################################################

pacman::p_load(tidyverse, marginaleffects)

repl <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data"
out  <- "~/Dropbox/_art/talks/ai_humanness/output/fig_detection_slide.png"

conf_int <- function(data, estimate, std) {
  data |> mutate(up95 = {{estimate}} + 1.96 * {{std}},
                 lb95 = {{estimate}} - 1.96 * {{std}})
}

# Data: same pre-processing as 07_direct_pairs.R -----------------------------
d_pairs <- read_csv(file.path(repl, "pairs_survey_clean.csv"), show_col_types = FALSE) |>
  filter(att_check_sum == 0) |>
  mutate(platform = if_else(platform == "X/Twitter", "Twitter/X", platform),
         source_num = ifelse(source == "Human", 1, 0)) |>
  group_by(response_id, order, platform) |>
  mutate(sum_source = sum(source_num)) |>
  ungroup() |>
  filter(sum_source == 1)

# Models ---------------------------------------------------------------------
m_pool_src <- lm(binary_response ~ source, data = d_pairs)
m_plat_src <- lm(binary_response ~ source * platform, data = d_pairs)

res <- bind_rows(
  avg_predictions(m_pool_src, by = "source") |> as_tibble() |>
    conf_int(estimate, std.error) |> mutate(comparison = "Pooled"),
  avg_predictions(m_plat_src, by = c("source", "platform")) |> as_tibble() |>
    conf_int(estimate, std.error) |> rename(comparison = platform)
) |>
  mutate(comparison = recode(comparison, "Twitter/X" = "X/Twitter"),
         comparison = factor(comparison, levels = rev(c("Pooled", "X/Twitter", "YouTube",
                                                         "TikTok", "Truth Social"))),
         source = factor(source, levels = c("Human", "AI")))

print(res |> filter(source == "AI") |> select(comparison, estimate, lb95, up95))

# Plot -----------------------------------------------------------------------
p <- ggplot(res, aes(y = comparison, x = estimate, fill = source)) +
  geom_col(width = 0.75, color = "black", linewidth = 0.3,
           position = position_dodge(width = 0.85)) +
  geom_errorbar(aes(xmin = lb95, xmax = up95), width = 0.25, linewidth = 0.7,
                color = "black", position = position_dodge(width = 0.85)) +
  geom_vline(xintercept = 0.5, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  scale_fill_manual(values = c("Human" = "tomato2", "AI" = "steelblue"),
                    name = "Post source", breaks = c("AI", "Human")) +
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  coord_cartesian(xlim = c(0, 1)) +
  labs(x = "Proportion of posts classified as AI (paired with a human post)", y = NULL) +
  theme_minimal(base_size = 22) +
  theme(legend.position = "right",
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 20),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = 24, color = "#22211d"),
        axis.text.x = element_text(size = 20),
        axis.title.x = element_text(size = 22, margin = margin(t = 12)))

ggsave(out, p, width = 14, height = 8, dpi = 300, bg = "white")
message("Saved: ", out)
