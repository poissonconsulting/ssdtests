test_that("fit random lnorm distributions with sample size 6 and pgtol 1e-8", {
  skip_on_ci()
  withr::with_seed(42, {
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rlnorm(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm")
      }
  })
  expect_true(TRUE)
})

test_that("fit random lnorm distributions with sample size 6", {
  skip_on_ci()
  withr::with_seed(42, {
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rgamma(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm")
      }
  })
  expect_true(TRUE)
})
