# HC5-as-percent-of-geomean regression table

## Purpose

Add a regression test that fits every curated `ssddata` dataset to every valid ssdtools distribution and snapshots each per-distribution HC5 expressed as a percentage of the geometric mean of the dataset's concentrations.
This normalises the HC5 across datasets that span different concentration scales and guards `ssd_fit_dists()` + `ssd_hc()` per-distribution behaviour across the full curated collection.

## Scope

In scope:

- A single new test file `tests/testthat/test-hc5-gm.R`.
- Fitting the valid distributions (`ssd_dists_all()`, the 9 valid distributions) to each of the 53 curated datasets from `ssddata::ssd_data_sets()`.
- The per-distribution HC5 (proportion 0.05) point estimate, expressed as a percentage of the geometric mean of the dataset's `Conc`.
- Snapshotting a single combined table on a full 53 x 9 grid, with `NA` where a distribution failed to fit.

Out of scope:

- Bootstrap confidence limits.
- Model-averaged HC5 (covered by `test-bcanz-hc.R`).
- The non-valid `invpareto` distribution.

## Distributions and datasets

- Distributions: `ssd_dists_all()` returns the 9 valid distributions (burrIII3, gamma, gompertz, lgumbel, llogis, llogis_llogis, lnorm, lnorm_lnorm, weibull). `invpareto` is excluded because it is not valid by default.
- Datasets: `ssddata::ssd_data_sets()` returns the 53 curated datasets (one geometric-mean `Conc` per species), wrapped in `suppressMessages()`.

## Workflow per dataset

For each dataset:

1. `fit <- ssd_fit_dists(d, dists = ssd_dists_all(), silent = TRUE)`.
2. `hc <- ssd_hc(fit, proportion = 0.05, average = FALSE)` for the per-distribution HC5 (`est`).
3. `gm <- ssddata::gm_mean(d$Conc)` for the geometric mean of the concentrations.
4. Left-join the fitted `est` onto the full `ssd_dists_all()` list so all 9 distributions appear, `NA` where the distribution failed to fit.
5. `hc5_pct_gm = hc5 / gm * 100`.

`ssd_fit_dists()` drops distributions that fail to fit, so the join supplies the `NA` rows. gompertz in particular is dropped for many datasets.

## Combined table

Columns:

- `dataset`: dataset name.
- `dist`: distribution name (all 9 per dataset).
- `hc5`: the per-distribution HC5 estimate (`NA` if the distribution did not fit).
- `gm`: geometric mean of the dataset's `Conc` (constant within a dataset).
- `hc5_pct_gm`: `hc5 / gm * 100`, the HC5 as a percentage of the geometric mean (`NA` if the distribution did not fit).

Raw `hc5` and `gm` are retained so a future snapshot change is diagnosable (fit drift vs geomean change).
The table has 477 rows: 53 datasets by 9 distributions.

## Snapshot

`expect_snapshot_data(tbl, "hc5_gm", digits = 4)` writes `tests/testthat/_snaps/hc5-gm/hc5_gm.csv`.
Point estimates only (`ci = FALSE`), but each fit is wrapped in `withr::with_seed(50, ...)`: gompertz (and other fragile distributions) use random initialisation, so an unseeded fit is not reproducible run to run.
Seeding per fit makes the snapshot locally deterministic and is robust to dataset order.

`digits = 7` was chosen from a cross-platform measurement (see below): every fitting combination is identical to at least 7 significant figures on macOS, Windows, and Ubuntu, so the table is fully portable at this precision.

## Platform handling

Runs on all CI platforms.
The full-precision table was computed on macOS, Windows, and Ubuntu (via a one-off `scripts/compute-hc5-gm.R` plus matrix workflow) and compared cell by cell:

- 338 of the 353 fitting combinations are identical across all platforms to >= 12 significant figures.
- 15 (all `burrIII3`, `gamma`, `llogis_llogis`, `lnorm_lnorm`) diverge only at 8+ significant figures, agreeing to 7-11 figures; macOS is the odd platform out for 14 of them.
- macOS CI is bit-identical to a local Apple-Silicon mac, so there is no local-only divergence.

Rounding to 7 significant figures therefore keeps the single table green on every platform, and no `skip_on_ci()` / `skip_on_os()` guard is required.

## Verification

Run `testthat::test_local(filter = "hc5-gm")` and confirm the test passes and produces `tests/testthat/_snaps/hc5-gm/hc5_gm.csv` with 477 rows (53 x 9) and no `.new` file.
