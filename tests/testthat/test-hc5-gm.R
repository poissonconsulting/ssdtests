test_that("per-distribution HC5 as percent of geomean for all curated ssddata datasets", {
  datasets <- suppressMessages(ssddata::ssd_data_sets())
  dists <- ssd_dists_all()

  hc5 <- lapply(names(datasets), function(name) {
    data <- datasets[[name]]
    # Seed the fit: gompertz (and other fragile distributions) use random
    # initialisation, so an unseeded fit is not reproducible run to run.
    fit <- withr::with_seed(50, ssd_fit_dists(data, dists = dists, silent = TRUE))
    hc <- ssd_hc(fit, proportion = 0.05, average = FALSE)
    gm <- ssddata::gm_mean(data$Conc)

    grid <- tibble::tibble(dataset = name, dist = dists)
    grid <- dplyr::left_join(grid, dplyr::select(hc, dist, hc5 = est), by = "dist")
    grid$gm <- gm
    grid$hc5_pct_gm <- grid$hc5 / gm * 100
    grid
  })
  hc5 <- dplyr::bind_rows(hc5)

  # 7 significant figures is reproducible across all CI platforms for every
  # fitting combination; divergence in the fragile fits (burrIII3, gamma,
  # mixtures) only appears at 8+ sig figs. See specs design doc.
  expect_snapshot_data(hc5, "hc5_gm", digits = 7)
})
