library(tidyverse)
library(patchwork)

# --- Panel 1: The mechanism flow ---

# Color palette matching the presentation
left_col <- "#005EB8"   # blue
right_col <- "#C93312"  # red
grey_col <- "#768692"
bg_col <- "white"

# Create user dots data for three periods
set.seed(42)

# Pre-ban: mixed platform
n_left_pre <- 30
n_right_pre <- 70
pre <- tibble(
  x = runif(n_left_pre + n_right_pre, 0, 10),
  y = runif(n_left_pre + n_right_pre, 0, 10),
  group = c(rep("Left-leaning", n_left_pre), rep("Right-leaning", n_right_pre)),
  period = "Pre-Ban"
)

# During ban: left mostly leaves, right stays
n_left_during <- 8
n_right_during <- 62
during <- tibble(
  x = runif(n_left_during + n_right_during, 0, 10),
  y = runif(n_left_during + n_right_during, 0, 10),
  group = c(rep("Left-leaning", n_left_during), rep("Right-leaning", n_right_during)),
  period = "During Ban"
)

# Post-ban: some left returns, but not all
n_left_post <- 20
n_right_post <- 70
post <- tibble(
  x = runif(n_left_post + n_right_post, 0, 10),
  y = runif(n_left_post + n_right_post, 0, 10),
  group = c(rep("Left-leaning", n_left_post), rep("Right-leaning", n_right_post)),
  period = "Post-Ban"
)

dots_data <- bind_rows(pre, during, post) %>%
  mutate(period = factor(period, levels = c("Pre-Ban", "During Ban", "Post-Ban")))

p_dots <- ggplot(dots_data, aes(x = x, y = y, color = group)) +
  geom_point(size = 3, alpha = 0.7) +
  facet_wrap(~period, ncol = 3) +
  scale_color_manual(values = c("Left-leaning" = left_col, "Right-leaning" = right_col)) +
  theme_minimal(base_size = 16, base_family = "Palatino") +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 14),
    strip.text = element_text(size = 18, face = "bold", color = "#012169"),
    plot.title = element_text(size = 20, face = "bold", color = "#012169", hjust = 0.5),
    plot.subtitle = element_text(size = 14, color = grey_col, hjust = 0.5),
    panel.border = element_rect(color = "#E8EDEE", fill = NA, linewidth = 0.5)
  ) +
  labs(
    title = "The Sorting Ratchet: Platform Composition on X",
    subtitle = "Each dot = a politically engaged user on the platform"
  )

# --- Panel 2: Bar chart showing the shares ---

shares_data <- tibble(
  period = factor(rep(c("Pre-Ban", "During Ban", "Post-Ban"), each = 2),
                  levels = c("Pre-Ban", "During Ban", "Post-Ban")),
  group = rep(c("Left-leaning", "Right-leaning"), 3),
  share_engagement = c(27, 73, 10, 90, 20, 80)
)

p_bars <- ggplot(shares_data, aes(x = period, y = share_engagement, fill = group)) +
  geom_col(position = "stack", width = 0.6, alpha = 0.85) +
  geom_text(aes(label = paste0(share_engagement, "%")),
            position = position_stack(vjust = 0.5),
            color = "white", size = 6, fontface = "bold") +
  scale_fill_manual(values = c("Left-leaning" = left_col, "Right-leaning" = right_col)) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  theme_minimal(base_size = 16, base_family = "Palatino") +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 14),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 14, color = grey_col),
    axis.text = element_text(size = 14),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 20, face = "bold", color = "#012169", hjust = 0.5),
    plot.subtitle = element_text(size = 14, color = grey_col, hjust = 0.5)
  ) +
  labs(
    title = "Share of Engagement (Likes) by Partisan Group",
    subtitle = "The rightward shift persists after the ban lifts",
    y = "Share of all likes"
  )

# --- Panel 3: Mechanism diagram ---

mechanism_data <- tibble(
  x = c(1, 3, 5),
  y = c(1, 1, 1),
  label = c(
    "Ban gets\npoliticized",
    "Asymmetric\ncompliance",
    "Persistent\nsorting"
  ),
  sublabel = c(
    "Right opposes ban\nLeft supports it",
    "Right circumvents (VPN)\nLeft exits to Bluesky",
    "Platform skews right\nEven after ban lifts"
  )
)

arrow_data <- tibble(
  x = c(1.55, 3.55),
  xend = c(2.45, 4.45),
  y = c(1, 1),
  yend = c(1, 1)
)

# Ratchet arrow (one-way)
p_mechanism <- ggplot() +
  # Boxes
  geom_tile(data = mechanism_data, aes(x = x, y = y),
            width = 1.3, height = 1.2, fill = "#E8EDEE", color = "#012169", linewidth = 0.8) +
  # Main labels
  geom_text(data = mechanism_data, aes(x = x, y = y + 0.2, label = label),
            size = 5.5, fontface = "bold", color = "#012169", family = "Palatino", lineheight = 0.9) +
  # Sub labels
  geom_text(data = mechanism_data, aes(x = x, y = y - 0.25, label = sublabel),
            size = 3.8, color = grey_col, family = "Palatino", lineheight = 0.9) +
  # Arrows
  geom_segment(data = arrow_data, aes(x = x, xend = xend, y = y, yend = yend),
               arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
               linewidth = 1.2, color = right_col) +
  # One-way label
  annotate("text", x = 3, y = 0.2, label = 'The ratchet only turns one way',
           size = 5, fontface = "italic", color = right_col, family = "Palatino") +
  coord_cartesian(xlim = c(0, 6), ylim = c(-0.1, 1.8)) +
  theme_void(base_family = "Palatino") +
  theme(
    plot.title = element_text(size = 20, face = "bold", color = "#012169", hjust = 0.5),
    plot.margin = margin(10, 10, 10, 10)
  ) +
  labs(title = "The Sorting Ratchet Mechanism")

# --- Combine ---
final <- p_mechanism / p_dots / p_bars +
  plot_layout(heights = c(1, 1.2, 1.2))

ggsave("/Users/tb186/Dropbox/talks/talks_git_repo/twitter_ban/output/sorting_ratchet_diagram.png",
       final, width = 14, height = 16, dpi = 300, bg = "white")

cat("Done! Saved to output/sorting_ratchet_diagram.png\n")
