library(data.table)
library(ggplot2)

bench2 <-
  list.files("bench2_results", full.names = TRUE) |>
  lapply(readRDS) |>
  lapply(setDT) |>
  rbindlist()

bench2[, data_class := fcase(data_class == "DF", "data.frame",
                             data_class == "DT", "data.table",
                             data_class == "TBL", "tibble")]

cclr <- c("data.table" = "#8da0cb", "tibble" = "#fc8d62", "data.frame" = "#66c2a5")
ctyp <- c("data.frame" = 2, "data.table" = 1, "tibble" = 3)

bench2_summary <-
  bench2[,
         .(mean = mean(time_seconds), median = median(time_seconds), q3 = quantile(time_seconds, prob = 0.75), q1 = quantile(time_seconds, prob = 0.25))
         , by = .(data_class, encounters, method, subconditions, flag.method)
         ]

ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters,
      ymin = q1,
      y = median,
      ymax = q3,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      shape = data_class
  ) +
  #geom_errorbar(width = 0.5) +
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
  facet_wrap(
    . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method) + flag.method,
    nrow = 2
    ) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark2.svg", width = 12, height = 7)
