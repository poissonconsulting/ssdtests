test_that("gamma", {
  test_dist2("gamma")
})

test_that("gamma parameters are extremely unstable", {
  data <- ssddata::ccme_boron
  data$Other <- data$Conc
  data$Conc <- data$Conc / max(data$Conc)

  # gamma shape change from 913 to 868 on most recent version
  set.seed(102)
  fits <- ssd_fit_dists(data, dists = c("lnorm", "gamma"), right = "Other", rescale = FALSE, computable = FALSE)

  tidy <- tidy(fits)
  expect_s3_class(tidy, "tbl")
  skip_on_ci() # not sure why gamma shape is 908 on GitHub actions windows and 841 on GitHub actions ubuntu
  expect_snapshot_data(tidy, "tidy_gamma_unstable", digits = 1)
})
