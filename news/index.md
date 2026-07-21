# Changelog

## ssdtests 0.2.0

- Added regression tables that fit every curated ssddata dataset:
  model-averaged BCANZ hazard concentrations (`test-bcanz-hc`) and
  per-distribution HC5 as a percentage of the geometric mean of the data
  (`test-hc5-gm`).
- Added `scripts/ssdtools-coverage.R` to report the ssdtools line
  coverage produced by the ssdtests suite.
- Added an introductory vignette
  ([`vignette("ssdtests")`](https://poissonconsulting.github.io/ssdtests/articles/ssdtests.md))
  and expanded the README.
- Reorganized the tests by subject and documented the snapshot-stability
  conventions and the ssdtests-versus-ssdtools placement rule in
  `CONTRIBUTING.md`.
- Standardized continuous integration on the poissonconsulting reusable
  workflows.
- Test hygiene: revived or removed permanently-skipped tests, removed
  redundant tests, and pruned unused dependencies.

## ssdtests 0.1.0

- Initial release version.
