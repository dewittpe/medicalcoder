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

mimiciv <- subset(benchmarks, set == "mimiciv")
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

g_expected_time <- function(data) {
  ggplot(data = data) +
  common_layers +
  aes(y = time_smooth, ymin = time_smooth_lwr, ymax = time_smooth_upr) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  scale_y_log10(
    name = "Time (seconds)",
    breaks = c(0.1, 10, 60, 120, 300, 600),
    labels = scales::label_comma()
  )
}

g_relative_time <- function(data) {
  ggplot2::ggplot(data = data) +
  common_layers +
  ggplot2::aes(y = relative_time) +
  ggplot2::geom_line() +
  ggplot2::geom_hline(yintercept = 1, color = cclr["data.frame"], linetype = 2) +
  ggplot2::scale_y_continuous(
    name = "Relative expected run time\n(vs data.frame)",
    transform = "log2",
    breaks = 2^(seq(-3, 3, by = 1))
  )
}

g_memory <- function(data) {
  ggplot(data = data) +
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
}

mimiciv_composite <-
  ggpubr::ggarrange(
    g_expected_time(benchmarks[set == "mimiciv"]) + theme(axis.title.x = element_blank()),
    g_relative_time(benchmarks[set == "mimiciv" & data_class != "data.frame"]) + theme(axis.title.x = element_blank()),
    g_memory(benchmarks[set == "mimiciv"]),
    ncol = 1, align = "v", common.legend = TRUE
  )
mimiciv_composite <-
  ggpubr::annotate_figure(
    mimiciv_composite,
    top = ggpubr::text_grob(sprintf("Benmarks for 'MIMIC-IV Demo' Data with medicalcoder version %s", packageVersion("medicalcoder")))
  )

all_cmrb_composite <-
  ggpubr::ggarrange(
    g_expected_time(benchmarks[set == "allcmrb"]) + theme(axis.title.x = element_blank()),
    g_relative_time(benchmarks[set == "allcmrb" & data_class != "data.frame"]) + theme(axis.title.x = element_blank()),
    g_memory(benchmarks[set == "allcmrb"]),
    ncol = 1, align = "v", common.legend = TRUE
  )

all_cmrb_composite <-
  ggpubr::annotate_figure(
    all_cmrb_composite,
    top = ggpubr::text_grob(sprintf("Benmarks for 'All Comorbidities' Data with medicalcoder version %s", packageVersion("medicalcoder")))
  )

for(x in c("mimiciv_composite", "all_cmrb_composite")) {
  f <- sprintf("benchmark_%s_composite.pdf", x)
  pdf(file = f, width = 12, height = 9)
    print(get(x = x))
  dev.off()

  f <- sprintf("benchmark_%s_composite.png", x)
  png(file = f, width = 12, height = 9)
    print(get(x = x))
  dev.off()

  f <- sprintf("benchmark_%s_composite.svg", x)
  svglite::svglite(filename = f, width = 12, height = 9)
    print(get(x = x))
  dev.off()
}



################################################################################
#                                 End of File                                  #
################################################################################
