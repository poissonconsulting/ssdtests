# Reorganize ssdtests tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dissolve the catch-all `test-zzz-unstable.R` into the appropriate subject test files so tests are organized on one axis (subject under test), and remove the `zzz-` ordering hack.

**Architecture:** `test-zzz-unstable.R` currently holds 19 tests spanning many unrelated subjects (sgompertz, weibull, gamma, lnorm_lnorm, invpareto, hc, hp, plotting). Each test moves verbatim to the file for its subject. File snapshots (CSV/PNG) move byte-for-byte with `git mv`. Text snapshots (`.md`) are regenerated in the destination file and verified against the originals by diff. Every test keeps its existing `skip_on_ci()` / `skip()` / seed guards. No test logic changes.

**Tech Stack:** R, testthat 3e (snapshot testing), git.

## Global Constraints

- Do not change any test's logic, seed, or skip guard; this is a pure move.
- File snapshots move with `git mv` to preserve exact bytes (no regeneration).
- Text (`.md`) snapshots are regenerated locally, then `git diff` must confirm the regenerated content is byte-identical to the block removed from `zzz-unstable.md` (proving no behavioral change).
- After every task, run the affected test file(s) and confirm no `.new` snapshot files are produced.
- The unstable tests use fixed seeds (`withr::with_seed`) so they regenerate deterministically on the local machine.
- Branch: `reorganize-tests`; base: `dev`; open as a draft PR into `dev`.
- Out of scope (separate follow-up PRs): mirroring ssdtools test file names, and standardizing the snapshot-stability policy inside `expect_snapshot_boot_data()`.

## Move map

Source tests in `test-zzz-unstable.R` (by title) and their destinations:

| Test title | Destination | Snapshots (type) |
| --- | --- | --- |
| ssd_fit_dists lnorm_lnorm unstable with censored data | test-lnorm-lnorm.R | `lnorm_lnorm_no_se.csv` (file) |
| weibull is sometimes unstable | test-weibull.R | none (skip(), expect_identical) |
| hc multi_ci lnorm default 100 | test-hc.R | `hc multi_ci lnorm default 100` (text, hc.md) |
| hp multi_ci lnorm default 100 | test-hp.R | `hp multi_ci lnorm default 100` (text, hp.md) |
| gamma parameters are extremely unstable | test-gamma.R | `tidy_gamma_unstable.csv` (file) |
| sgompertz completely unstable! | test-gompertz.R | text (gompertz.md) |
| sgompertz with initial values still unstable! | test-gompertz.R | text (gompertz.md) |
| sgompertz cant even fit some values | test-gompertz.R | text (gompertz.md) |
| sgompertz cant even initialize lots of values | test-gompertz.R | text (gompertz.md) |
| ssd_hc cis with error | test-hc.R | `hc_err_na.csv`, `hc_err.csv` (file) |
| ssd_hc comparable parametric and non-parametric big sample size | test-hc.R | `hc_para.csv`, `hc_nonpara.csv` (file) |
| ssd_hp cis with error | test-hp.R | `hp_err_na.csv`, `hp_err.csv` (file) |
| ssd_hp comparable parametric and non-parametric big sample size | test-hp.R | `hp_para.csv`, `hp_nonpara.csv` (file) |
| plot geoms | test-plot.R (new) | `geoms_all.png` (file) |
| ssd_plot censored data | test-plot.R (new) | `boron_cens_pred_ribbon.png` (file) |
| invpareto with extreme data | test-invpareto.R | none |
| not all estimates if fail | test-hc.R | `hc_notallestimates.csv` (file) |
| lnorm_lnorm fits anonb | test-lnorm-lnorm.R | `tidy_anonb.csv` (file), `plot_anonb.png` (file) |
| lnorm_lnorm non-bimodal 1000 data | test-lnorm-lnorm.R | none |

Destination snapshot dirs confirmed free of name collisions. `_snaps/gamma/`, `_snaps/invpareto/`, `_snaps/lnorm-lnorm/` do not yet exist and will be created by `git mv`.

## File Structure

