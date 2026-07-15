# Exact bootstrap confidence-interval snapshots for the European inverse Pareto
# distribution. These are kept in ssdtests rather than ssdtools because the
# parametric bootstrap confidence limits are not reproducible across platforms
# (the bootstrap refits diverge with different BLAS/LAPACK), so exact snapshot
# comparison only holds in a controlled environment. ssdtools retains
# structural assertions for the same code paths.

test_that("invpareto_eur gives cis with ccme_boron", {
  fit <- ssd_fit_dists(ssddata::ccme_boron, dists = "invpareto_eur")
  expect_s3_class(fit, "fitdists")
  withr::with_seed(50, {
    hc <- ssd_hc(
      fit,
      nboot = 100,
      ci = TRUE,
      ci_method = "multi_fixed",
      samples = TRUE
    )
  })
  expect_snapshot_data(hc, "hc_boron")
})

test_that("invpareto_eur ssd_hp gives cis with ccme_boron", {
  fit <- ssd_fit_dists(ssddata::ccme_boron, dists = "invpareto_eur")
  expect_s3_class(fit, "fitdists")
  withr::with_seed(50, {
    hp <- ssd_hp(
      fit,
      nboot = 100,
      ci = TRUE,
      ci_method = "multi_fixed",
      samples = TRUE,
      proportion = FALSE
    )
  })
  expect_snapshot_data(hp, "hp_boron")
})
