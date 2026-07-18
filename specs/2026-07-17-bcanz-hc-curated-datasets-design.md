# bcanz HC regression table over curated ssddata datasets

## Purpose

Add a regression test that fits the BCANZ distributions to every curated dataset in `ssddata` using the BCANZ workflow and snapshots a table of the model-averaged hazard concentrations at the default proportions.
This provides a broad regression guard over `ssd_fit_bcanz()` and `ssd_hc_bcanz()` across the full curated dataset collection.

## Scope

In scope:

- A single new test file `tests/testthat/test-bcanz-hc.R`.
- Fitting the BCANZ distributions to each of the 53 curated datasets returned by `ssddata::ssd_data_sets()`.
- Extracting the model-averaged hazard concentration at each of the default proportions (0.01, 0.05, 0.1, 0.2) for each dataset.
- Snapshotting a single combined table of the results.

Out of scope:

- Bootstrap confidence limits.
- Per-distribution hazard concentrations.
- Per-dataset test blocks.
- Any change to `ssdtools` itself.

## Datasets

The curated datasets are enumerated with `ssddata::ssd_data_sets()`, which returns a named list of 53 tibbles.
Each tibble has already been reduced to one geometric-mean `Conc` per `Species`, which is the correct input form for the BCANZ fitting workflow.
`ssd_data_sets()` emits informational messages (geometric-mean application), so the call is wrapped in `suppressMessages()`.

## Workflow per dataset

For each dataset:

1. `fit <- ssd_fit_bcanz(data, silent = TRUE)`.
2. Assert `expect_s3_class(fit, "fitdists")`.
3. `hc <- ssd_hc_bcanz(fit)` (defaults: `ci = FALSE`, `average = TRUE`, proportions `c(0.01, 0.05, 0.1, 0.2)`).
4. Retain all four proportion rows (the model-averaged HC1, HC5, HC10, HC20).

The BCANZ distributions are `ssd_dists_bcanz()`: gamma, lgumbel, llogis, lnorm, lnorm_lnorm, weibull.
`ssd_fit_bcanz()` may drop distributions that fail to fit for a given dataset (for example `lnorm_lnorm` is absent for several datasets), so the set of distributions actually fit varies by dataset.

## Combined table

The per-dataset results are row-bound into one tibble with columns:

- `dataset`: the dataset name.
- `proportion`: the hazard proportion (0.01, 0.05, 0.1, 0.2).
- `est`: the model-averaged hazard concentration estimate.
- `dists`: the comma-separated distributions actually fit (captured as a regression signal, since this varies by dataset).

The table has 212 rows: 53 datasets by 4 proportions.

## Snapshot

The combined table is snapshotted with the existing `expect_snapshot_data()` helper:

```r
expect_snapshot_data(tbl, "bcanz_hc", digits = 4)
```

This writes `tests/testthat/_snaps/bcanz-hc/bcanz_hc.csv`.

`digits = 4` rounds the hazard concentration estimates to 4 significant figures, robust to minor cross-platform MLE differences while still catching meaningful changes.

## Determinism and platform handling

With `ci = FALSE` there is no bootstrap, so the computation is deterministic and no `set.seed` is required.
The test runs on all CI platforms (no `skip_on_ci` or `skip_on_os`).
If cross-platform MLE divergence proves to make the snapshot flaky, the fallback is to guard with `skip_on_os()` to macOS, matching the existing `expect_snapshot_plot()` pattern; this is not applied initially.

## Verification

Run `testthat::test_local(filter = "bcanz-hc")` and confirm the test passes and produces `tests/testthat/_snaps/bcanz-hc/bcanz_hc.csv` with 212 rows and no `.new` file.