- Create: `tests/testthat/test-plot.R` (the two plot tests).
- Modify: `tests/testthat/test-hc.R`, `test-hp.R`, `test-gompertz.R`, `test-gamma.R`, `test-weibull.R`, `test-lnorm-lnorm.R`, `test-invpareto.R` (receive moved tests).
- Delete: `tests/testthat/test-zzz-unstable.R`, `tests/testthat/_snaps/zzz-unstable.md`, `tests/testthat/_snaps/zzz-unstable/` (after all contents moved).
- Snapshots move under `tests/testthat/_snaps/<destination>/`.

Each task below moves one subject. Work one subject at a time, running that subject's test file after the move, so a failure is isolated to the subject just moved. Keep `test-zzz-unstable.R` in place until Task 9 removes the now-empty file.

---

### Task 1: Move file-snapshot hc tests to test-hc.R

**Files:**
- Modify: `tests/testthat/test-hc.R` (append tests), `tests/testthat/test-zzz-unstable.R` (remove the same tests)
- Move: `_snaps/zzz-unstable/{hc_err_na,hc_err,hc_para,hc_nonpara,hc_notallestimates}.csv` -> `_snaps/hc/`

**Interfaces:**
- Consumes: existing helpers `expect_snapshot_data`, `expect_snapshot_boot_data` (already sourced from `helpers.R`).
- Produces: `test-hc.R` gains tests "ssd_hc cis with error", "ssd_hc comparable parametric and non-parametric big sample size", "not all estimates if fail".

- [ ] **Step 1: Move the snapshot files**

```bash
cd tests/testthat
git mv _snaps/zzz-unstable/hc_err_na.csv _snaps/hc/hc_err_na.csv
git mv _snaps/zzz-unstable/hc_err.csv _snaps/hc/hc_err.csv
git mv _snaps/zzz-unstable/hc_para.csv _snaps/hc/hc_para.csv
git mv _snaps/zzz-unstable/hc_nonpara.csv _snaps/hc/hc_nonpara.csv
git mv _snaps/zzz-unstable/hc_notallestimates.csv _snaps/hc/hc_notallestimates.csv
```

- [ ] **Step 2: Cut the three test blocks from `test-zzz-unstable.R`**

Locate the `test_that("ssd_hc cis with error", {...})` (line ~480), `test_that("ssd_hc comparable parametric and non-parametric big sample size", {...})` (line ~496), and `test_that("not all estimates if fail", {...})` (line ~602) blocks. Cut each complete block (from `test_that(` through its closing `})`).

- [ ] **Step 3: Paste them verbatim at the end of `test-hc.R`**

Paste the three blocks unchanged (including their `skip_on_ci()` and `withr::with_seed(...)` lines) after the last existing test in `test-hc.R`.

- [ ] **Step 4: Run the hc tests and confirm they pass with no new snapshots**

Run: `Rscript -e 'testthat::test_local(filter = "^hc$", reporter = "summary")'`
Expected: all pass; no `Adding new file snapshot` warning; no `.new` files under `_snaps/hc/`.

- [ ] **Step 5: Confirm no stray `.new` files**

Run: `ls tests/testthat/_snaps/hc/*.new* 2>/dev/null && echo FOUND || echo CLEAN`
Expected: `CLEAN`

- [ ] **Step 6: Commit**

```bash
git add tests/testthat/test-hc.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/hc tests/testthat/_snaps/zzz-unstable
git commit -m "Move file-snapshot hc tests out of zzz-unstable"
```

---

### Task 2: Move file-snapshot hp tests to test-hp.R

**Files:**
- Modify: `tests/testthat/test-hp.R`, `tests/testthat/test-zzz-unstable.R`
- Move: `_snaps/zzz-unstable/{hp_err_na,hp_err,hp_para,hp_nonpara}.csv` -> `_snaps/hp/`

**Interfaces:**
- Produces: `test-hp.R` gains tests "ssd_hp cis with error", "ssd_hp comparable parametric and non-parametric big sample size".

- [ ] **Step 1: Move the snapshot files**

```bash
cd tests/testthat
git mv _snaps/zzz-unstable/hp_err_na.csv _snaps/hp/hp_err_na.csv
git mv _snaps/zzz-unstable/hp_err.csv _snaps/hp/hp_err.csv
git mv _snaps/zzz-unstable/hp_para.csv _snaps/hp/hp_para.csv
git mv _snaps/zzz-unstable/hp_nonpara.csv _snaps/hp/hp_nonpara.csv
```

