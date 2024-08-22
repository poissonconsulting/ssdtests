test_that("lnorm fits with pearson1000", {
  data <- pearson1000
  fit <- ssd_fit_dists(data, dists = "lnorm")
  
  expect_snapshot_data(glance(fit), "glancepearson1000")
  expect_snapshot_data(tidy(fit), "tidypearson1000")
})
