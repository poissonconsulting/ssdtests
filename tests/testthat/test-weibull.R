test_that("weibull", {
  test_dist2("weibull")
})

test_that("weibull sometimes fails to converge", {
  withr::with_seed(97, {
    data <- data.frame(Conc = ssdtools::ssd_rweibull(1000))
  })
  skip()
  withr::with_seed(97, {
    expect_warning(
      fits <- ssdtools::ssd_fit_dists(data = data, dists = c("lnorm", "weibull")),
      "Distribution 'weibull' failed to converge \\(try rescaling data\\): ERROR: ABNORMAL_TERMINATION_IN_LNSRCH."
    )
  })
})

test_that("weibull bootstraps anona", {
  fit <- ssd_fit_dists(ssddata::anon_a, dists = "weibull")
  withr::with_seed(50, {
    hc <- ssd_hc(
      fit,
      nboot = 1000,
      ci = TRUE,
      ci_method = "weighted_samples",
      samples = TRUE
    )
  })
  expect_snapshot_data(hc, "hc_anona")
})
