library(data.table)
library(ggplot2)

bench1 <-
  list.files("bench1_results", full.names = TRUE) |>
  lapply(readRDS) |>
  lapply(setDT) |>
  rbindlist()


#ggplot(bench1) +
#  theme_bw() +
#  aes(x = factor(subjects), y = time_seconds, fill = data_class) +
#  geom_violin() +
#  scale_y_log10() +
#  annotation_logticks(side = "l") +
#  facet_grid(. ~ method + subconditions)

bench1[, data_class := fcase(data_class == "DF", "data.frame",
                             data_class == "DT", "data.table",
                             data_class == "TBL", "tibble")]

cclr <- c("data.table" = "#8da0cb", "tibble" = "#fc8d62", "data.frame" = "#66c2a5")

ggplot(bench1) +
  theme_bw() +
  aes(x = subjects, y = time_seconds, color = data_class, fill = data_class, linetype = data_class) +
  #geom_point() +
  stat_smooth() +
  scale_x_log10(labels = scales::label_comma()) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = c("data.frame" = 2, "data.table" = 1, "tibble" = 3)) +
  annotation_logticks() +
  xlab("Encounters") +
  ylab("Time (seconds)") +
  facet_wrap(. ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "bench1.svg", width = 7, height = 7)
