# Test-hygiene improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Four self-contained hygiene improvements to ssdtests: document the snapshot-stability convention, resolve the four permanently-skipped tests, prune unused dependencies, and clean dead code in the shared test helper.

**Architecture:** Small, independent edits sharing one branch and one PR into `dev`. No change to what any surviving test asserts, except the four bare-`skip()` tests: one is deleted, three are revived behind `skip_on_ci()` (verified to pass locally in a spike).

**Tech Stack:** R, testthat 3e, roxygen2/usethis, git.

## Global Constraints

- Branch: `improve-test-hygiene`; base: `dev`; open as a draft PR into `dev`.
- The three revived tests were spiked with their `skip()` removed and all passed on macOS; they are guarded with `skip_on_ci()` (not run on CI), so CI behaviour is unchanged for them.
- After test edits, run the affected files and confirm no unexpected `.new` snapshots.
- Run `usethis::use_tidy_description()` after editing DESCRIPTION.
- Docs and spec files live in `specs/` (Rbuildignored); `CONTRIBUTING.md` at top level is added to `.Rbuildignore`.

## File Structure

- Modify: `tests/testthat/helpers.R` (remove dead code; add convention comment).
- Create: `CONTRIBUTING.md` (snapshot-stability convention).
- Modify: `.Rbuildignore` (add `^CONTRIBUTING\.md$`; remove stale `^codecov\.yml$`, `^\.covrignore$`).
- Modify: `tests/testthat/test-lnorm-lnorm.R` (delete one test).
- Modify: `tests/testthat/test-fit.R`, `tests/testthat/test-weibull.R` (revive three tests).
- Create: `tests/testthat/_snaps/fit/tidy_stable_computable.csv` (generated).
- Modify: `DESCRIPTION` (drop `envirotox`, `sessioninfo`).

---

### Task 1: Clean helpers.R and document the snapshot convention (items 1 + 4)

**Files:**
- Modify: `tests/testthat/helpers.R`

- [ ] **Step 1: Remove the dead `lapply_fun` assignment**

In `expect_snapshot_data`, the first `lapply_fun <- function(x) I(lapply(x, fun))` (currently line 59) is immediately overwritten inside the `if (!delist)` branch (line 63). Delete the line-59 assignment so `lapply_fun` is defined only where used:

```r
expect_snapshot_data <- function(x, name, digits = 6, delist = FALSE) {
  fun <- function(x) if (is.numeric(x)) signif(x, digits = digits) else x
  x <- dplyr::mutate(x, dplyr::across(where(is.numeric), fun))

  if (!delist) {
    lapply_fun <- function(x) I(lapply(x, fun))
    x <- dplyr::mutate(x, dplyr::across(dplyr::where(is.list), lapply_fun))
  } else {
    n <- nrow(x)
    x <- dplyr::mutate(x, dplyr::across(where(is.list), \(.x) rep("list", n)))
  }
  path <- save_csv(x)
  testthat::expect_snapshot_file(
    path,
    paste0(name, ".csv"),
    compare = testthat::compare_file_text
  )
}
```

- [ ] **Step 2: Add a convention comment above `expect_snapshot_boot_data`**

Insert this comment immediately before the `expect_snapshot_boot_data <- function(...)` definition:

```r
# Bootstrap compatibility limits (lcl/ucl/se) depend on refits that diverge
# across BLAS/LAPACK implementations, so their exact snapshot only holds on the
# platform that generated it. Tests that snapshot bootstrap CIs must call
# skip_on_ci() before the bootstrap; this helper still asserts the structural
# pboot bounds, which hold on every platform. See CONTRIBUTING.md.
```

- [ ] **Step 3: Run a snapshot-using test file to confirm the helper still works**

Run: `Rscript -e 'testthat::test_local(filter = "^averaging$", reporter = "summary")'`
Expected: pass; no `.new` files.

- [ ] **Step 4: Commit**

```bash
git add tests/testthat/helpers.R
git commit -m "Tidy expect_snapshot_data and document bootstrap snapshot convention"
```

