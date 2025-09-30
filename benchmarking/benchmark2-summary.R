library(data.table)
library(ggplot2)

################################################################################
# data import
bench2 <-
  list.files("bench2_results", full.names = TRUE) |>
  lapply(readRDS) |>
  lapply(setDT) |>
  rbindlist()

mem <-
  list.files("./logs2/mem", pattern = "\\.tsv$", full.names = TRUE, recursive = TRUE) |>
  lapply(fread) |>
  rbindlist()
mem[, subconditions := grepl("pccc_v3.1s", method)]
mem[, method := sub("s$", "", method)]
setnames(mem, "flag_method", "flag.method")

bench2_summary <-
  bench2[, .(median_time_seconds = median(time_seconds)) , by = .(data_class, subjects, encounters, seed, method, subconditions, flag.method) ]
mem_summary <-
  mem[,    .(median_rss_kib = median(max_rss_kib)),        by = .(data_class, subjects,             seed, method, subconditions, flag.method)]

bench2_summary <-
  merge(bench2_summary, mem_summary, all = TRUE)

bench2_summary[!is.na(median_time_seconds) & !is.na(median_rss_kib)]

bench2_summary[, data_class := fcase(data_class == "DF", "data.frame",
                                     data_class == "DT", "data.table",
                                     data_class == "TBL", "tibble")]

# relative time
bench2_summary[!is.na(median_time_seconds), df_median := median_time_seconds[data_class == "data.frame"], by = .(subjects, encounters, method, subconditions, flag.method)]
bench2_summary[, relative_time := (median_time_seconds / df_median)]
bench2_summary[, df_median := NULL]

################################################################################
# Plotting helpers
cclr <- c("data.table" = "#8da0cb", "tibble" = "#fc8d62", "data.frame" = "#66c2a5")
ctyp <- c("data.frame" = 2, "data.table" = 1, "tibble" = 3)


################################################################################
# plot
facet_spec <- . ~ fifelse(subconditions,
                          paste(method, "(with subconditions)"),
                          method) + flag.method
g <-
  ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters, y = median_time_seconds,
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
  facet_wrap(facet_spec, nrow = 2) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

ggsave(file = "benchmark2.pdf", plot = g, width = 12, height = 7)
ggsave(file = "benchmark2.svg", plot = g, width = 12, height = 7)

gr <-
  ggplot(bench2_summary) +
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

ggsave(file = "benchmark2-relative.svg", plot = gr, width = 12, height = 7)
ggsave(file = "benchmark2-relative.pdf", plot = gr, width = 12, height = 7)

g <-
  ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters, y = median_rss_kib / (1024^2),
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
  ylab("median RSS (GiB)") +
  facet_wrap(facet_spec, nrow = 2) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

#
# Combined plot
#

facet_spec <- . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)

outtable <- list()

