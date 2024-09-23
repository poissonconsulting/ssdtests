test_that("averaging results", {
  data_sets <- ssddata::ssd_data_sets()
  results <- data.frame(item = names(data_sets))
  for(i in seq_along(data_sets)) {
    suppressWarnings(fit <- ssdtools::ssd_fit_bcanz(data = data_sets[[i]]))
    results$multi[i] <- ssdtools::ssd_hc(fit)$est
    results$weighted[i] <- ssdtools::ssd_hc(fit, multi_est = FALSE)$est
  }
  expect_snapshot_data(results, "averaging")
  results$change <- (results$multi - results$weighted) / results$weighted
  summary(results$change)
})
