# Measure ssdtools coverage from ssdtests

## Purpose

Report the simple line coverage of ssdtools produced by running the ssdtests suite.
This is the metric that justifies the package: the existing `test-coverage` workflow measures ssdtests' own coverage (a few trivial R files), which says nothing about the package's actual job.

## Source selection: org and branch matched

The ssdtools source is chosen to correspond to the current ssdtests repo and branch:

- **Org** = owner of the ssdtests `origin` remote. In this clone `origin` is `poissonconsulting`; it is `bcgov` for a direct clone of `bcgov/ssdtests`.
- **Branch** = the current ssdtests branch, mapped to the same-named branch on `{org}/ssdtools`.

So:

- `bcgov/ssdtests@main` -> `bcgov/ssdtools@main`
- `poissonconsulting/ssdtests@main` -> `poissonconsulting/ssdtools@main`
- `poissonconsulting/ssdtests@dev` -> `poissonconsulting/ssdtools@dev`

If the same-named branch does not exist on `{org}/ssdtools` (for example a feature branch), fall back to that ssdtools repo's default branch. An explicit `ref` argument overrides the detected branch.

The script shallow-clones `{org}/ssdtools@{ref}` into a temporary directory each run, so the ssdtools version is exactly the corresponding branch regardless of any local checkout state. The temp clone is removed afterwards.

## Approach

Confirmed mechanism (spiked): `covr::package_coverage(path = <ssdtools source>, type = "none", code = <run ssdtests tests>)` instruments all ssdtools source files (76 in the spike) and attributes coverage from whatever `code` runs. Running the ssdtests suite as that `code` yields ssdtools coverage produced by ssdtests.

`scripts/ssdtools-coverage.R`:

1. Detects org from `git remote get-url origin`, branch from `git rev-parse --abbrev-ref HEAD` (or the `ref` argument).
2. Shallow-clones `{org}/ssdtools@{ref}` to a temp dir (falling back to the default branch if `{ref}` is absent).
3. Builds the set of ssdtests test files to run, excluding the stress test by default (see below), as an anchored inclusion filter for `testthat::test_dir()`.
4. Runs `covr::package_coverage(clone, type = "none", code = "testthat::test_dir('<ssdtests>/tests/testthat', filter = '<filter>', stop_on_failure = FALSE, reporter = 'silent')")`.
5. Prints the overall ssdtools coverage percentage and a per-file table (`covr::percent_coverage()` and `covr::tally_coverage()`), then removes the temp clone.

## Excluding the stress test

`test-fit-random-small.R` runs 20000 fits; under covr instrumentation that would run for hours while adding no new ssdtools coverage (it only re-hits the lnorm fit path). It is excluded from the coverage run by default. A `--all` flag re-includes it.

Exclusion is implemented by computing the test basenames, dropping `fit-random-small`, and passing the rest as an anchored alternation `filter` to `test_dir` (for example `^(hc|hc5-gm|lnorm|...)$`), so no test files are copied or modified.

## Runtime and skips

The suite is run locally, so the `CI` environment variable is unset and the `skip_on_ci` tests execute (they are the bulk of the package's value). Plot snapshot tests still `skip_on_os` on non-macOS. Snapshot mismatches do not stop the run (`stop_on_failure = FALSE`); coverage is collected regardless. Even excluding the stress test, a full run is slow because it instruments ssdtools and runs the curated-dataset table tests; this is expected.

## Deliverable

- `scripts/ssdtools-coverage.R` (Rbuildignored via the existing `^scripts$` entry).
- A short "Measuring ssdtools coverage" note in `CONTRIBUTING.md` describing how to run it, the org/branch matching, and the default stress-test exclusion.
- No committed coverage numbers; they are informational and vary with the ssdtools branch.

## Verification

On `poissonconsulting/ssdtests@dev`, run `Rscript scripts/ssdtools-coverage.R --filter hc5-gm` and confirm it clones `poissonconsulting/ssdtools@dev`, prints a non-trivial ssdtools coverage percentage and per-file table, and removes the temp clone. A default run (all tests except `fit-random-small`) produces the same report shape over the whole suite.

## Out of scope

- Incremental coverage over ssdtools' own tests (simple coverage only).
- A CI workflow or Codecov integration (skip_on_ci tests would be undercounted on CI).
- Changing or removing the existing `test-coverage` workflow.