for (mt in unique(bench2_summary$method)) {
  for (sc in unique(bench2_summary$subconditions)) {
    for (dc in unique(bench2_summary$data_class)) {
      for (fm in unique(bench2_summary$flag.method)) {
        thisdt <- subset(bench2_summary, method == mt & subconditions == sc & data_class == dc & flag.method == fm)
        if (nrow(thisdt)) {
          ats_loess <- loess(log10(median_time_seconds) ~ log10(encounters), data = thisdt)
          ats <- predict(ats_loess, se = TRUE)

          mem_loess <- loess(log10(median_rss_kib) ~ log10(encounters), data = thisdt)
          mem <- predict(mem_loess, se = TRUE)

          bench2_summary[method == mt & subconditions == sc & data_class == dc & flag.method == fm & !is.na(median_time_seconds) & !is.na(encounters),
                         `:=`(
                              time_smoothed_y   = 10^(ats$fit),
                              time_smoothed_lwr = 10^(ats$fit - 1.96 * ats$se.fit),
                              time_smoothed_upr = 10^(ats$fit + 1.96 * ats$se.fit)
                              )]

          bench2_summary[method == mt & subconditions == sc & data_class == dc & flag.method == fm & !is.na(median_rss_kib) & !is.na(encounters),
                         `:=`(
                              mem_smoothed_y   = 10^(mem$fit),
                              mem_smoothed_lwr = 10^(mem$fit - 1.96 * mem$se.fit),
                              mem_smoothed_upr = 10^(mem$fit + 1.96 * mem$se.fit)
                              )]
          if (dc != "data.frame") {
            rts_loess <- loess(relative_time ~ log10(encounters), data = thisdt)
            rts <- predict(rts_loess, se = TRUE)
            bench2_summary[method == mt & subconditions == sc & data_class == dc & flag.method == fm & !is.na(relative_time) & !is.na(encounters),
                           `:=`(
                                rel_time_smoothed_y   = rts$fit,
                                rel_time_smoothed_lwr = rts$fit - 1.96 * rts$se.fit,
                                rel_time_smoothed_upr = rts$fit + 1.96 * rts$se.fit
                                )]
          }

          outtable <-
            c(outtable,
              list(
                data.table(
                  method = mt, subconditions = sc, data_class = dc, flag.method = fm, encounters = 10^(3:6),
                  time_seconds  = 10^(predict(ats_loess, newdata = data.frame(encounters = 10^(3:6)))),
                  memory        = 10^(predict(mem_loess, newdata = data.frame(encounters = 10^(3:6)))),
                  relative_time = if (dc != "data.table") {predict(rts_loess, newdata = data.frame(encounters = 10^(3:6)))} else {1.0}
                )
              )
          )

        }
      }
    }
  }
}

outtable <- rbindlist(outtable)
saveRDS(outtable, file = "outtable.rds")

bench2_summary[data_class == "data.frame",
               `:=`(
                    rel_time_smoothed_y   = 1,
                    rel_time_smoothed_lwr = 1,
                    rel_time_smoothed_upr = 1
                    )]


# use this data set to identify the flag.method
setkey(bench2_summary,
       method, data_class, subconditions, flag.method, subjects)
fmpt <-
  bench2_summary[, .(encounters = max(encounters, na.rm = TRUE)), keyby = .(method, data_class, subconditions, flag.method, subjects)]
fmpt <- bench2_summary[fmpt, on = c(key(fmpt), "encounters")]
fmpt <- unique(fmpt)

g1 <-
  ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters,
      y = time_smoothed_y,
      ymin = time_smoothed_lwr,
      ymax = time_smoothed_upr,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      groupby = flag.method
  ) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  #geom_point(mapping = aes(y = median)) +
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

g2 <-
  ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters,
      y = rel_time_smoothed_y,
      ymin = rel_time_smoothed_lwr,
      ymax = rel_time_smoothed_upr,
      color = data_class,
      fill = data_class,
      linetype = data_class,
      groupby = flag.method
  ) +
  geom_line() +
  geom_ribbon(alpha = 0.2, mapping = aes(color = NULL)) +
  geom_point(data = fmpt[data_class != "data.frame"], mapping = aes(shape = flag.method), size = 2) +
  scale_y_continuous(breaks = seq(0.4, 1.4, by = 0.2)) +
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
    panel.grid.minor.x = element_blank(),
    legend.position = "bottom"
  )

g3 <-
  ggplot(bench2_summary) +
  theme_bw() +
  aes(x = encounters,
      y = mem_smoothed_y / (1024^2),
      ymin = mem_smoothed_lwr / (1024^2),
      ymax = mem_smoothed_upr / (1024^2),
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

svglite::svglite(filename = "benchmark2-composite.svg", width = 9, height = 7)

  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g2 + theme(axis.title.x = element_blank(), axis.text.x = element_blank(), strip.text = element_blank(), strip.background = element_blank()),
                    g3 + theme(strip.text = element_blank(), strip.background = element_blank()),
                    ncol = 1, align = "v", common.legend = TRUE)

dev.off()

pdf(file = "benchmark2-composite.pdf", width = 12, height = 9)
  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g2 + theme(axis.title.x = element_blank(), axis.text.x = element_blank()),
                    g3,
                    ncol = 1, align = "v", common.legend = TRUE)
dev.off()
