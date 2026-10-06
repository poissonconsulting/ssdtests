# Contributing to ssdtests

ssdtests holds the slow and unstable tests for
[ssdtools](https://github.com/bcgov/ssdtools) that are impractical to keep in
ssdtools itself.

## What belongs in ssdtests

A test belongs here rather than in ssdtools when it cannot run reliably as part
of ssdtools' own CRAN-facing test suite. In practice that means:

- Exact snapshots of parametric bootstrap confidence limits, whose values are
not reproducible across BLAS/LAPACK implementations, so exact comparison only
holds in a controlled environment (see `test-hc.R`).
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

Snapshots are generated on macOS and every one of them reproduces on the
GitHub Actions macOS runner, so the regular R-CMD-check compares them all on
that platform.
Most also reproduce on Linux and Windows.
Round point estimates and tidy tables to 4-6 significant figures via the
`digits` argument of `expect_snapshot_data()` so minor cross-platform
maximum-likelihood differences do not cause failures.

A minority of snapshots are platform-specific: some bootstrap compatibility
limits (`lcl`, `ucl`, `se` from `ssd_hc(ci = TRUE)` / `ssd_hp(ci = TRUE)`),
some `sgompertz()` fits, and a few fits that fail to converge on one platform.
Guard these with `skip_on_os()` naming only the platforms on which they fail,
placed immediately before the first platform-dependent expectation so the
structural assertions still run everywhere.
`expect_snapshot_boot_data()` asserts the structural `pboot` bounds before the
snapshot.
Do not use `skip_on_ci()` for reproducibility; it is reserved for tests that
are too slow for CI (`test-fit-random-small.R`).

To find out which platforms a new snapshot needs, leave it unguarded and let the
pull-request checks report.
The `full-tests` workflow (`.github/workflows/full-tests.yaml`) runs the whole
suite on all three platforms weekly and on demand via workflow dispatch, with
`CI` set to `false` so only the `skip_on_os()` guards apply.
It uploads any `.new` snapshot files as an artifact when a comparison fails.
`test-fit-random-small.R` is excluded from that run because its 20000 fits
take hours and add no snapshot coverage.

## Regenerating snapshots

Run the tests, review changes with `testthat::snapshot_review()`, and accept
with `testthat::snapshot_accept()` once verified.

## Formatting

Code is formatted with [Air](https://posit-dev.github.io/air/).
Run `air format .` before committing, or enable format-on-save in your editor.
Long literal data vectors in the tests are preceded by `# fmt: skip` so they
stay compact; add the same marker when pasting a new one.

## Measuring ssdtools coverage

`scripts/ssdtools-coverage.R` reports the ssdtools line coverage produced by the
ssdtests suite. It clones the ssdtools branch that corresponds to the current
ssdtests repo and branch (same org as the `origin` remote, same branch name, so
`bcgov/ssdtests@main` is measured against `bcgov/ssdtools@main` and the
development fork `poissonconsulting/ssdtests@dev` against
`poissonconsulting/ssdtools@dev`),
instruments it with covr, runs the ssdtests tests against it, and prints the
overall and per-file coverage.

```sh
Rscript scripts/ssdtools-coverage.R
```

Run it locally on macOS, where no snapshot tests are skipped.
`test-fit-random-small.R` is
excluded by default (20000 instrumented fits take hours and add no new
coverage); pass `--all` to include it, `--filter <regex>` to scope to specific
test files, or `--ref <branch>` to measure against a different ssdtools branch.
