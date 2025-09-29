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
         , by = .(data_class, subjects, encounters, method, subconditions, flag.method)
         ]

# relative time
bench2_summary[, df_mean := mean[data_class == "data.frame"], by = .(subjects, encounters, method, subconditions, flag.method)]
bench2_summary[, rt := (mean / df_mean)]

# helper facet labeller
facet_spec <- . ~ fifelse(subconditions,
                          paste(method, "(with subconditions)"),
                          method) + flag.method

g <-
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
  aes(x = encounters, y = rt, color = data_class, fill = data_class, linetype = data_class) +
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


#
# Combined plot
#

facet_spec <- . ~ fifelse(subconditions, paste(method, "(with subconditions)"), method)

for (mt in unique(bench2_summary$method)) {
  for (sc in unique(bench2_summary$subconditions)) {
    for (dc in unique(bench2_summary$data_class)) {
      for (fm in unique(bench2_summary$flag.method)) {
        thisdt <- subset(bench2_summary, method == mt & subconditions == sc & data_class == dc & flag.method == fm)
        if (nrow(thisdt)) {
          ats <- loess(log10(median) ~ log10(encounters), data = thisdt)
          ats <- predict(ats, se = TRUE)
          bench2_summary[method == mt & subconditions == sc & data_class == dc & flag.method == fm,
                         `:=`(
                              time_smoothed_y   = 10^(ats$fit),
                              time_smoothed_lwr = 10^(ats$fit - 1.96 * ats$se.fit),
                              time_smoothed_upr = 10^(ats$fit + 1.96 * ats$se.fit)
                              )]
          if (dc != "data.frame") {
            rts <- loess(rt ~ log10(encounters), data = thisdt)
            rts <- predict(rts, se = TRUE)
            bench2_summary[method == mt & subconditions == sc & data_class == dc & flag.method == fm & !is.na(rt),
                           `:=`(
                                rel_time_smoothed_y   = rts$fit,
                                rel_time_smoothed_lwr = rts$fit - 1.96 * rts$se.fit,
                                rel_time_smoothed_upr = rts$fit + 1.96 * rts$se.fit
                                )]
          }
        }
      }
    }
  }
}

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
  bench2_summary[, .(encounters = max(encounters)), keyby = .(method, data_class, subconditions, flag.method, subjects)]
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
  scale_x_log10(labels = scales::label_comma()) +
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
  #geom_point(mapping = aes(y = rt)) +
  geom_point(data = fmpt[data_class != "data.frame"], mapping = aes(shape = flag.method), size = 2) +
  scale_y_continuous(breaks = seq(0.4, 1.4, by = 0.2)) +
  scale_x_log10(labels = scales::label_comma()) +
  annotation_logticks(sides = "b") +
  scale_fill_manual(name = "Data Class", values = cclr) +
  scale_color_manual(name = "Data Class", values = cclr) +
  scale_linetype_manual(name = "Data Class", values = ctyp) +
  scale_shape_manual(name = "flag.method", values = c("cumulative" = 2, "current" = 1)) +
  xlab("Encounters") +
  ylab("Relative expected run time (vs data.frame)") +
  facet_wrap(facet_spec, nrow = 1) +
  theme(
    panel.grid.minor.x = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(hjust = 0.75)
  )

svg(filename = "benchmark2-composite.svg", width = 12, height = 7)
  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank()), g2, ncol = 1, align = "v", common.legend = TRUE)
dev.off()

pdf(file = "benchmark2-composite.pdf", width = 12, height = 7)
  ggpubr::ggarrange(g1 + theme(axis.title.x = element_blank()), g2, ncol = 1, align = "v", common.legend = TRUE)
dev.off()