- [ ] **Step 2: Cut the two test blocks from `test-zzz-unstable.R`**

Cut `test_that("ssd_hp cis with error", {...})` (line ~510) and `test_that("ssd_hp comparable parametric and non-parametric big sample size", {...})` (line ~526), each complete block.

- [ ] **Step 3: Paste them verbatim at the end of `test-hp.R`**

- [ ] **Step 4: Run the hp tests**

Run: `Rscript -e 'testthat::test_local(filter = "^hp$", reporter = "summary")'`
Expected: all pass; no `Adding new file snapshot`; no `.new` files under `_snaps/hp/`.

- [ ] **Step 5: Confirm no stray `.new` files**

Run: `ls tests/testthat/_snaps/hp/*.new* 2>/dev/null && echo FOUND || echo CLEAN`
Expected: `CLEAN`

- [ ] **Step 6: Commit**

```bash
git add tests/testthat/test-hp.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/hp tests/testthat/_snaps/zzz-unstable
git commit -m "Move file-snapshot hp tests out of zzz-unstable"
```

---

### Task 3: Move gamma and lnorm_lnorm file-snapshot tests

**Files:**
- Modify: `tests/testthat/test-gamma.R`, `tests/testthat/test-lnorm-lnorm.R`, `tests/testthat/test-zzz-unstable.R`
- Move: `_snaps/zzz-unstable/tidy_gamma_unstable.csv` -> `_snaps/gamma/`; `_snaps/zzz-unstable/{tidy_anonb.csv,plot_anonb.png,lnorm_lnorm_no_se.csv}` -> `_snaps/lnorm-lnorm/`

**Interfaces:**
- Produces: `test-gamma.R` gains "gamma parameters are extremely unstable"; `test-lnorm-lnorm.R` gains "ssd_fit_dists lnorm_lnorm unstable with censored data", "lnorm_lnorm fits anonb", "lnorm_lnorm non-bimodal 1000 data".

- [ ] **Step 1: Move the snapshot files**

```bash
cd tests/testthat
mkdir -p _snaps/gamma _snaps/lnorm-lnorm
git mv _snaps/zzz-unstable/tidy_gamma_unstable.csv _snaps/gamma/tidy_gamma_unstable.csv
git mv _snaps/zzz-unstable/tidy_anonb.csv _snaps/lnorm-lnorm/tidy_anonb.csv
git mv _snaps/zzz-unstable/plot_anonb.png _snaps/lnorm-lnorm/plot_anonb.png
git mv _snaps/zzz-unstable/lnorm_lnorm_no_se.csv _snaps/lnorm-lnorm/lnorm_lnorm_no_se.csv
```

- [ ] **Step 2: Cut the four test blocks from `test-zzz-unstable.R`**

Cut `test_that("gamma parameters are extremely unstable", {...})` (line ~122) into `test-gamma.R`. Cut `test_that("ssd_fit_dists lnorm_lnorm unstable with censored data", {...})` (line ~16), `test_that("lnorm_lnorm fits anonb", {...})` (line ~627), and `test_that("lnorm_lnorm non-bimodal 1000 data", {...})` (line ~642) into `test-lnorm-lnorm.R`.

- [ ] **Step 3: Paste them verbatim at the end of the destination files**

Note: "lnorm_lnorm fits anonb" also calls `expect_snapshot_plot(..., "plot_anonb")`. `expect_snapshot_plot` skips on Windows/Linux, so `plot_anonb.png` only compares on macOS; the moved PNG covers that.

- [ ] **Step 4: Run the gamma and lnorm-lnorm tests**

Run: `Rscript -e 'testthat::test_local(filter = "^(gamma|lnorm-lnorm)$", reporter = "summary")'`
Expected: all pass; no `Adding new file snapshot`; no `.new` files under `_snaps/gamma/` or `_snaps/lnorm-lnorm/`.

- [ ] **Step 5: Confirm no stray `.new` files**

Run: `ls tests/testthat/_snaps/gamma/*.new* tests/testthat/_snaps/lnorm-lnorm/*.new* 2>/dev/null && echo FOUND || echo CLEAN`
Expected: `CLEAN`

