library(data.table)
library(ggplot2)

################################################################################
# data import
benchmarks <-
  list(
    mimiciv = readRDS(file.path("mimic-iv", "benchmark.rds")),
    allcmrb = readRDS(file.path("all-cmrb", "benchmark.rds"))
  ) |>
  lapply(as.data.table) |>
  rbindlist(idcol = "set")

################################################################################
# from the standpoint of implimentation, the extra compuational cost of
# `flag.method = "cumulative"` is due to finding the first occurance of a
# condition and then the population of a data set reflecting that condition for
# all following encounters within a subject.
facet_spec <- . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method) + data_class

## Expected Time
g <-
  ggplot(data = benchmarks[flag.method == "current"]) +
  theme_bw() +
  aes(
    x = encounters,
    y = time_smooth,
    ymin = time_smooth_lwr,
    ymax = time_smooth_upr,
    color = set,
    linetype = set
  ) +
  geom_line() +
  scale_x_log10() +
  scale_y_log10() +
  facet_wrap(facet_spec, )

# NOTE: as of 17 December 2025 inspection of the results show that the mimic-iv
# data consistently took more time to process than the all-cmrb set.  This is
# since the mimic-iv-demo data is closer to real data this should be the set
# used to report the benchmarks.
mimiciv <- subset(benchmarks, set == "mimiciv")

################################################################################
# Plotting helpers
# colors from the Dark2 pallete
cclr <- c("data.table" = "#1b9e77", "tibble" = "#7570b3", "data.frame" = "#d95f02")
ctyp <- c("current" = 3, "cumulative" = 1)

facet_spec <-
  . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)

common_layers <-
  list(
    ggplot2::theme_bw(),
    ggplot2::aes(
      x = encounters,
      color = data_class,
      fill = data_class,
      linetype = flag.method
    ),
    ggplot2::scale_x_log10(
      name = "Encounters",
      labels = scales::label_number(scale_cut = scales::cut_si(""))
    ),
    ggplot2::scale_fill_manual(name = "Data Class", values = cclr),
    ggplot2::scale_color_manual(name = "Data Class", values = cclr),
    ggplot2::scale_linetype_manual(name = "Flag Method", values = ctyp),
    ggplot2::annotation_logticks(base = 10, side = "b"),
    ggplot2::facet_wrap(facet_spec, nrow = 1),
    ggplot2::theme(
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
  )

g_expected_time <-
  ggplot(mimiciv) +
  common_layers +
  aes(y = time_smooth, ymin = time_smooth_lwr, ymax = time_smooth_upr) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  scale_y_log10(
    name = "Time (seconds)",
    breaks = c(0.1, 10, 60, 120, 300, 600),
    labels = scales::label_comma()
  )

g_relative_time <-
  ggplot2::ggplot(mimiciv[data_class != "data.frame"]) +
  common_layers +
  ggplot2::aes(y = relative_time) +
  ggplot2::geom_line() +
  ggplot2::geom_hline(yintercept = 1, color = cclr["data.frame"], linetype = 2) +
  ggplot2::scale_y_continuous(
    name = "Relative expected run time\n(vs data.frame)",
    transform = "log2"
  )

g_memory <-
  ggplot(mimiciv) +
  common_layers +
  aes(
    y = max_rss_kib_smooth / (1024^2),
    ymin = max_rss_kib_smooth_lwr / (1024^2),
    ymax = max_rss_kib_smooth_lwr / (1024^2)
  ) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  scale_y_continuous(
    name = "Memory (GiB)",
    transform = "log2",
    breaks = 2^(seq(-1, 5, by = 1)),
    labels = scales::label_comma()
  )

composite <-
  ggpubr::ggarrange(
    g_expected_time + theme(axis.title.x = element_blank()),
    g_relative_time + theme(axis.title.x = element_blank()),
    g_memory,
    ncol = 1, align = "v", common.legend = TRUE
  )

pdf(file = "benchmark-composite.pdf", width = 12, height = 9)
  print(composite)
dev.off()

png(file = "benchmark-composite.png", width = 12, height = 9)
  print(composite)
dev.off()

svglite::svglite(filename = "benchmark-composite.svg", width = 12, height = 9)
  print(composite)
dev.off()

################################################################################
#                                 End of File                                  #
################################################################################
