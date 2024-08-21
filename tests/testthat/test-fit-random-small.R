test_that("fit random lnorm distributions with sample size 6", {
  withr::with_seed(42, {
    for(i in 1:10^4) {
      data <- data.frame(Conc = ssd_rlnorm(6))
      fit <- ssd_fit_dists(data = data, dist = "lnorm")
    }
  })
  expect_true(is.fitdists(fit))
})

test_that("fail to fit random lnorm distributions with sample size 6 and pgtol 1e-8", {
  withr::with_seed(42, {
    expect_warning(expect_error(
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rlnorm(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm", control = list(pgtol = 1e-8))
      }), "failed to converge")
  })
})

test_that("fit random gamma distributions with sample size 6", {
  withr::with_seed(42, {
    for(i in 1:10^4) {
      data <- data.frame(Conc = ssd_rgamma(6))
      fit <- ssd_fit_dists(data = data, dist = "gamma")
    }
  })
  expect_true(is.fitdists(fit))
})

test_that("fail to fit random gamma distributions with sample size 6", {
  withr::with_seed(42, {
    expect_warning(expect_error(
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rgamma(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm", control = list(pgtol = 1e-8))
      }), "failed to converge")
  })
})
