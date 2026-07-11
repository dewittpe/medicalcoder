library(data.table)
library(ggplot2)
library(mgcv)

################################################################################
# data import
bench <-
  list.files("bench_results", full.names = TRUE) |>
  sapply(readRDS, simplify = FALSE) |>
  lapply(setDT) |>
  rbindlist(idcol = "file", use.names = TRUE, fill = TRUE)
bench[, iter := as.integer(sub("(^.*)__(\\d+)\\.rds$", "\\2", file))]
bench[, data_class := fcase(grepl("DT__", file), "DT", grepl("DF__", file), "DF", grepl("TBL__", file), "TBL")]
bench[, file := NULL]

mem <-
  list.files("./logs/mem", pattern = "\\.tsv$", full.names = TRUE, recursive = TRUE) |>
  lapply(fread) |>
  rbindlist()
mem[, subconditions := grepl("pccc_v3.1s", method)]
mem[, method := sub("s$", "", method)]
setnames(mem, "flag_method", "flag.method")
mem[, out := NULL]

bench <-
  merge(
    x = bench,
    y = mem,
    all = TRUE,
    by = c("data_class", "subjects", "iter", "seed", "method", "subconditions", "flag.method"),
  )

bench[, data_class := fcase(data_class == "DF", "data.frame", data_class == "DT", "data.table", data_class == "TBL", "tibble")]

bench[, log10_time_seconds := log10(time_seconds)]
bench[, log10_encounters   := log10(encounters)]
bench[, log10_max_rss_kib  := log10(max_rss_kib)]

################################################################################
# use gams to smooth the data
b <-
  split(bench,
    by = c("data_class", "method", "subconditions", "flag.method"),
    sep = "__"
  )

time_gams <-
  lapply(b,
    function(x) {
      m <-
        try(
          mgcv::gam(log10_time_seconds ~ s(log10_encounters, bs = "bs"), data = x)
          ,
          silent = TRUE
        )
      if (inherits(m, "gam")) {
        p <- predict(m, newdata = x, se.fit = TRUE)
        lwr <- 10**(p$fit + qnorm(0.025) * p$se.fit)
        upr <- 10**(p$fit + qnorm(0.975) * p$se.fit)
        p   <- 10**p$fit
      } else {
        p   <- NA_real_
        lwr <- NA_real_
        upr <- NA_real_
      }
      set(x, j = "time_smooth",     value = p)
      set(x, j = "time_smooth_lwr", value = lwr)
      set(x, j = "time_smooth_upr", value = upr)
    })

mem_gams <-
  lapply(
    b,
    function(x) {
      m <-
        try(
          mgcv::gam(log10_max_rss_kib ~ s(log10_encounters, bs = "bs"), data = x)
          ,
          silent = TRUE
        )
      if (inherits(m, "gam")) {
        p <- predict(m, newdata = x, se.fit = TRUE)
        lwr <- 10**(p$fit + qnorm(0.025) * p$se.fit)
        upr <- 10**(p$fit + qnorm(0.975) * p$se.fit)
        p   <- 10**p$fit
      } else {
        p   <- NA_real_
        lwr <- NA_real_
        upr <- NA_real_
      }
      set(x, j = "max_rss_kib_smooth",     value = p)
      set(x, j = "max_rss_kib_smooth_lwr", value = lwr)
      set(x, j = "max_rss_kib_smooth_upr", value = upr)
    })

bench <- rbindlist(b)

################################################################################
# Plotting helpers
cclr <- c("data.table" = "#8da0cb", "tibble" = "#fc8d62", "data.frame" = "#66c2a5")
ctyp <- c("data.frame" = 3, "data.table" = 1, "tibble" = 2)

################################################################################
# plot
facet_spec <- . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method) + flag.method

g1 <-
  ggplot(bench) +
  theme_bw() +
  aes(
    x        = encounters,
    y        = time_seconds,
    color    = data_class,
    fill     = data_class,
    linetype = data_class,
    shape    = data_class
    ) +
  geom_point() +
  scale_x_log10(labels = scales::label_comma()) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "Data Class", values = ctyp) +
  annotation_logticks() +
  xlab("Encounters") +
  ylab("Time (seconds)") +
  facet_wrap(facet_spec, nrow = 2) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark.pdf", plot = g1, width = 12, height = 7)
ggsave(file = "benchmark.svg", plot = g1, width = 12, height = 7)

relative <-
  bench[, unique(.SD),  .SDcols = c("data_class", "encounters", "method", "subconditions", "flag.method", "time_smooth")]

relative[, relative_time := time_smooth[data_class == "data.frame"], by = .(encounters, method, subconditions, flag.method)][, relative_time := time_smooth / relative_time]