- [ ] **Step 6: Commit**

```bash
git add tests/testthat/test-gamma.R tests/testthat/test-lnorm-lnorm.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/gamma tests/testthat/_snaps/lnorm-lnorm tests/testthat/_snaps/zzz-unstable
git commit -m "Move gamma and lnorm_lnorm unstable tests out of zzz-unstable"
```

---

### Task 4: Move non-snapshot weibull and invpareto tests

**Files:**
- Modify: `tests/testthat/test-weibull.R`, `tests/testthat/test-invpareto.R`, `tests/testthat/test-zzz-unstable.R`

**Interfaces:**
- Produces: `test-weibull.R` gains "weibull is sometimes unstable"; `test-invpareto.R` gains "invpareto with extreme data". Neither uses file snapshots.

- [ ] **Step 1: Cut the two test blocks from `test-zzz-unstable.R`**

Cut `test_that("weibull is sometimes unstable", {...})` (line ~30) into `test-weibull.R`, and `test_that("invpareto with extreme data", {...})` (line ~563) into `test-invpareto.R`.

- [ ] **Step 2: Paste them verbatim at the end of the destination files**

Keep the `skip()` / `skip_on_ci()` lines exactly as in the source.

- [ ] **Step 3: Run the weibull and invpareto tests**

Run: `Rscript -e 'testthat::test_local(filter = "^(weibull|invpareto)$", reporter = "summary")'`
Expected: all pass or skip as before; no `.new` files.

- [ ] **Step 4: Commit**

```bash
git add tests/testthat/test-weibull.R tests/testthat/test-invpareto.R tests/testthat/test-zzz-unstable.R
git commit -m "Move weibull and invpareto unstable tests out of zzz-unstable"
```

---

### Task 5: Create test-plot.R and move the plot tests

**Files:**
- Create: `tests/testthat/test-plot.R`
- Modify: `tests/testthat/test-zzz-unstable.R`
- Move: `_snaps/zzz-unstable/{geoms_all.png,boron_cens_pred_ribbon.png}` -> `_snaps/plot/`

**Interfaces:**
- Consumes: `expect_snapshot_plot` helper (skips on Windows/Linux; compares on macOS only).
- Produces: `test-plot.R` with tests "plot geoms" and "ssd_plot censored data".

- [ ] **Step 1: Move the snapshot files**

```bash
cd tests/testthat
mkdir -p _snaps/plot
git mv _snaps/zzz-unstable/geoms_all.png _snaps/plot/geoms_all.png
git mv _snaps/zzz-unstable/boron_cens_pred_ribbon.png _snaps/plot/boron_cens_pred_ribbon.png
```

- [ ] **Step 2: Cut the two test blocks into a new `test-plot.R`**

Cut `test_that("plot geoms", {...})` (line ~540) and `test_that("ssd_plot censored data", {...})` (line ~555) from `test-zzz-unstable.R` into a new file `tests/testthat/test-plot.R`. The file contains only those two `test_that` blocks, verbatim.

- [ ] **Step 3: Run the plot tests**

Run: `Rscript -e 'testthat::test_local(filter = "^plot$", reporter = "summary")'`
Expected: on macOS, snapshots compare and pass; on Windows/Linux they skip. No `.new` files under `_snaps/plot/`.

- [ ] **Step 4: Confirm no stray `.new` files**

Run: `ls tests/testthat/_snaps/plot/*.new* 2>/dev/null && echo FOUND || echo CLEAN`
Expected: `CLEAN`

- [ ] **Step 5: Commit**

```bash
git add tests/testthat/test-plot.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/plot tests/testthat/_snaps/zzz-unstable
git commit -m "Move plot tests out of zzz-unstable into test-plot.R"
```

---

### Task 6: Move hc/hp text-snapshot tests and regenerate their .md snapshots

**Files:**
- Modify: `tests/testthat/test-hc.R`, `tests/testthat/test-hp.R`, `tests/testthat/test-zzz-unstable.R`
- Modify: `_snaps/hc.md`, `_snaps/hp.md` (regenerated); `_snaps/zzz-unstable.md` (blocks removed)

**Interfaces:**
- These two tests use inline `testthat::expect_snapshot({...})` (text output), stored in `<file>.md` keyed by test title.

