test_that("odds scaling changes hc", {
  odds <- function(x) {
    x / (1 - x)
  }
  inv_odds <- function(x) {
    x / (x + 1)
  }

  x <- c(0.01, 0.2, 0.5, 0.8)
  expect_identical(x, inv_odds(odds(x)))

  datas <- tibble::tibble(
    Sample_id = c("A", "B", "C"),
    complement = FALSE,
    odds = FALSE,
    data = list(
      tibble::tibble(
        Conc = c(
          0.00492,
          0.00452,
          0.00064,
          0.00331,
          0.0014,
          0.00051,
          0.00062,
          0.00261,
          0.00039,
          0.00523,
          0.0111
        )
      ),
      tibble::tibble(
        Conc = c(
          0.0549,
          0.0449,
          0.0111,
          0.0173,
          0.00939,
          0.00041,
          0.0152,
          0.00837,
          0.0152,
          0.0504,
          0.25
        )
      ),
      tibble::tibble(
        Conc = c(
          0.0256,
          0.0299,
          0.0132,
          0.149,
          0.0616,
          0.00035,
          0.0098,
          0.0225,
          0.106,
          0.149,
          0.0787
        )
      )
    )
  )
  datas <- datas |>
    dplyr::bind_rows(
      dplyr::mutate(
        datas,
        complement = TRUE,
        data = purrr::map(data, \(x) dplyr::mutate(x, Conc = 1 - Conc))
      )
    )
  datas <- datas |>
    dplyr::bind_rows(
      dplyr::mutate(
        datas,
        odds = TRUE,
        data = purrr::map(data, \(x) dplyr::mutate(x, Conc = odds(Conc)))
      )
    )

  datas <- datas |>
    dplyr::mutate(
      fit = purrr::map(
        .data$data,
        ssd_fit_dists,
        dists = ssd_dists_bcanz(npars = 2L)
      ),
      hc = purrr::map(.data$fit, ssd_hc, proportion = c(0.01, 0.05, 0.1, 0.2)),
      hc = purrr::map_if(
        .data$hc,
        .p = .data$odds,
        \(x) dplyr::mutate(x, across(c(est, lcl, ucl), inv_odds))
      )
    ) |>
    tidyr::unnest(hc) |>
    dplyr::select(Sample_id, complement, odds, proportion, est)

  gp <- datas |>
    dplyr::mutate(
      odds = dplyr::if_else(odds, "odds", "original"),
      complement = dplyr::if_else(complement, "upper tail", "lower tail")
    ) |>
    tidyr::pivot_wider(names_from = odds, values_from = est) |>
    dplyr::mutate(bias = ((1 / odds) / (1 / original)) - 1) |>
    ggplot2::ggplot() +
    ggplot2::facet_grid(complement ~ proportion) +
    ggplot2::aes(x = 1 / odds, y = bias) +
    ggplot2::geom_point(ggplot2::aes(color = Sample_id)) +
    ggplot2::geom_hline(yintercept = 0) +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::scale_x_log10() +
    ggplot2::xlab("Number of estimated dilutions") +
    ggplot2::ylab("Proportion of additional required dilutions")

  expect_snapshot_plot(gp, "wett")
})
