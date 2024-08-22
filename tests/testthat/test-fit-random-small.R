test_that("fail to fit random lnorm distributions with sample size 6 and pgtol 1e-8", {
  skip_on_ci()
  withr::with_seed(42, {
    expect_warning(expect_error(
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rlnorm(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm")
      }, "failed to fit"), "failed to converge")
  })
})

test_that("fail to fit random gamma distributions with sample size 6", {
  skip_on_ci()
  withr::with_seed(42, {
    expect_warning(expect_error(
      for(i in 1:10^4) {
        data <- data.frame(Conc = ssd_rgamma(6))
        fit <- ssd_fit_dists(data = data, dist = "lnorm")
      }, "failed to fit"), "failed to converge")
  })
})
