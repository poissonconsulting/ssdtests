# Introduction to ssdtests

## Overview

ssdtests holds the slow and unstable tests for
[ssdtools](https://github.com/bcgov/ssdtools). It contains no
user-facing functionality of its own; its job is to exercise ssdtools
code paths that cannot run reliably or quickly as part of ssdtools’ own
CRAN-facing test suite.

## What belongs in ssdtests

A test belongs here rather than in ssdtools when it cannot run reliably
as part of ssdtools’ own tests. In practice that means:

- Exact snapshots of parametric bootstrap confidence limits, whose
  values are not reproducible across BLAS/LAPACK implementations, so
  exact comparison only holds in a controlled environment.
- Slow tests that would make ssdtools’ suite too heavy for CRAN, such as
  fitting every curated dataset to every distribution, or looping
  thousands of small-sample fits.
- Numerically unstable fits (for example gompertz) whose results drift
  run to run or across platforms.

ssdtools keeps the fast, portable, structural assertions for the same
code paths; ssdtests keeps the exact-value and stress tests. A test that
is fast and portable belongs in ssdtools, not here.

## Test organisation

Tests live in `tests/testthat/` and are organised by subject, one
`test-<subject>.R` file per distribution or function, for example
`test-lnorm.R`, `test-hc.R`, and `test-plot.R`. There is no separate
“unstable” file; a test lives with its subject regardless of how stable
it is.

Shared helpers in `tests/testthat/helpers.R` support the common
patterns:

- `test_dist2()` checks that a distribution’s parameters can be
  recovered from data simulated with `ssd_r<dist>()`.
- `expect_snapshot_data()` snapshots a data frame as CSV, rounding
  numeric columns to a chosen number of significant figures.
- `expect_snapshot_boot_data()` asserts the structural `pboot` bounds
  and then snapshots the bootstrap result.

## Snapshot stability

Two kinds of snapshot are used.

Deterministic snapshots, such as point estimates and tidy tables, run on
every platform. They are rounded to 4-6 significant figures via the
`digits` argument of `expect_snapshot_data()` so that minor
cross-platform maximum-likelihood differences do not cause failures.

Bootstrap confidence-limit snapshots (`lcl`, `ucl`, `se` from
`ssd_hc(ci = TRUE)` and `ssd_hp(ci = TRUE)`) are not reproducible across
BLAS/LAPACK implementations. They are guarded with `skip_on_ci()` placed
before the bootstrap call, so the expensive, platform-dependent
comparison runs only locally.

Because most bootstrap tests are `skip_on_ci()`, they compare only on
the machine that generated them.

## Curated-dataset regression tables

Two tests fit the full collection of curated datasets returned by
[`ssddata::ssd_data_sets()`](https://open-aims.github.io/ssddata/reference/ssd_data_sets.html)
and snapshot a combined table.

`test-bcanz-hc.R` fits the BCANZ distributions to each dataset and
snapshots the model-averaged hazard concentrations at the default
proportions:

``` r

library(ssdtools)
library(ssddata)

fit <- ssd_fit_bcanz(ssddata::ccme_boron)
ssd_hc_bcanz(fit)
```

`test-hc5-gm.R` fits every valid distribution
([`ssd_dists_all()`](https://bcgov.github.io/ssdtools/reference/ssd_dists_all.html))
to each dataset and snapshots the per-distribution HC5 as a percentage
of the geometric mean of the concentrations, on a full grid with `NA`
where a distribution fails to fit:

``` r

fit <- ssd_fit_dists(ssddata::ccme_boron, dists = ssd_dists_all())
hc <- ssd_hc(fit, proportion = 0.05, average = FALSE)
hc$est / ssddata::gm_mean(ssddata::ccme_boron$Conc) * 100
```

These tables are rounded to a precision that is reproducible across
platforms (7 significant figures for the HC5 table, established by a
cross-platform measurement).

## Measuring ssdtools coverage

`scripts/ssdtools-coverage.R` reports the ssdtools line coverage
produced by the ssdtests suite. It clones the ssdtools branch that
corresponds to the current ssdtests repo and branch, instruments it with
covr, runs the ssdtests tests against it, and prints overall and
per-file coverage:

``` sh
Rscript scripts/ssdtools-coverage.R
```

Run it locally rather than on CI, because the `skip_on_ci()` tests are
where most of the coverage comes from.

## Running the tests

Run the suite with
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html)
or `devtools::test()`. Most bootstrap and stress tests are
`skip_on_ci()` and so run only locally. Snapshots are generated locally
(macOS); review changes with
[`testthat::snapshot_review()`](https://testthat.r-lib.org/reference/snapshot_accept.html)
and accept with
[`testthat::snapshot_accept()`](https://testthat.r-lib.org/reference/snapshot_accept.html).

See `CONTRIBUTING.md` for the contributor-facing version of these
conventions.
