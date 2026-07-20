
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ssdtests

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/poissonconsulting/ssdtests/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/ssdtests/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of ssdtests is to hold the slow and unstable tests for the
[ssdtools](https://github.com/bcgov/ssdtools) package. It has no
user-facing functionality of its own.

A test belongs here rather than in ssdtools when it cannot run reliably
or quickly as part of ssdtools’ own CRAN-facing suite: exact parametric
bootstrap confidence-limit snapshots that are not reproducible across
platforms, slow tests such as fitting every curated dataset to every
distribution, and numerically unstable fits. ssdtools keeps the fast,
portable, structural assertions for the same code paths.

The tests are organised by subject in `tests/testthat/` (one
`test-<subject>.R` file per distribution or function), and
`scripts/ssdtools-coverage.R` reports the ssdtools coverage the suite
produces. See `vignette("ssdtests")` for an overview and
`CONTRIBUTING.md` for the conventions.

## Installation

You can install the development version of ssdtests from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
pak::pak("bcgov/ssdtests")
```

## Licensing

Copyright 2018-2025 Province of British Columbia\
Copyright 2021-2025 Environment and Climate Change Canada\
Copyright 2023-2026 Australian Government Department of Climate Change,
Energy, the Environment and Water

The documentation is released under the [CC BY 4.0
License](https://creativecommons.org/licenses/by/4.0/)

The code is released under the [Apache License
2.0](https://www.apache.org/licenses/LICENSE-2.0)
