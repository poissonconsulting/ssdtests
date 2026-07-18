test_that("bcanz hazard concentrations for all curated ssddata datasets", {
  datasets <- suppressMessages(ssddata::ssd_data_sets())

  hc <- lapply(names(datasets), function(name) {
    fit <- ssd_fit_bcanz(datasets[[name]], silent = TRUE)
    expect_s3_class(fit, "fitdists")
    hc <- ssd_hc_bcanz(fit)
    hc$dataset <- name
    hc$dists <- vapply(hc$dists, paste, character(1), collapse = ", ")
    hc[c("dataset", "proportion", "est", "dists")]
  })
  hc <- dplyr::bind_rows(hc)

  expect_snapshot_data(hc, "bcanz_hc", digits = 4)
})