---

### Task 2: Add CONTRIBUTING.md documenting the convention (item 1)

**Files:**
- Create: `CONTRIBUTING.md`
- Modify: `.Rbuildignore`

- [ ] **Step 1: Write `CONTRIBUTING.md`**

```markdown
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
  `expect_snapshot_data()` so minor cross-platform maximum-likelihood
  differences do not cause failures.
- Bootstrap confidence-limit snapshots (`lcl`, `ucl`, `se` from
  `ssd_hc(ci = TRUE)` / `ssd_hp(ci = TRUE)`) are not reproducible across
  BLAS/LAPACK implementations. Guard these with `skip_on_ci()` placed before the
  bootstrap call, so the expensive, platform-dependent comparison runs only
  locally. `expect_snapshot_boot_data()` still asserts the structural `pboot`
  bounds.

Snapshots are generated locally (macOS). Because most bootstrap tests are
`skip_on_ci()`, they compare only on the machine that generated them.

## Regenerating snapshots

Run the tests, review changes with `testthat::snapshot_review()`, and accept
with `testthat::snapshot_accept()` once verified.
```

- [ ] **Step 2: Rbuildignore CONTRIBUTING.md and drop stale entries**

Add `^CONTRIBUTING\.md$` to `.Rbuildignore`, and remove the two entries for files that do not exist (`^codecov\.yml$`, `^\.covrignore$`).

- [ ] **Step 3: Confirm the package still builds cleanly past the ignore stage**

Run: `Rscript -e 'pkgbuild::build(".", dest_path = tempdir())'`
Expected: builds without complaint about `CONTRIBUTING.md` (it is Rbuildignored).

- [ ] **Step 4: Commit**

```bash
git add CONTRIBUTING.md .Rbuildignore
git commit -m "Add CONTRIBUTING.md and drop stale Rbuildignore entries"
```

---

### Task 3: Delete the unfixable lnorm_lnorm censored test (item 2)

**Files:**
- Modify: `tests/testthat/test-lnorm-lnorm.R`

**Interfaces:**
- The test `ssd_fit_dists lnorm_lnorm unstable with censored data` has a bare `skip()` and references a snapshot (`lnorm_lnorm_no_se`) that was never generated, so it asserts nothing and has no orphan snapshot to remove.

- [ ] **Step 1: Delete the test block**

Remove the entire `test_that("ssd_fit_dists lnorm_lnorm unstable with censored data", { ... })` block from `test-lnorm-lnorm.R`.

- [ ] **Step 2: Confirm no orphan snapshot and the file still passes**

