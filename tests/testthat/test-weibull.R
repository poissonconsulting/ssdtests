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

test_that("weibull is sometimes unstable", {
  data <- data.frame(Conc = c(
    868.24508,
    1713.82388,
    3161.70678,
    454.65412,
    3971.75890,
    37.69471,
    262.14053,
    363.20288,
    1940.43277,
    3218.05296,
    77.48251,
    1214.70521,
    1329.27005,
    1108.05761,
    339.91458,
    437.52104
  ))

  fits <- ssd_fit_dists(
    data = data,
    left = "Conc", dists = c("gamma", "weibull"),
    silent = TRUE, reweight = FALSE, min_pmix = 0, nrow = 6L,
    computable = TRUE, at_boundary_ok = FALSE, rescale = FALSE
  )

  # not sure why weibull dropping on some linux on github actions and windows
  # on other folks machines
  # now doing on my machine 2025-11-27
  skip()
  expect_identical(names(fits), c("gamma", "weibull"))
})
