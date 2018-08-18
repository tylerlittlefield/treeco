# For CMD check, removes some of the notes
utils::globalVariables(c(":=", ".I"))

#-------------------------------------------------------------------------------
# Interpolation function
#-------------------------------------------------------------------------------
eco_interp <- function(x, x1, y1, x2, y2) {

  y = ((x - x1) * (y2 - y1) / (x2 - x1)) + y1
  return(y)

}

#-------------------------------------------------------------------------------
# String similarity function
#-------------------------------------------------------------------------------
string_dist <- function(str_1, str_2) {

  1 - (utils::adist(str_1, str_2) / pmax(nchar(str_1), nchar(str_2)))

}

#' Run eco benefits for a tree
#'
#' @param data path to csv file containing tree inventory
#' @param species_col the name of the column containing common names of species
#' @param dbh_col the name of the column containing dbh values
#' @param region region code, see \code{species_data} or \code{eco_data}
#'
#' @export
eco_run_all <- function(data, species_col, dbh_col, region) {

  message("Importing: ", basename(data), "...")

  # import data
  eco_tbl <- data.table::as.data.table(treeco::eco_data)
  species_tbl <- data.table::as.data.table(treeco::species_data)
  trees_tbl <- data.table::fread(data, stringsAsFactors = FALSE)

  message(basename(data), " imported.")

  message("Reconfiguring data...")

  trees_tbl <- trees_tbl[, c(species_col, dbh_col), with = FALSE]
  trees_tbl[, ("id") := 1:nrow(trees_tbl)]
  trees_tbl <- trees_tbl[, c("id", species_col, dbh_col), with = FALSE]
  data.table::setnames(trees_tbl, species_col, "common_name")
  data.table::setnames(trees_tbl, dbh_col, "dbh_val")

  message("Data reconfigured.")

  unique_common_names <- unique(trees_tbl, by = "common_name")[["common_name"]]

  species_tbl <- species_tbl[species_tbl$common_name %in% unique_common_names]

  # Subset data by region
  eco_tbl <- eco_tbl[eco_tbl$species_region == region]
  species_tbl <- species_tbl[species_tbl$species_region == region, ]

  species_tbl <- species_tbl[, c("scientific_name", "common_name", "species_code", "spp_value_assignment")]

  message("Guessing species codes...")

  # Guess and grab species_codes
  vector <- integer(0)
  for (i in unique(unique_common_names))
    vector[i] <- which.max(string_dist(i, species_tbl$common_name))
  trees_tbl$species_code <- species_tbl$species_code[vector]

  message("Species codes gathered.")

  data.table::setkey(trees_tbl, "species_code")
  data.table::setkey(species_tbl, "species_code")

  message("Linking species codes to the data...")

  trees_tbl <- trees_tbl[species_tbl, allow.cartesian = TRUE]

  message("Species codes linked.")

  data.table::setkey(trees_tbl, NULL)
  data.table::setkey(species_tbl, NULL)

  # Don't need to grab unique ids anymore?

  unique_value_assignments <- unique(trees_tbl, by = "spp_value_assignment")[["spp_value_assignment"]]
  eco_tbl <- eco_tbl[eco_tbl$species_code %in% unique_value_assignments]

  trees_tbl <- trees_tbl[, c("id", "scientific_name", "common_name", "dbh_val", "spp_value_assignment")]
  eco_tbl <- eco_tbl[, c("species_code", "dbh_range", "benefit_value", "benefit", "unit")]

  data.table::setkey(trees_tbl, "spp_value_assignment")
  data.table::setkey(eco_tbl, "species_code")

  message("Calculating benefits for ", length(unique(trees_tbl$id)), " trees...")

  trees_tbl <- trees_tbl[eco_tbl, nomatch=0L, allow.cartesian=TRUE]

  data.table::setkey(trees_tbl, NULL)
  data.table::setkey(eco_tbl, NULL)

  # Calculate absolute value of dbh - dbh_range
  trees_tbl[, ("dbh_diff") := abs(trees_tbl$dbh_val - trees_tbl$dbh_range)]

  # Sort dbh_diff in ascending order
  data.table::setkey(trees_tbl, "dbh_diff")

  # Grab the first two records grouped by benefit and id, this will be the lowest dbh_diff values
  trees_tbl <- trees_tbl[trees_tbl[, .I[1:2], c("benefit", "id")]$V1]

  data.table::setkey(trees_tbl, NULL)

  # Sort dbh_range in ascending order
  data.table::setkey(trees_tbl, "dbh_range")

  # Need to figure out how to remove the CMD Check Notes resulting from dbh_range and benefit_value
  trees_tbl[, ("x1") := min(dbh_range), by = "id"]
  trees_tbl[, ("x2") := max(dbh_range), by = "id"]
  trees_tbl[, ("y1") := benefit_value[1], by = c("id", "benefit")]
  trees_tbl[, ("y2") := benefit_value[2], by = c("id", "benefit")]

  trees_tbl[, ("benefit_value") := eco_interp(x = trees_tbl$dbh_val, x1 = trees_tbl$x1, x2 = trees_tbl$x2, y1 = trees_tbl$y1, y2 = trees_tbl$y2)]

  trees_tbl <- trees_tbl[, c("id", "scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit")]

  trees_tbl <- unique(trees_tbl, by = c("id", "benefit"))

  trees_tbl[, "benefit_value" := round(trees_tbl$benefit_value, 4)]

  data.table::setnames(trees_tbl, "dbh_val", "dbh")

  trees_tbl <- trees_tbl[!is.na(trees_tbl$common_name), ]

  data.table::setkey(trees_tbl, "id")

  message("Complete.")

  return(trees_tbl)

}