- [ ] **Step 1: Cut the two test blocks from `test-zzz-unstable.R`**

Cut `test_that("hc multi_ci lnorm default 100", {...})` (line ~64) into `test-hc.R`, and `test_that("hp multi_ci lnorm default 100", {...})` (line ~94) into `test-hp.R`. Paste verbatim, keeping `skip_on_ci()` and seeds.

- [ ] **Step 2: Remove the matching blocks from `_snaps/zzz-unstable.md`**

Delete the `# hc multi_ci lnorm default 100` section (heading through the line before the next `# ` heading) and the `# hp multi_ci lnorm default 100` section from `_snaps/zzz-unstable.md`. Save the removed text to compare against in Step 4.

- [ ] **Step 3: Regenerate the destination `.md` snapshots**

Run: `Rscript -e 'testthat::test_local(filter = "^(hc|hp)$")'`
This appends the `# hc multi_ci lnorm default 100` block to `_snaps/hc.md` and the `# hp multi_ci lnorm default 100` block to `_snaps/hp.md` (first run in the new file auto-adds the snapshot).

- [ ] **Step 4: Verify the regenerated snapshot text matches the original**

Run: `git -C ../.. diff -- tests/testthat/_snaps/hc.md tests/testthat/_snaps/hp.md`
Expected: the added blocks under `_snaps/hc.md` / `_snaps/hp.md` are byte-identical to the sections removed from `_snaps/zzz-unstable.md` (same `Code`/`Output`/`Condition` text). If they differ beyond the heading, stop and investigate before committing.

- [ ] **Step 5: Re-run to confirm the snapshot now compares clean**

Run: `Rscript -e 'testthat::test_local(filter = "^(hc|hp)$", reporter = "summary")'`
Expected: all pass; no `Adding new file snapshot`; no `.new` files.

- [ ] **Step 6: Commit**

```bash
git add tests/testthat/test-hc.R tests/testthat/test-hp.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/hc.md tests/testthat/_snaps/hp.md tests/testthat/_snaps/zzz-unstable.md
git commit -m "Move hc/hp multi_ci text-snapshot tests out of zzz-unstable"
```

---

### Task 7: Move sgompertz text-snapshot tests and regenerate gompertz.md

**Files:**
- Modify: `tests/testthat/test-gompertz.R`, `tests/testthat/test-zzz-unstable.R`
- Create: `_snaps/gompertz.md` (regenerated); Modify: `_snaps/zzz-unstable.md` (blocks removed)

**Interfaces:**
- The four sgompertz tests use inline `expect_snapshot({...})` (text). `_snaps/gompertz.md` does not yet exist and is created by regeneration.

- [ ] **Step 1: Cut the four test blocks from `test-zzz-unstable.R`**

Cut `test_that("sgompertz completely unstable!", {...})` (line ~138), `test_that("sgompertz with initial values still unstable!", {...})` (line ~155), `test_that("sgompertz cant even fit some values", {...})` (line ~194), and `test_that("sgompertz cant even initialize lots of values", {...})` (line ~209) into `test-gompertz.R`. Paste verbatim.

- [ ] **Step 2: Remove the matching four sections from `_snaps/zzz-unstable.md`**

Delete the four `# sgompertz ...` sections from `_snaps/zzz-unstable.md`. Save the removed text for comparison in Step 4.

- [ ] **Step 3: Regenerate `_snaps/gompertz.md`**

Run: `Rscript -e 'testthat::test_local(filter = "^gompertz$")'`
This creates `_snaps/gompertz.md` with the four sgompertz sections (added to the existing gompertz snapshots).

- [ ] **Step 4: Verify the regenerated text matches the original**

Run: `git -C ../.. diff --cached --stat; cat tests/testthat/_snaps/gompertz.md`
Compare the four sgompertz sections in the new `_snaps/gompertz.md` against the text removed from `_snaps/zzz-unstable.md` in Step 2. They must be identical apart from ordering. If any `Code`/`Condition`/`Output` text differs, stop and investigate.

- [ ] **Step 5: Re-run to confirm clean comparison**

Run: `Rscript -e 'testthat::test_local(filter = "^gompertz$", reporter = "summary")'`
Expected: all pass; no `Adding new file snapshot`; no `.new` files.

