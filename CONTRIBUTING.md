# Contributing to ssdtests

ssdtests holds the slow and unstable tests for
[ssdtools](https://github.com/bcgov/ssdtools) that are impractical to keep in
ssdtools itself.

## What belongs in ssdtests

A test belongs here rather than in ssdtools when it cannot run reliably as part
of ssdtools' own CRAN-facing test suite. In practice that means:

- Exact snapshots of parametric bootstrap confidence limits, whose values are
not reproducible across BLAS/LAPACK implementations, so exact comparison only
holds in a controlled environment (see `test-invpareto_eur.R`).
- Slow tests that would make ssdtools' suite too heavy for CRAN, such as fitting
every curated dataset to every distribution, or looping thousands of small-sample
fits.
- Numerically unstable fits (for example gompertz) whose results drift run to run
or across platforms.

ssdtools keeps the fast, portable, structural assertions for the same code paths;
ssdtests keeps the exact-value and stress tests. A new test that is fast and
portable belongs in ssdtools, not here.

## Snapshot stability

Tests are organized by subject (one `test-<subject>.R` file per distribution or
function), not by whether they are stable.

Two kinds of snapshot are used:

- Deterministic snapshots (point estimates, tidy tables) run on every platform.
Round to 4-6 significant figures via the `digits` argument of
`expect_snapshot_data()` so minor cross-platform maximum-likelihood differences
do not cause failures.
- Bootstrap confidence-limit snapshots (`lcl`, `ucl`, `se` from
`ssd_hc(ci = TRUE)` / `ssd_hp(ci = TRUE)`) are not reproducible across
BLAS/LAPACK implementations.
Guard these with `skip_on_ci()` placed before the bootstrap call, so the
expensive, platform-dependent comparison runs only locally.
`expect_snapshot_boot_data()` still asserts the structural `pboot` bounds.

Snapshots are generated locally (macOS).
Because most bootstrap tests are `skip_on_ci()`, they compare only on the
machine that generated them.

## Regenerating snapshots

Run the tests, review changes with `testthat::snapshot_review()`, and accept
with `testthat::snapshot_accept()` once verified.

## Measuring ssdtools coverage

`scripts/ssdtools-coverage.R` reports the ssdtools line coverage produced by the
ssdtests suite. It clones the ssdtools branch that corresponds to the current
ssdtests repo and branch (same org as the `origin` remote, same branch name, so
`poissonconsulting/ssdtests@dev` is measured against `poissonconsulting/ssdtools@dev`),
instruments it with covr, runs the ssdtests tests against it, and prints the
overall and per-file coverage.

```sh
Rscript scripts/ssdtools-coverage.R
```

Run it locally, not on CI: the `skip_on_ci()` tests are where most of the
coverage comes from and they only run locally. `test-fit-random-small.R` is
excluded by default (20000 instrumented fits take hours and add no new
coverage); pass `--all` to include it, `--filter <regex>` to scope to specific
test files, or `--ref <branch>` to measure against a different ssdtools branch.
