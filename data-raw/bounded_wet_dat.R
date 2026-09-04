low_tox_wet_dat <- readr::read_csv(
  "data-raw/low_tox_bounded_wet_dat.csv",
  col_types = readr::cols(.default = "c")
) |>
  tidyr::pivot_longer(
    cols = dplyr::starts_with("Sample"),
    names_to = "Sample_ID",
    values_to = "Conc"
  ) |>
  dplyr::mutate(Conc = as.numeric(gsub(">", "", Conc))) |>
  dplyr::select(Species = `...1`, Sample_ID, Conc) |>
  dplyr::mutate(
    Species = gsub("Species ", "sp_", Species),
    Sample_ID = gsub("Sample ", "rep_", Sample_ID)
  )
dput(low_tox_wet_dat)
