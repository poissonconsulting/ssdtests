test_that("ssd_hc passing all boots ccme_chloride lnorm_lnorm", {
  fits <- ssd_fit_dists(ssddata::ccme_chloride,
    min_pmix = 0.0001, at_boundary_ok = TRUE,
    dists = c("lnorm_lnorm", "llogis_llogis")
  )
  skip_on_ci()
  withr::with_seed(102, {
    hc <- ssd_hc(fits, ci = TRUE, nboot = 1000, average = FALSE)
  })
  expect_s3_class(hc, "tbl_df")
  expect_snapshot_boot_data(hc, "hc_cis_chloride50")
})


test_that("ssd_hc cis with error and multiple dists", {
  withr::with_seed(99, {
    conc <- ssd_rlnorm_lnorm(30, meanlog1 = 0, meanlog2 = 1, sdlog1 = 1 / 10, sdlog2 = 1 / 10, pmix = 0.2)
  })
  data <- data.frame(Conc = conc)
  fit <- ssd_fit_dists(data, dists = c("lnorm", "llogis_llogis"), min_pmix = 0.1)
  expect_identical(attr(fit, "min_pmix"), 0.1)
  skip_on_ci()
  withr::with_seed(99, {
    hc_err_two <- ssd_hc(fit, ci = TRUE, nboot = 100, average = FALSE, delta = 100)
  })
  expect_snapshot_boot_data(hc_err_two, "hc_err_two")
  withr::with_seed(99, {
    hc_err_avg <- ssd_hc(fit,
      ci = TRUE, nboot = 100,
      delta = 100, ci_method = "MACL"
    )
  })
  expect_snapshot_boot_data(hc_err_avg, "hc_err_avg2")
})


test_that("ssd_hc calculates cis in parallel but one distribution", {
  local_multisession()
  data <- ssddata::ccme_boron
  fits <- ssd_fit_dists(data, dists = "lnorm")
  withr::with_seed(10, {
    hc <- ssd_hc(fits, ci = TRUE, nboot = 10, ci_method = "MACL", samples = TRUE)
  })
  expect_snapshot_data(hc, "hcici_multi")
})

test_that("ssd_hc calculates cis in parallel with two distributions", {
  local_multisession()
  data <- ssddata::ccme_boron
  fits <- ssd_fit_dists(data, dists = c("lnorm", "llogis"))
  withr::with_seed(10, {
    hc <- ssd_hc(fits, ci = TRUE, nboot = 10, ci_method = "MACL")
  })
  expect_snapshot_value(hc$se, style = "deparse")
})

test_that("ssd_hc identical if in parallel", {
  data <- ssddata::ccme_boron
  fits <- ssd_fit_dists(data, dists = c("lnorm", "llogis"))
  withr::with_seed(10, {
    hc <- ssd_hc(fits, ci = TRUE, nboot = 10)
  })
  local_multisession(workers = 2)
  withr::with_seed(10, {
    hc2 <- ssd_hc(fits, ci = TRUE, nboot = 10)
  })
  expect_equal(hc, hc2)
})

test_that("hc est_method and ci_method combos", {
  fit1 <- ssd_fit_dists(ssddata::ccme_boron, dists = "lnorm")
  fit2 <- ssd_fit_dists(ssddata::ccme_boron, dists = c("lnorm", "llogis"))
  fits <- list(fit1, fit2)
  
  est_methods <- ssd_est_methods()
  ci_methods <- ssd_ci_methods()
  parametric <- c(TRUE, FALSE)
  ci <- c(FALSE, TRUE)
  average <- c(TRUE, FALSE)
  
  data <- tidyr::expand_grid(fit = fits, average = average, est_method = est_methods, ci = ci, parametric = parametric, ci_method = ci_methods)
  data$seed <- 10
  data$id <- seq_len(nrow(data))
  
  func <- function(fit, average, est_method, ci_method, parametric, ci, seed, id) {
    withr::with_seed(seed, {
      hc <- ssd_hc(fit, average = average, est_method = est_method, ci_method = ci_method, parametric = parametric, ci = ci, nboot = 10)
    })
    expect_s3_class(hc, "tbl")
    hc$id <- id
    hc
  }
  ls <- purrr::pmap(data, .f = func)
  
  ls <- dplyr::bind_rows(ls)
  data <- dplyr::rename(data, ci_method_arg = "ci_method", est_method_arg = "est_method")
  data <- dplyr::inner_join(data, ls, by = "id")
  data$fit <- NULL
  expect_snapshot_data(data, "all_hc_combos")
})
