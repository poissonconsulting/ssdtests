test_that("ssd_hp cis with error and multiple dists", {
  withr::with_seed(99, {
    conc <- ssd_rlnorm_lnorm(30, meanlog1 = 0, meanlog2 = 1, sdlog1 = 1 / 10, sdlog2 = 1 / 10, pmix = 0.2)
  })
  data <- data.frame(Conc = conc)
  fit <- ssd_fit_dists(data, dists = c("lnorm", "llogis_llogis"), min_pmix = 0.1)
  expect_identical(attr(fit, "min_pmix"), 0.1)
  skip_on_ci()
  withr::with_seed(99, {
    hp_err_two <- ssd_hp(fit,
      conc = 1, ci = TRUE, nboot = 100, average = FALSE,
      delta = 100, proportion = FALSE
    )
  })
  expect_snapshot_boot_data(hp_err_two, "hp_err_two")
  withr::with_seed(99, {
    hp_err_avg <- ssd_hp(fit,
      conc = 1, ci = TRUE, nboot = 100,
      delta = 100, ci_method = "MACL", proportion = FALSE
    )
  })
  expect_snapshot_boot_data(hp_err_avg, "hp_err_avg")
})

test_that("ssd_hp calculates cis in parallel but one distribution", {
  local_multisession()
  data <- ssddata::ccme_boron
  fits <- ssd_fit_dists(data, dists = "lnorm")
  withr::with_seed(10, {
    hp <- ssd_hp(fits, 1, ci = TRUE, nboot = 10, ci_method = "MACL", proportion = FALSE)
  })
  expect_snapshot_value(hp$se, style = "deparse")
})

test_that("ssd_hp calculates cis in parallel with two distributions", {
  local_multisession()
  data <- ssddata::ccme_boron
  fits <- ssd_fit_dists(data, dists = c("lnorm", "llogis"))
  withr::with_seed(10, {
    hp <- ssd_hp(fits, 1, ci = TRUE, nboot = 10, ci_method = "MACL", proportion = FALSE)
  })
  expect_snapshot_value(hp$se, style = "deparse")
})

test_that("hp est_method and ci_method combos", {
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
      hp <- ssd_hp(fit, average = average, est_method = est_method, ci_method = ci_method, parametric = parametric, ci = ci, nboot = 10, proportion = TRUE)
    })
    expect_s3_class(hp, "tbl")
    hp$id <- id
    hp
  }
  ls <- purrr::pmap(data, .f = func)
  
  ls <- dplyr::bind_rows(ls)
  data <- dplyr::rename(data, ci_method_arg = "ci_method", est_method_arg = "est_method")
  data <- dplyr::inner_join(data, ls, by = "id")
  data$fit <- NULL
  expect_snapshot_data(data, "all_hp_combos")
})

test_that("ssd_hp cis with non-convergence", {
  withr::with_seed(99, {
    conc <- ssd_rlnorm_lnorm(
      100,
      meanlog1 = 0,
      meanlog2 = 1,
      sdlog1 = 1 / 10,
      sdlog2 = 1 / 10,
      pmix = 0.2
    )
    data <- data.frame(Conc = conc)
    fit <- ssd_fit_dists(data, dists = "lnorm_lnorm", min_pmix = 0.15)
    expect_identical(attr(fit, "min_pmix"), 0.15)
    hp15 <- ssd_hp(
      fit,
      conc = 1,
      ci = TRUE,
      nboot = 100,
      min_pboot = 0.9,
      proportion = FALSE
    )
    attr(fit, "min_pmix") <- 0.3
    expect_identical(attr(fit, "min_pmix"), 0.3)
    hp30 <- ssd_hp(
      fit,
      conc = 1,
      ci = TRUE,
      nboot = 100,
      min_pboot = 0.9,
      ci_method = "MACL",
      samples = TRUE,
      proportion = FALSE
    )
  })
  expect_s3_class(hp30, "tbl")
  expect_snapshot_data(hp30, "hp_30")
})

