##############################################################################
# File-Name: fig_features2_slide.R
# Purpose: Figure 2 (emotive language features and PHI) in its original paper
#          design, with larger axis and legend text for the GenAI & Social
#          Science talk. Data, model, ordering, colors, and scale follow
#          pnas_replication_package/code/08_semantic_features.R.
#          Only change besides text size: "Optmism" label typo fixed.
# Output: output/fig_features2_slide.png
##############################################################################

pacman::p_load(tidyverse, marginaleffects, wesanderson)

repl <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data/bt_scores_features"
out  <- "~/Dropbox/_art/talks/ai_humanness/output/fig_features2_slide.png"

# Data: same recoding as 08_semantic_features.R ------------------------------
ft3 <- list.files(repl, pattern = "^post", full.names = TRUE) |>
  map_df(~ read_csv(.x, show_col_types = FALSE) |> mutate(platform = basename(.x))) |>
  janitor::clean_names() |>
  mutate(irony              = fct_relevel(irony_label, "non_irony"),
         offensive          = fct_relevel(offensive_label, "non-offensive"),
         hateful_speech     = fct_relevel(hate_label, "non-hate"),
         joy                = ifelse(emotion_label == "joy", 1, 0),
         optimism           = ifelse(emotion_label == "optimism", 1, 0),
         sadness            = ifelse(emotion_label == "sadness", 1, 0),
         sentiment_negative = ifelse(sentiment_label == "LABEL_0", 1, 0),
         sentiment_positive = ifelse(sentiment_label == "LABEL_2", 1, 0))

# Model: same specification as Figure 2 --------------------------------------
mod_p <- lm(normalized_ability ~ irony + offensive + hateful_speech +
              joy + optimism + sadness +
              sentiment_negative + sentiment_positive +
              n_chars + n_sents + avg_word_len + n_exclaims + pct_caps,
            data = ft3)

# Same ordering and categories as the paper figure ---------------------------
order_paper <- c("Hateful Speech", "Sentiment Negative", "Optimism", "Sadness",
                 "Joy", "Offensive", "Irony", "Sentiment Positive")

ft_res <- avg_slopes(mod_p) |>
  as_tibble() |>
  filter(term != "avg_word_len", !str_detect(term, "n_|pct")) |>
  mutate(yaxis    = str_to_title(str_replace_all(term, "_", " ")),
         yaxis    = factor(yaxis, levels = rev(order_paper)),
         category = case_when(yaxis %in% c("Joy", "Optimism", "Sadness")              ~ "Emotion",
                              yaxis %in% c("Hateful Speech", "Irony", "Offensive")   ~ "Civility",
                              str_detect(yaxis, "Sentiment")                          ~ "Sentiment"),
         category = fct_relevel(category, c("Sentiment", "Emotion", "Civility")))

print(ft_res |> select(yaxis, category, estimate, conf.low, conf.high))

# Plot: original design, larger text -----------------------------------------
p <- ggplot(ft_res, aes(y = yaxis, x = estimate, fill = category)) +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), linewidth = 1.5, width = 0) +
  geom_point(size = 7, shape = 21) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  xlab("Marginal Effects on PHI Scores (Positive = More Human)") +
  ylab("") +
  guides(fill = guide_legend(reverse = TRUE, override.aes = list(size = 7))) +
  scale_fill_manual(values = wes_palette("AsteroidCity2", 3),
                    name = "Emotive language features:") +
  xlim(-0.4, 0.4) +
  theme_minimal() +
  theme(text = element_text(color = "#22211d"),
        legend.position = "bottom",
        legend.title = element_text(size = 24),
        legend.text = element_text(size = 22),
        axis.text.y = element_text(size = 28, color = "#22211d"),
        axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 26, hjust = 1, margin = margin(t = 12)),
        plot.margin = margin(1, 1, 1, 1, "cm"))

ggsave(out, p, width = 14, height = 11, dpi = 300, bg = "white")
message("Saved: ", out)
