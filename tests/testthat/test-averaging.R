test_that("averaging results", {
  items <- data(package = "ssddata")$results[,"Item"]
  items <- items[items != "ssd_fits"]
  results <- data.frame(item = items)
  for(i in seq_len(nrow(results))) {
    print(results$item[i])
    code <- glue::glue("suppressWarnings(code <- ssdtools::ssd_fit_bcanz(data = ssddata::{results$item[i]}))")
    fit <- eval(parse(text = code))
    results$multi[i] <- ssdtools::ssd_hc(fit)$est
    results$weighted[i] <- ssdtools::ssd_hc(fit, multi_est = FALSE)$est
  }
  expect_snapshot_data(results, "averaging")
  results$change <- (results$weighted - results$multi) / results$weighted
  summary(results$change)
})