Run: `ls tests/testthat/_snaps/lnorm-lnorm/` (expect only `tidy_anonb.csv`, `plot_anonb.png`; no `lnorm_lnorm_no_se.csv`).
Run: `Rscript -e 'testthat::test_local(filter = "^lnorm-lnorm$", reporter = "summary")'`
Expected: pass; the previously-skipped test no longer appears.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-lnorm-lnorm.R
git commit -m "Delete permanently-skipped lnorm_lnorm censored test"
```

---

### Task 4: Revive the three skipped tests behind skip_on_ci() (item 2)

**Files:**
- Modify: `tests/testthat/test-fit.R`, `tests/testthat/test-weibull.R`
- Create: `tests/testthat/_snaps/fit/tidy_stable_computable.csv`

**Interfaces:**
- Spike result: with `skip()` removed, all three pass on macOS. `test-fit`'s test produces a new snapshot `tidy_stable_computable`; the two weibull tests use `expect_warning`/`expect_identical` and produce no snapshot.

- [ ] **Step 1: Replace `skip()` with `skip_on_ci()` in the three tests**

In `test-fit.R` ("ssd_fit_dists computable = TRUE allows for fits without standard errors"), and in `test-weibull.R` ("weibull sometimes fails to converge" and "weibull is sometimes unstable"), change the bare `skip()` line to `skip_on_ci()`.

- [ ] **Step 2: Run the two files to execute the revived tests and generate the fit snapshot**

Run: `Rscript -e 'testthat::test_local(filter = "^(fit|weibull)$", reporter = "summary")'`
Expected: pass locally; a `W` warning "Adding new file snapshot: 'tests/testthat/_snaps/fit/tidy_stable_computable.csv'" appears on this first run.

- [ ] **Step 3: Re-run to confirm the new snapshot compares clean**

Run: `Rscript -e 'testthat::test_local(filter = "^(fit|weibull)$", reporter = "summary")'`
Expected: pass; no `Adding new file snapshot`; no `.new` files under `_snaps/fit/`.

- [ ] **Step 4: Commit**

```bash
git add tests/testthat/test-fit.R tests/testthat/test-weibull.R tests/testthat/_snaps/fit/tidy_stable_computable.csv
git commit -m "Revive three skipped tests behind skip_on_ci()"
```

---

### Task 5: Prune unused dependencies (item 3)

**Files:**
- Modify: `DESCRIPTION`

**Interfaces:**
- `envirotox` (Suggests + Remotes) and `sessioninfo` (Suggests) are referenced in no test or R file (verified by grep over `tests/`, `R/`, `README.Rmd`).

- [ ] **Step 1: Remove the dependencies**

Delete `envirotox (>= 0.0.0.9002),` from `Suggests`, `sessioninfo,` from `Suggests`, and `poissonconsulting/envirotox,` from `Remotes` in `DESCRIPTION`.

- [ ] **Step 2: Normalise DESCRIPTION**

Run: `Rscript -e 'usethis::use_tidy_description()'`
Expected: field order/formatting normalised; no error.

- [ ] **Step 3: Confirm the package loads without the removed Suggests**

Run: `Rscript -e 'pkgload::load_all(); cat("ok\n")'`
Expected: `ok` with no error about missing `envirotox`/`sessioninfo`.

- [ ] **Step 4: Commit**

```bash
git add DESCRIPTION
git commit -m "Drop unused envirotox and sessioninfo dependencies"
```

---

### Task 6: Full suite, push, and open the draft PR

- [ ] **Step 1: Run the full suite**

Run: `Rscript -e 'testthat::test_local(reporter = "summary")'`
Expected: passes; the four previously-skipped tests are now either gone (1) or running locally (3); no `.new` files anywhere under `_snaps/`.

- [ ] **Step 2: Confirm no stray `.new` files**

Run: `find tests/testthat/_snaps -name '*.new*'`
Expected: no output.

- [ ] **Step 3: Push and open the draft PR**

```bash
git push -u origin improve-test-hygiene
gh pr create --draft --repo poissonconsulting/ssdtests --base dev --head poissonconsulting:improve-test-hygiene \
  --title "Test hygiene: document snapshot convention, resolve skipped tests, prune deps" \
  --body "Documents the bootstrap snapshot-stability convention (CONTRIBUTING.md + helper comment), deletes one permanently-skipped test that could never generate its snapshot, revives three others behind skip_on_ci() (verified to pass locally), prunes the unused envirotox and sessioninfo dependencies, and removes dead code plus stale Rbuildignore entries. No surviving test's assertions change."
```

- [ ] **Step 4: Monitor CI**

Watch R-CMD-check / test-coverage / pkgdown. The revived tests are `skip_on_ci()`, so CI behaviour for them is unchanged; the dependency prune removes a GitHub install from CI.

## Self-Review

**Spec coverage:** Item 1 = Tasks 1 (helper comment) + 2 (CONTRIBUTING). Item 2 = Tasks 3 (delete 1) + 4 (revive 3). Item 3 = Task 5. Item 4 = Task 1 (dead code). Task 6 verifies and ships.

**Placeholder scan:** No TODO/TBD; each step has exact commands, file targets, and expected output; edited code shown in full where changed.

**Type consistency:** `tidy_stable_computable` snapshot name matches between the `expect_snapshot_data` call in `test-fit.R` and the generated `_snaps/fit/tidy_stable_computable.csv`. `skip_on_ci()` replaces `skip()` consistently across the three revived tests.
