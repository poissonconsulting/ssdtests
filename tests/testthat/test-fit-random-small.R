test_that("ssd_fit_dists fits 10000 small lnorm samples with pgtol 1e-8", {
  skip_on_ci()
  withr::with_seed(42, {
    for (i in 1:10^4) {
      data <- data.frame(Conc = ssd_rlnorm(6))
      fit <- ssd_fit_dists(data = data, dists = "lnorm", control = list(pgtol = 1e-8))
    }
  })
  expect_s3_class(fit, "fitdists")
  expect_identical(names(fit), "lnorm")
})

test_that("ssd_fit_dists fits 10000 small gamma samples to lnorm", {
  skip_on_ci()
  withr::with_seed(42, {
    for (i in 1:10^4) {
      data <- data.frame(Conc = ssd_rgamma(6))
      fit <- ssd_fit_dists(data = data, dists = "lnorm")
    }
  })
  expect_s3_class(fit, "fitdists")
  expect_identical(names(fit), "lnorm")
})
