##############################################################################
# File-Name: fig_platform_model_slide.R
# Purpose: Slide-sized versions of
#   (1) Figure 1B: marginal means of PHI by post source and platform
#       (same model as pnas_replication_package/code/06_analysis_bt.R)
#   (2) SI Figure S6A: AI detection rate in human-AI pairs by AI model, pooled
#       (same data prep and model as pnas_replication_package/code/07_direct_pairs.R)
#   Redrawn with larger text for the GenAI & Social Science talk.
# Output: output/fig1_platform_slide.png, output/fig_detect_model_slide.png
##############################################################################

pacman::p_load(tidyverse, marginaleffects)

repl    <- "~/Dropbox/artigos/Generative_AI_humannes/pnas_replication_package/data"
out_dir <- "~/Dropbox/_art/talks/ai_humanness/output"

model_labels <- c("human"       = "Human",
                  "gpt_4"       = "GPT-4",
                  "gpt_4o"      = "GPT-4o",
                  "gpt_4o_mini" = "GPT-4o Mini",
                  "llama2_70b"  = "Llama 2",
                  "llama3_2_3b" = "Llama 3.2",
                  "llama_3.3"   = "Llama 3.3")
model_order  <- c("Human", "GPT-4", "GPT-4o", "GPT-4o Mini", "Llama 2", "Llama 3.2", "Llama 3.3")
fill_family  <- c(Human = "tomato2", GPT = "gray90", Llama = "steelblue")

fix_model <- function(x) {
  case_when(x == "gpt_4omini"  ~ "gpt_4o_mini",
            x == "llama3_3"    ~ "llama_3.3",
            x == "llama_3_3"   ~ "llama_3.3",
            x == "gpt_4o_fall" ~ "gpt_4o",
            x == "gpt4o-mini"  ~ "gpt_4o_mini",
            TRUE ~ x)
}

# BT scores (shared by both figures) -----------------------------------------
bt_files <- list.files(file.path(repl, "bt_scores"), pattern = "^bt_", full.names = TRUE)
platform_of <- function(f) {
  case_when(str_detect(f, "bt_ts_") ~ "Truth Social",
            str_detect(f, "bt_tt_") ~ "TikTok",
            str_detect(f, "bt_x_")  ~ "Twitter/X",
            str_detect(f, "bt_yt_") ~ "YouTube")
}
bt_raw <- map_df(bt_files, ~ read_csv(.x, show_col_types = FALSE) |>
                   mutate(platform = platform_of(.x)))

# (1) PHI by source and platform ----------------------------------------------
bt <- bt_raw |> janitor::clean_names() |> mutate(model = fix_model(model))

m_plat <- lm(normalized_ability ~ model * platform, data = bt)

res_plat <- avg_predictions(m_plat, by = c("model", "platform")) |>
  as_tibble() |>
  mutate(model    = factor(recode(model, !!!model_labels), levels = rev(model_order)),
         platform = factor(recode(platform, "Twitter/X" = "X/Twitter"),
                           levels = c("X/Twitter", "YouTube", "TikTok", "Truth Social")),
         family   = case_when(model == "Human"           ~ "Human",
                              str_detect(model, "GPT")   ~ "GPT",
                              str_detect(model, "Llama") ~ "Llama"))

human_plat <- res_plat |> filter(model == "Human") |> select(platform, human = estimate)
print(human_plat)

p1 <- ggplot(res_plat, aes(x = estimate, y = model, fill = family)) +
  geom_vline(data = human_plat, aes(xintercept = human),
             linetype = "dashed", color = "tomato2", linewidth = 0.8) +
  geom_vline(xintercept = 0, color = "gray75", linewidth = 0.5) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0, linewidth = 1.1) +
  geom_point(size = 5, shape = 21, stroke = 0.8) +
  scale_fill_manual(values = fill_family) +
  scale_x_continuous(breaks = c(-0.5, 0, 0.5)) +
  facet_wrap(~platform, nrow = 1) +
  labs(x = "Marginal mean of PHI (higher = more human); dashed line = human mean", y = NULL) +
  theme_minimal(base_size = 22) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.spacing.x = unit(1.5, "lines"),
        strip.text = element_text(size = 24, face = "bold"),
        axis.text.y = element_text(size = 22, color = "#22211d"),
        axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20, margin = margin(t = 12)))

ggsave(file.path(out_dir, "fig1_platform_slide.png"), p1, width = 15, height = 7.5, dpi = 300, bg = "white")

# (2) Detection rate by AI model, pooled --------------------------------------
bt_models <- bt_raw |>
  select(platform, text_id = Text_ID, model) |>
  distinct(platform, text_id, .keep_all = TRUE)

d_pairs <- read_csv(file.path(repl, "pairs_survey_clean.csv"), show_col_types = FALSE) |>
  filter(att_check_sum == 0) |>
  mutate(platform = if_else(platform == "X/Twitter", "Twitter/X", platform),
         source_num = ifelse(source == "Human", 1, 0)) |>
  group_by(response_id, order, platform) |>
  mutate(sum_source = sum(source_num)) |>
  ungroup() |>
  filter(sum_source == 1) |>
  left_join(bt_models, by = c("platform", "text_id")) |>
  mutate(model = if_else(source == "Human", "human", fix_model(model)))

m_pool <- lm(binary_response ~ model, data = d_pairs)

res_model <- avg_predictions(m_pool, by = "model") |>
  as_tibble() |>
  filter(model != "human") |>
  mutate(model  = factor(recode(model, !!!model_labels), levels = rev(model_order[-1])),
         family = if_else(str_detect(model, "GPT"), "GPT", "Llama"))

print(res_model |> select(model, estimate, conf.low, conf.high))

p2 <- ggplot(res_model, aes(x = estimate, y = model, fill = family)) +
  geom_col(width = 0.7, color = "black", linewidth = 0.3) +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.25, linewidth = 0.7) +
  geom_vline(xintercept = 0.5, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  geom_text(aes(x = conf.high + 0.02, label = sprintf("%.1f%%", 100 * estimate)),
            hjust = 0, size = 7, color = "gray25") +
  scale_fill_manual(values = fill_family) +
  scale_x_continuous(breaks = seq(0, 1, 0.1), labels = scales::percent) +
  coord_cartesian(xlim = c(0, 0.8)) +
  labs(x = "AI post correctly identified (paired with a human post); dashed line = chance", y = NULL) +
  theme_minimal(base_size = 22) +
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.text.y = element_text(size = 24, color = "#22211d"),
        axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20, margin = margin(t = 12)))

ggsave(file.path(out_dir, "fig_detect_model_slide.png"), p2, width = 14, height = 7.5, dpi = 300, bg = "white")
message("Saved both figures to ", out_dir)