gr <-
  ggplot(relative) +
  theme_bw() +
  aes(x = encounters, y = relative_time, color = data_class, fill = data_class, linetype = data_class) +
  stat_smooth(method = "loess", formula = y ~ x) +
  scale_y_continuous() +
  scale_x_log10(labels = scales::label_comma()) +
  annotation_logticks(sides = "b") +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  xlab("Encounters") +
  ylab("Relative expected run time (vs data.frame)") +
  facet_wrap(facet_spec, nrow = 2) +
  theme(
    panel.grid.minor.x = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark-relative.svg", plot = gr, width = 12, height = 7)
ggsave(file = "benchmark-relative.pdf", plot = gr, width = 12, height = 7)

gm <-
  ggplot(bench) +
  theme_bw() +
  aes(
    x = encounters,
    y = max_rss_kib / (1024^2),
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
  ylab("RSS (GiB)") +
  facet_wrap(facet_spec, nrow = 2) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark-memory.svg", plot = gm, width = 12, height = 7)
ggsave(file = "benchmark-memory.pdf", plot = gm, width = 12, height = 7)

#
# Combined plot
#

facet_spec <- . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)

# use this dataset to identify the flag.method
fmpt <-
  unique(bench, by = c("data_class", "method", "subconditions", "flag.method", "time_smooth"))
fmpt <- fmpt[, .SD[time_smooth == max(time_smooth)], by = .(data_class, method, subconditions, flag.method)]

g1 <-
  ggplot(bench) +
  theme_bw() +
  aes(x = encounters,
      y = time_smooth,
      ymin = time_smooth_lwr,
      ymax = time_smooth_upr,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      groupby = flag.method
  ) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  geom_point(data = fmpt, mapping = aes(shape = flag.method), size = 2) +
  scale_x_log10(labels = scales::label_number(scale_cut = scales::cut_si(""))) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "flag.method", values = c("cumulative" = 2, "current" = 1)) +
  annotation_logticks() +
  xlab("Encounters") +
  ylab("Time (seconds)") +
  facet_wrap(facet_spec, nrow = 1) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )


fmpt2 <-
  unique(relative, by = c("data_class", "method", "subconditions", "flag.method", "time_smooth"))
fmpt2 <- fmpt2[, .SD[time_smooth == max(time_smooth)], by = .(data_class, method, subconditions, flag.method)]

g2 <-
  ggplot(relative) +
  theme_bw() +
  aes(x = encounters,
      y =    relative_time,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      groupby = flag.method
  ) +
  geom_line() +
  geom_point(data = fmpt2[data_class != "data.frame"], mapping = aes(shape = flag.method), size = 2) +
  scale_y_continuous(breaks = c(0.125, 0.25, 0.5, 1.0, 1.5, 2.0, 4.0, 6.0), limits = c(0, 2.0)) +
  scale_x_log10(labels = scales::label_number(scale_cut = scales::cut_si(""))) +
  annotation_logticks(sides = "b") +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "flag.method", values = c("cumulative" = 2, "current" = 1)) +
  xlab("Encounters") +
  ylab("Relative expected run time\n(vs data.frame)") +
  facet_wrap(facet_spec, nrow = 1) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

g3 <-
  ggplot(bench) +
  theme_bw() +
  aes(x = encounters,
      y = max_rss_kib_smooth / (1024^2),
      ymin = max_rss_kib_smooth_lwr / (1024^2),
      ymax = max_rss_kib_smooth_lwr / (1024^2),
      color = data_class,
      fill = data_class,
      linetype = data_class,
      groupby = flag.method
  ) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  geom_point(data = fmpt, mapping = aes(shape = flag.method), size = 2) +
  scale_x_log10(labels = scales::label_number(scale_cut = scales::cut_si(""))) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "flag.method", values = c("cumulative" = 2, "current" = 1)) +
  annotation_logticks() +
  xlab("Encounters") +
  ylab("Memory (GiB)") +
  facet_wrap(facet_spec, nrow = 1) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

svglite::svglite(filename = "benchmark-composite.svg", width = 9, height = 7)

  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g2 + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), strip.text = element_blank(), strip.background = element_blank()),
                    g3 + theme(strip.text = element_blank(), strip.background = element_blank()),
                    ncol = 1, align = "v", common.legend = TRUE)

dev.off()

png(filename = "benchmark-composite.png", width = 9, height = 7)

  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g2 + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), strip.text = element_blank(), strip.background = element_blank()),
                    g3 + theme(strip.text = element_blank(), strip.background = element_blank()),
                    ncol = 1, align = "v", common.legend = TRUE)

dev.off()

pdf(file = "benchmark-composite.pdf", width = 12, height = 9)
  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g2 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g3,
                    ncol = 1, align = "v", common.legend = TRUE)
dev.off()

################################################################################
# final step - save the outtable.rds file, this is tracked in the Makefile
benchmark <-
  merge(
    x = bench,
    y = relative,
    by = intersect(names(bench), names(relative))
  )
saveRDS(benchmark, file = "benchmark.rds")

################################################################################
#                                 End of File                                  #
################################################################################
