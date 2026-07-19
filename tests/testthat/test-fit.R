test_that("ssd_fit_dists computable = TRUE allows for fits without standard errors", {
  data <- ssddata::ccme_boron
  data$Other <- data$Conc
  data$Conc <- data$Conc / max(data$Conc)

  skip_on_ci()
  expect_warning(
    ssd_fit_dists(data, right = "Other", rescale = FALSE, at_boundary_ok = FALSE),
    "^Distribution 'lnorm_lnorm' failed to converge \\(try rescaling data\\)"
  )

  withr::with_seed(50, {
    fits <- ssd_fit_dists(data, right = "Other", dists = c("lgumbel", "llogis", "lnorm"), rescale = FALSE, at_boundary_ok = TRUE)
  })

  tidy <- tidy(fits)
  expect_s3_class(tidy, "tbl")
  expect_snapshot_data(tidy, "tidy_stable_computable", digits = 6)
})