- [ ] **Step 6: Commit**

```bash
git add tests/testthat/test-gompertz.R tests/testthat/test-zzz-unstable.R tests/testthat/_snaps/gompertz.md tests/testthat/_snaps/zzz-unstable.md
git commit -m "Move sgompertz text-snapshot tests out of zzz-unstable"
```

---

### Task 8: Verify test-zzz-unstable.R is empty and its snapshot dir is drained

**Files:**
- Inspect: `tests/testthat/test-zzz-unstable.R`, `_snaps/zzz-unstable/`, `_snaps/zzz-unstable.md`

- [ ] **Step 1: Confirm no `test_that` blocks remain**

Run: `grep -c "test_that(" tests/testthat/test-zzz-unstable.R`
Expected: `0` (only leftover copyright/comment lines, if any, remain).

- [ ] **Step 2: Confirm the file snapshot dir is empty**

Run: `ls tests/testthat/_snaps/zzz-unstable/ 2>/dev/null | wc -l`
Expected: `0`

- [ ] **Step 3: Confirm the `.md` has no remaining sections**

Run: `grep -c "^# " tests/testthat/_snaps/zzz-unstable.md`
Expected: `0`

If any of these are non-zero, a test was missed; return to the relevant task before proceeding.

---

### Task 9: Delete the emptied zzz-unstable files and run the full suite

**Files:**
- Delete: `tests/testthat/test-zzz-unstable.R`, `tests/testthat/_snaps/zzz-unstable.md`, `tests/testthat/_snaps/zzz-unstable/`

- [ ] **Step 1: Delete the emptied files**

```bash
cd tests/testthat
git rm test-zzz-unstable.R
git rm _snaps/zzz-unstable.md
git rm -r _snaps/zzz-unstable
```

- [ ] **Step 2: Run the full test suite**

Run: `Rscript -e 'testthat::test_local(reporter = "summary")'`
Expected: same pass/skip counts as before the reorganization (the same tests run, just from different files); no `.new` files anywhere under `_snaps/`.

- [ ] **Step 3: Confirm no stray `.new` files across all snapshots**

Run: `find tests/testthat/_snaps -name '*.new*'`
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add -A tests/testthat
git commit -m "Remove emptied test-zzz-unstable.R and its snapshots"
```

---

### Task 10: Open the draft PR into dev

- [ ] **Step 1: Push the branch**

```bash
git push -u origin reorganize-tests
```

- [ ] **Step 2: Open the draft PR**

```bash
gh pr create --draft --repo poissonconsulting/ssdtests --base dev --head poissonconsulting:reorganize-tests \
  --title "Reorganize tests: dissolve test-zzz-unstable.R into subject files" \
  --body "Moves the 19 tests in test-zzz-unstable.R into their subject files (hc, hp, gamma, lnorm-lnorm, weibull, invpareto, gompertz) and a new test-plot.R, so tests are organized by subject rather than by the cross-cutting 'unstable' property. File snapshots move byte-for-byte with git mv; text (.md) snapshots are regenerated in the destination file and verified identical to the originals. No test logic, seed, or skip guard changes."
```

- [ ] **Step 3: Monitor CI**

Watch the R-CMD-check / test-coverage / pkgdown checks. Because most moved tests are `skip_on_ci()`, CI mainly exercises the file relocation; expect the same result as `dev` before the change.

## Self-Review

**Spec coverage:** All 19 tests in the move map are assigned to a task (Tasks 1-7), Task 8 verifies drainage, Task 9 deletes and runs the full suite, Task 10 ships the PR. The two out-of-scope items (mirror ssdtools names, helper standardization) are recorded under Global Constraints.

**Placeholder scan:** No TODO/TBD; every step has an exact command and expected output. Test blocks are moved verbatim (their code already exists in the repo), so the plan references them by title and line rather than reproducing the bodies, which is correct for a pure move.

**Type consistency:** Snapshot names are used consistently between the `git mv` destination path and the `expect_snapshot_*` call that reads them (e.g. `hc_err.csv` -> `_snaps/hc/`, read by `expect_snapshot_data(..., "hc_err")`). Destination dirs confirmed collision-free.
