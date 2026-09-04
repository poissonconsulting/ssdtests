test_that("averaging results", {
  data_sets <- suppressMessages(ssddata::ssd_data_sets())
  results <- data.frame(item = names(data_sets))
  for (i in seq_along(data_sets)) {
    suppressWarnings(fit <- ssdtools::ssd_fit_bcanz(data = data_sets[[i]]))
    results$multi[i] <- ssdtools::ssd_hc(fit)$est
    results$weighted[i] <- ssdtools::ssd_hc(fit, est_method = "arithmetic")$est
  }
  expect_snapshot_data(results, "averaging")
})
