# Copyright 2023 Environment and Climate Change Canada
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

local_multisession <- function(.local_envir = parent.frame(), workers = 2) {
  oldDoPar <- doFuture::registerDoFuture()
  withr::defer_parent(with(oldDoPar, foreach::setDoPar(fun = fun, data = data, info = info)))
  oldPlan <- future::plan("future::multisession", workers = workers)
  withr::defer_parent(future::plan(oldPlan))
  invisible(oldDoPar)
}

save_png <- function(x, width = 400, height = 400) {
  path <- tempfile(fileext = ".png")
  grDevices::png(path, width = width, height = height)
  on.exit(grDevices::dev.off())
  print(x)

  path
}

save_csv <- function(x) {
  path <- tempfile(fileext = ".csv")
  readr::write_csv(x, path)
  path
}

expect_snapshot_plot <- function(x, name) {
  testthat::skip_on_os("windows")
  testthat::skip_on_os("linux")

  path <- save_png(x)
  testthat::expect_snapshot_file(path, paste0(name, ".png"))
}

# Bootstrap compatibility limits (lcl/ucl/se) depend on refits that diverge
# across BLAS/LAPACK implementations, so their exact snapshot only holds on the
# platform that generated it. Tests that snapshot bootstrap CIs must call
# skip_on_ci() before the bootstrap; this helper still asserts the structural
# pboot bounds, which hold on every platform. See CONTRIBUTING.md.
expect_snapshot_boot_data <- function(x, name, digits = 6, min_pboot = 0.9, max_pboot = 1) {
  if (!is.na(min_pboot) && min_pboot > 0) {
    testthat::expect_true(all(x$pboot >= min_pboot))
  }
  if (!is.na(min_pboot) && max_pboot < 1) {
    testthat::expect_true(all(x$pboot <= max_pboot))
  }
  x$pboot <- NULL
  expect_snapshot_data(x, name, digits = digits)
}

expect_snapshot_data <- function(x, name, digits = 6, delist = FALSE) {
  fun <- function(x) if(is.numeric(x)) signif(x, digits = digits) else x
  x <- dplyr::mutate(x, dplyr::across(where(is.numeric), fun))

  if(!delist) {
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

ep <- function(text) {
  invisible(eval(parse(text = text)))
}

test_dist2 <- function(dist, upadj = 0, multi = FALSE) {
  if (!multi) {
    withr::with_seed(97, {
      data <- data.frame(Conc = ep(glue::glue("ssd_r{dist}(500)")))
    })
    fits <- ssd_fit_dists(data = data, dists = dist)
    tidy <- tidy(fits)
    testthat::expect_s3_class(tidy, "tbl_df")
    testthat::expect_identical(names(tidy), c("dist", "term", "est", "se"))
    testthat::expect_identical(tidy$dist[1], dist)
    tidy$lower <- tidy$est - tidy$se * 3
    tidy$upper <- tidy$est + tidy$se * 3

    default <- ep(glue::glue("formals(ssd_r{dist})"))
    default$n <- NULL
    default$chk <- NULL
    default <- data.frame(term = names(default), default = unlist(default))

    tidy <- merge(tidy, default, by = "term", all = "TRUE")
    testthat::expect_true(all(tidy$default > tidy$lower - upadj))
    testthat::expect_true(all(tidy$default < tidy$upper + upadj))
  }
}
