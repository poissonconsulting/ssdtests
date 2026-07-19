# Contributing to ssdtests

ssdtests holds the slow and unstable tests for
[ssdtools](https://github.com/bcgov/ssdtools) that are impractical to keep in
ssdtools itself.

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
