library(data.table)
library(ggplot2)

bench1 <-
  list.files("bench1_results", full.names = TRUE) |>
  lapply(readRDS) |>
  lapply(setDT) |>
  rbindlist()

bench1[, data_class := fcase(data_class == "DF", "data.frame",
                             data_class == "DT", "data.table",
                             data_class == "TBL", "tibble")]

cclr <- c("data.table" = "#8da0cb", "tibble" = "#fc8d62", "data.frame" = "#66c2a5")
ctyp <- c("data.frame" = 2, "data.table" = 1, "tibble" = 3)

bench1_summary <-
  bench1[,
         .(mean = mean(time_seconds), median = median(time_seconds), q3 = quantile(time_seconds, prob = 0.75), q1 = quantile(time_seconds, prob = 0.25))
         , by = .(data_class, subjects, encounters, method, subconditions, flag.method)
         ]

# relative time
bench1_summary[, df_mean := mean[data_class == "data.frame"], by = .(subjects, encounters, method, subconditions, flag.method)]
bench1_summary[, rt := (mean / df_mean)]

ggplot(bench1_summary) +
  theme_bw() +
  aes(x = subjects,
      ymin = q1,
      y = median,
      ymax = q3,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      shape = data_class
  ) +
  geom_point() +
  geom_line() +
  scale_x_log10(labels = scales::label_comma()) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "Data Class", values = ctyp) +
  annotation_logticks() +
  xlab("Encounters") +
  ylab("Time (seconds)") +
  facet_wrap(. ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark1.svg", width = 7, height = 7)

ggplot(bench1_summary) +
  theme_bw() +
  aes(x = encounters, y = rt, color = data_class, fill = data_class, linetype = data_class) +
  stat_smooth(method = "loess", formula = y ~ x) +
  scale_y_continuous() +
  scale_x_log10(labels = scales::label_comma()) +
  annotation_logticks(sides = "b") +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  xlab("Encounters") +
  ylab("Relative expected run time (vs data.frame)") +
  facet_wrap(. ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)) +
  theme(
    panel.grid.minor.x = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark1-relative.svg", width = 7, height = 7)
