test_that("plot geoms", {
  skip_on_ci()

  gp <- ggplot2::ggplot(boron_pred) +
    geom_ssdpoint(data = ssddata::ccme_boron, ggplot2::aes(x = Conc)) +
    geom_ssdsegment(data = ssddata::ccme_boron, ggplot2::aes(x = Conc, xend = Conc * 2)) +
    geom_hcintersect(xintercept = 100, yintercept = 0.5) +
    geom_xribbon(
      ggplot2::aes(xmin = lcl, xmax = ucl, y = proportion),
      alpha = 1 / 3
    )
  expect_snapshot_plot(gp, "geoms_all")
})

test_that("ssd_plot censored data", {
  skip_on_ci()

  data <- ssddata::ccme_boron
  data$Other <- data$Conc * 2
  expect_snapshot_plot(ssd_plot(data, boron_pred, right = "Other"), "boron_cens_pred_ribbon")
})
