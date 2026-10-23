##############################################################################
# File-Name: fig_pooled_slide.R
# Purpose: Slide-sized version of Figure 1A (pooled marginal means of PHI by
#          post source). Same model as pnas_replication_package/code/06_analysis_bt.R,
#          redrawn wide with larger text for the GenAI & Social Science talk.
# Output: output/fig1_pooled_slide.png
##############################################################################

pacman::p_load(tidyverse, marginaleffects)

repl <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data/bt_scores"
out  <- "~/Dropbox/_art/talks/ai_humanness/output/fig1_pooled_slide.png"

# Data: same cleaning as 06_analysis_bt.R ------------------------------------
bt <- list.files(repl, pattern = "^bt_", full.names = TRUE) |>
  map_df(read_csv, show_col_types = FALSE) |>
  janitor::clean_names() |>
  mutate(model = case_when(model == "gpt_4omini"  ~ "gpt_4o_mini",
                           model == "llama3_3"    ~ "llama_3.3",
                           model == "llama_3_3"   ~ "llama_3.3",
                           model == "gpt_4o_fall" ~ "gpt_4o",
                           model == "gpt4o-mini"  ~ "gpt_4o_mini",
                           TRUE ~ model))

# Model and marginal means ---------------------------------------------------
m_human <- lm(normalized_ability ~ model, data = bt)

res <- avg_predictions(m_human, by = "model") |>
  as_tibble() |>
  mutate(model = recode(model,
                        "human"       = "Human",
                        "gpt_4"       = "GPT-4",
                        "gpt_4o"      = "GPT-4o",
                        "gpt_4o_mini" = "GPT-4o Mini",
                        "llama2_70b"  = "Llama 2",
                        "llama3_2_3b" = "Llama 3.2",
                        "llama_3.3"   = "Llama 3.3"),
         model = factor(model, levels = rev(c("Human", "GPT-4", "GPT-4o", "GPT-4o Mini",
                                              "Llama 2", "Llama 3.2", "Llama 3.3"))),
         family = case_when(model == "Human"           ~ "Human",
                            str_detect(model, "GPT")   ~ "GPT",
                            str_detect(model, "Llama") ~ "Llama"))

print(res |> select(model, estimate, conf.low, conf.high))

human_mean <- res |> filter(model == "Human") |> pull(estimate)

# Plot -----------------------------------------------------------------------
p <- ggplot(res, aes(x = estimate, y = model, fill = family)) +
  geom_vline(xintercept = human_mean, linetype = "dashed", color = "tomato2", linewidth = 0.8) +
  geom_vline(xintercept = 0, color = "gray75", linewidth = 0.5) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0, linewidth = 1.2) +
  geom_point(size = 6, shape = 21, stroke = 0.8) +
  geom_text(aes(label = sprintf("%.2f", estimate)), nudge_y = 0.32, size = 6, color = "gray25") +
  annotate("text", x = human_mean, y = 0.45, label = "Human mean",
           color = "tomato2", size = 6, hjust = -0.08) +
  scale_fill_manual(values = c(Human = "tomato2", GPT = "gray90", Llama = "steelblue")) +
  scale_x_continuous(limits = c(-0.4, 0.35), breaks = seq(-0.4, 0.3, 0.1)) +
  coord_cartesian(clip = "off") +
  labs(x = "Marginal mean of PHI (higher = more human)", y = NULL) +
  theme_minimal(base_size = 22) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = 22, color = "#22211d"),
        axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20, margin = margin(t = 12)),
        plot.margin = margin(25, 20, 10, 10))

ggsave(out, p, width = 13, height = 7.5, dpi = 300, bg = "white")
message("Saved: ", out)
