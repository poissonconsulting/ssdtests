# Report the simple line coverage of ssdtools produced by the ssdtests suite.
#
# The ssdtools source is matched to the current ssdtests repo and branch: the
# org is the owner of the `origin` remote and the branch is the same-named
# branch on {org}/ssdtools (falling back to that repo's default branch). So
# poissonconsulting/ssdtests@dev is measured against poissonconsulting/ssdtools@dev,
# bcgov/ssdtests@main against bcgov/ssdtools@main, and so on.
#
# Usage:
#   Rscript scripts/ssdtools-coverage.R [--ref <branch>] [--filter <regex>] [--all]
#
#   --ref <branch>    Override the ssdtools branch to measure against.
#   --filter <regex>  Only run ssdtests test files matching this regex
#                     (matched against the name after stripping "test-"/".R").
#   --all             Include test-fit-random-small.R (excluded by default
#                     because 20000 instrumented fits take hours and add no
#                     new ssdtools coverage).

suppressMessages(library(covr))

args <- commandArgs(trailingOnly = TRUE)
get_opt <- function(flag) {
  i <- match(flag, args)
  if (is.na(i) || i == length(args)) NULL else args[[i + 1]]
}
ref_override <- get_opt("--ref")
filter_override <- get_opt("--filter")
include_all <- "--all" %in% args

ssdtests_root <- normalizePath(".")
tests_dir <- file.path(ssdtests_root, "tests", "testthat")

git <- function(...) system2("git", c(...), stdout = TRUE, stderr = FALSE)

# --- resolve org and ssdtools ref ------------------------------------------
origin <- git("remote", "get-url", "origin")
org <- sub(".*github\\.com[:/]([^/]+)/.*", "\\1", origin)
branch <- git("rev-parse", "--abbrev-ref", "HEAD")
url <- sprintf("https://github.com/%s/ssdtools.git", org)

if (!is.null(ref_override)) {
  ref <- ref_override
} else {
  has_branch <- length(git("ls-remote", "--heads", url, branch)) > 0
  if (has_branch) {
    ref <- branch
  } else {
    symref <- git("ls-remote", "--symref", url, "HEAD")
    ref <- sub("^ref: refs/heads/(\\S+)\\s+HEAD$", "\\1", symref[grepl("^ref:", symref)])
    message("Branch '", branch, "' not on ", org, "/ssdtools; using default '", ref, "'.")
  }
}

# --- build the test filter --------------------------------------------------
if (!is.null(filter_override)) {
  filter <- filter_override
} else {
  names <- sub("^test-(.*)\\.R$", "\\1", list.files(tests_dir, pattern = "^test-.*\\.R$"))
  if (!include_all) names <- setdiff(names, "fit-random-small")
  filter <- paste0("^(", paste(names, collapse = "|"), ")$")
}

# --- clone the matching ssdtools source ------------------------------------
clone <- tempfile("ssdtools-")
on.exit(unlink(clone, recursive = TRUE), add = TRUE)
message("Cloning ", org, "/ssdtools@", ref, " ...")
status <- system2("git", c("clone", "--depth", "1", "--branch", ref, url, clone))
if (status != 0) stop("Failed to clone ", url, " at ", ref)

# --- instrument ssdtools and run the ssdtests suite against it --------------
message("Instrumenting ssdtools and running ssdtests (filter: ", filter, ") ...")
code <- sprintf(
  'testthat::test_local("%s", filter = "%s", stop_on_failure = FALSE, reporter = "silent")',
  ssdtests_root, filter
)
cov <- covr::package_coverage(path = clone, type = "none", code = code)

# --- report -----------------------------------------------------------------
tc <- covr::tally_coverage(cov)
per_file <- sort(vapply(
  split(tc$value, basename(tc$filename)),
  function(v) round(100 * mean(v > 0), 1),
  numeric(1)
))

cat("\n", strrep("=", 60), "\n", sep = "")
cat(sprintf("ssdtools coverage from ssdtests (%s/ssdtools@%s)\n", org, ref))
cat(strrep("=", 60), "\n", sep = "")
cat(sprintf("Overall: %.2f%%  (%d of %d lines)\n\n",
            covr::percent_coverage(cov), sum(tc$value > 0), nrow(tc)))
cat("Per file (%):\n")
print(data.frame(coverage = per_file))