test_that("ssd_hp fix_weight", {
  fits <- ssd_fit_dists(ssddata::ccme_boron, dists = c("lnorm", "lgumbel"))

  withr::with_seed(102, {
    hc_unfix <- ssd_hp(
      fits,
      nboot = 100,
      ci = TRUE,
      ci_method = "multi_free",
      samples = TRUE,
      proportion = FALSE
    )
  })
  expect_snapshot_data(hc_unfix, "hc_unfix")

  withr::with_seed(102, {
    hc_fix <- ssd_hp(
      fits,
      nboot = 100,
      ci = TRUE,
      ci_method = "multi_fixed",
      samples = TRUE,
      proportion = FALSE
    )
  })
  expect_snapshot_data(hc_fix, "hc_fix")
})

test_that("hp multi_ci lnorm default 100", {
  fits <- ssd_fit_dists(ssddata::ccme_boron)
  set.seed(102)
  hp_average <- ssd_hp(fits, proportion = TRUE, average = TRUE, ci = TRUE, nboot = 100, ci_method = "MACL", samples = TRUE)
  set.seed(102)
  hp_multi <- ssd_hp(fits,
    proportion = TRUE,
    average = TRUE, ci_method = "multi_free", ci = TRUE, nboot = 100,
    min_pboot = 0.8, samples = TRUE
  )

  testthat::expect_snapshot({
    hp_average
  })
  skip_on_ci()
  # ── Failure ('test-hp-root.R:79:3'): hp multi_ci lnorm default 100 ─────────────────
  # Snapshot of code has changed:
  #   old[4:7] vs new[4:7]
  # # A tibble: 1 x 10
  # dist     conc   est    se   lcl   ucl    wt method     nboot pboot
  # <chr>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <chr>      <dbl> <dbl>
  #   -   1 average     1  3.90  3.57 0.347  11.2     1 parametric   100  0.86
  #   +   1 average     1  3.90  2.89 0.347  11.2     1 parametric   100  0.86
  testthat::expect_snapshot({
    hp_multi
  })
})

test_that("ssd_hp cis with error", {
  skip_on_ci()

  set.seed(99)
  conc <- ssd_rlnorm_lnorm(30, meanlog1 = 0, meanlog2 = 1, sdlog1 = 1 / 10, sdlog2 = 1 / 10, pmix = 0.2)
  data <- data.frame(Conc = conc)
  fit <- ssd_fit_dists(data, dists = "lnorm_lnorm", min_pmix = 0.1)
  expect_identical(attr(fit, "min_pmix"), 0.1)
  expect_warning(hp_err <- ssd_hp(fit, proportion = TRUE, conc = 1, ci = TRUE, ci_method = "multi_fixed", nboot = 100, min_pboot = 0.99))
  expect_s3_class(hp_err, "tbl")
  expect_snapshot_data(hp_err, "hp_err_na")
  hp_err <- ssd_hp(fit, proportion = TRUE, conc = 1, ci = TRUE, nboot = 100, min_pboot = 0.92, ci_method = "MACL")
  expect_s3_class(hp_err, "tbl")
  expect_snapshot_data(hp_err, "hp_err")
})

test_that("ssd_hp comparable parametric and non-parametric big sample size", {
  skip_on_ci()

  set.seed(99)
  data <- data.frame(Conc = ssd_rlnorm(10000, 2, 1))
  fit <- ssd_fit_dists(data, dists = "lnorm")
  set.seed(10)
  hp_para <- ssd_hp(fit, 1, proportion = TRUE, ci = TRUE, nboot = 10, ci_method = "MACL", samples = TRUE)
  expect_snapshot_data(hp_para, "hp_para")
  set.seed(10)
  hp_nonpara <- ssd_hp(fit, 1, proportion = TRUE, ci = TRUE, nboot = 10, parametric = FALSE, ci_method = "MACL", samples = TRUE)
  expect_snapshot_data(hp_nonpara, "hp_nonpara")
})
