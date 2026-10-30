# Deck figure: share of users we could not collect, by ideology decile.
# Mirrors Module 5 of code/09_missing_data_analysis.R in SVTR_twitter_ban, but
# on the recentered ideology scale used throughout the deck (positive = right).
suppressPackageStartupMessages({ library(tidyverse); library(arrow); library(scales) })

proj <- "/Users/tb186/Dropbox/artigos/SVTR_twitter_ban"
out  <- "/Users/tb186/Dropbox/_art/talks/twitter_ban/output/fig_uncollected_deciles.png"

model_row <- read_csv(file.path(proj, "output/model_row_counts.csv"), show_col_types = FALSE) %>%
  rename(user_screename = domain)
w_scores  <- read_csv(file.path(proj, "data/user_reescaled_scores.csv"), show_col_types = FALSE) %>%
  rename(w_user_dim1 = dim1_res)
timeline_users <- read_parquet(file.path(proj, "data/processed_data/timelines_2024_all_combined.parquet"),
                               col_select = "user_screename") %>%
  mutate(user_screename = str_trim(str_remove_all(user_screename, "data/2025_08_11_scrape/|.csv"))) %>%
  distinct() %>% pull(user_screename)

df <- model_row %>%
  left_join(w_scores, by = "user_screename") %>%
  mutate(ideology = -1 * w_user_dim1,
         matched  = user_screename %in% timeline_users,
         decile   = ntile(ideology, 10))

cat("users:", nrow(df), " collected:", sum(df$matched), " not collected:", sum(!df$matched), "\n")

decile_props <- df %>%
  group_by(decile) %>%
  summarise(prop = mean(!matched), n = n(), .groups = "drop")
overall <- mean(!df$matched)
print(decile_props); cat("overall:", overall, "\n")

navy <- "#041E42"; red <- "#D50032"; grey_col <- "#6b7280"; bar <- "#899DA4"

p <- ggplot(decile_props, aes(x = factor(decile), y = prop)) +
  geom_col(fill = bar, width = 0.7) +
  geom_hline(yintercept = overall, linetype = "dashed", color = red, linewidth = 0.9) +
  annotate("text", x = 10.2, y = overall + 0.012, hjust = 1,
           label = paste0("All users: ", percent(overall, accuracy = 0.1)),
           size = 5.5, color = red, fontface = "bold", family = "Palatino") +
  geom_text(aes(label = percent(prop, accuracy = 1)), vjust = -0.5, size = 4.8,
            color = navy, family = "Palatino") +
  scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.12))) +
  scale_x_discrete(labels = c("1\nMost left", "2", "3", "4", "5", "6", "7", "8", "9", "10\nMost right")) +
  labs(x = "Ideology decile (pre-ban scores)", y = "Share of users we could not collect") +
  theme_minimal(base_size = 20, base_family = "Palatino") +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
        axis.title = element_text(size = 18, color = navy),
        axis.text = element_text(size = 16, color = grey_col),
        plot.margin = margin(8, 12, 4, 4))

ggsave(out, p, width = 12, height = 7, dpi = 300, bg = "white")
cat("saved", out, "\n")
