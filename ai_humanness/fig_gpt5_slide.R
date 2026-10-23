##############################################################################
# File-Name: fig_gpt5_slide.R
# Purpose: Slide-sized version of SI Figure S13 (GPT-5 zero-shot detection rate
#          on the same human-AI pairs respondents saw). Same data and models as
#          pnas_replication_package/code/12_gpt_direct_classifier_figure.R,
#          redrawn with larger text to match fig_detection_slide.R.
# Output: output/fig_gpt5_slide.png
##############################################################################

pacman::p_load(tidyverse, marginaleffects)

repl <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data"
out  <- "~/Dropbox/_art/talks/ai_humanness/output/fig_gpt5_slide.png"

# Data: most recent pairwise-detector output, as in 12_gpt_direct_classifier_figure.R
candidates <- list.files(repl, pattern = "^gpt_detector_sample_.*\\.csv$", full.names = TRUE)
input <- candidates[which.max(file.mtime(candidates))]
message("Using: ", input)

d_long <- read_csv(input, show_col_types = FALSE) |>
  filter(!is.na(parsed_answer)) |>
  transmute(text_id_left, text_id_right, platform, call_number, parsed_answer,
            `Post A_source` = source_left,
            `Post B_source` = source_right) |>
  pivot_longer(c(`Post A_source`, `Post B_source`), names_to = "side", values_to = "source") |>
  mutate(side            = str_remove(side, "_source"),
         binary_response = as.integer(parsed_answer == side),
         platform        = if_else(platform == "X/Twitter", "Twitter/X", platform))

# Models ---------------------------------------------------------------------
m_pool <- lm(binary_response ~ source, data = d_long)
m_plat <- lm(binary_response ~ source * platform, data = d_long)

res <- bind_rows(
  avg_predictions(m_pool, by = "source") |> as_tibble() |> mutate(comparison = "Pooled"),
  avg_predictions(m_plat, by = c("source", "platform")) |> as_tibble() |> rename(comparison = platform)
) |>
  mutate(comparison = recode(comparison, "Twitter/X" = "X/Twitter"),
         comparison = factor(comparison, levels = rev(c("Pooled", "X/Twitter", "YouTube",
                                                         "TikTok", "Truth Social"))),
         source = factor(source, levels = c("Human", "AI")))

print(res |> filter(source == "AI") |> select(comparison, estimate, conf.low, conf.high))

# Plot -----------------------------------------------------------------------
p <- ggplot(res, aes(y = comparison, x = estimate, fill = source)) +
  geom_col(width = 0.75, color = "black", linewidth = 0.3,
           position = position_dodge(width = 0.85)) +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), width = 0.25, linewidth = 0.7,
                color = "black", position = position_dodge(width = 0.85)) +
  geom_vline(xintercept = 0.5, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  scale_fill_manual(values = c("Human" = "tomato2", "AI" = "steelblue"),
                    name = "Post source", breaks = c("AI", "Human")) +
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  coord_cartesian(xlim = c(0, 1)) +
  labs(x = "Proportion of posts GPT-5 classified as AI (paired with a human post)", y = NULL) +
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
