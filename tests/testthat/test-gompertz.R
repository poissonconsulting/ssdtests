test_that("bootstrap gompertz with problem data", {
  set.seed(99)
  data <- data.frame(Conc = ssd_rgompertz(6, location = 0.6, shape = 0.07))
  fit <- ssdtools::ssd_fit_dists(data, dists = "gompertz")
  set.seed(99)
  hc <- ssd_hc(fit,
               ci = TRUE, nboot = 100, min_pboot = 0.8, ci_method = "weighted_arithmetic", multi_est = FALSE,
               samples = TRUE
  )
  expect_snapshot_data(hc, "hc_prob")
})
