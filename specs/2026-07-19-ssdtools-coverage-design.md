# Measure ssdtools coverage from ssdtests

## Purpose

Quantify which ssdtools code paths the ssdtests suite exercises, and in particular the incremental coverage ssdtests adds beyond ssdtools' own test suite.
This is the metric that justifies the package: right now the `test-coverage` workflow measures ssdtests' own coverage (a few trivial R files), which says nothing about the package's actual job.

## Approach

A local R script `scripts/ssdtools-coverage.R` that instruments a local ssdtools source tree with covr and runs the ssdtests suite against it.

Confirmed mechanism (spiked): `covr::package_coverage(path = <ssdtools>, type = "none", code = <run ssdtests tests>)` instruments all ssdtools source files (76 in the spike) and attributes coverage from whatever `code` runs. Running `testthat::test_dir()` on the ssdtests tests as that `code` therefore yields ssdtools coverage produced by ssdtests.

The script:

1. Resolves a local ssdtools source path (command-line arg 1, default `~/Code/poissonconsulting/ssdtools`).
2. Computes ssdtools coverage from ssdtests: `package_coverage(ssdtools, type = "none", code = "testthat::test_dir('<ssdtests>/tests/testthat', stop_on_failure = FALSE, reporter = 'silent')")`.
3. Computes the baseline ssdtools coverage from ssdtools' own tests: `package_coverage(ssdtools)`.
4. Reports:
   - overall ssdtools coverage from ssdtests (percent, and per-file table via `covr::tally_coverage()`),
   - the incremental lines and files covered by ssdtests but not by ssdtools' own tests (set difference on the covered-line keys of the two coverage objects),
   - optionally an HTML report via `covr::report()`.

## Why local, not CI

The value of ssdtests is concentrated in the slow / `skip_on_ci` tests, which do not run on CI. Run locally, the `CI` environment variable is unset so those tests execute and the measurement reflects the full suite. A CI job would systematically undercount exactly the tests this package exists for, so the primary deliverable is a local script, not a workflow.

## Runtime

Instrumented coverage of the full suite is heavy; the `fit-random-small` tests alone run 20000 fits and would be far slower under instrumentation. The script therefore:

- accepts an optional `filter` argument (passed to `test_dir`) to scope the run to specific test files, and
- by default excludes the pathological stress tests (`fit-random-small`) from the coverage run, documenting that a full run is slow.

The incremental-coverage comparison (step 3-4) requires ssdtools' own test suite to run under instrumentation as well; this is the ssdtools baseline and is expected to be the slower half.

## Deliverable

- `scripts/ssdtools-coverage.R` (Rbuildignored via the existing `^scripts$` entry).
- A short "Measuring ssdtools coverage" note in `CONTRIBUTING.md` describing how to run it and interpret the output.
- No committed coverage numbers; they vary with the ssdtools version and are informational.

## Verification

Run `Rscript scripts/ssdtools-coverage.R` against the local ssdtools checkout on a filtered subset (for example `--filter hc5-gm`) and confirm it prints a non-trivial ssdtools coverage percentage plus an incremental report, and completes in reasonable time. A full run (all non-excluded tests) is expected to be slow but should produce the same shape of report.

## Out of scope

- A CI workflow or Codecov integration (undercounts the skip_on_ci tests; can be revisited if a portable subset is worth tracking).
- Changing or removing the existing `test-coverage` workflow (separate decision).
