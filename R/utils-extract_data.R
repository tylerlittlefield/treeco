extract_data <- function(data, common_col, botanical_col, dbh_col, region, unit) {

  # Might need to remove NA's first? Given the keep.rownames=TRUE?
  ifelse(
    test = inherits(data, "data.frame"),
    yes = trees <- data.table::as.data.table(data, keep.rownames = TRUE),
    no = trees <- data.table::fread(data)
  )

  # Remove NA's if an in common or botanical col
  # discarded_records <- dim(trees)[1] - dim(trees[!with(trees, is.na(trees[[common_col]]) | is.na(trees[[botanical_col]])), ])[1]
  #
  # warning_message <- paste0(discarded_records, " records were discarded due to missing common or botanical names. Please use eco_guess to resolve these missing values.")
  #
  # if(discarded_records > 0)
  #   warning(warning_message, call. = FALSE)

  trees <- trees[!with(trees, is.na(trees[[common_col]]) | is.na(trees[[botanical_col]])), ]

  # trees  <- data.table::fread(data, select = c(common_col, botanical_col, dbh_col))
  benefits <- data.table::as.data.table(treeco::benefits)
  species  <- data.table::as.data.table(treeco::species)
  money    <- data.table::as.data.table(treeco::money)
  money    <- money[money$region_code == region, ]
  money    <- data.table::melt(money, id.vars = c("region_code", "region_name"))
  money    <- money[, c("variable", "value")]

  data.table::setnames(trees, botanical_col, "botanical_name")
  data.table::setnames(trees, common_col, "common_name")
  data.table::setnames(trees, dbh_col, "dbh_val")

  trees$botanical_name <- as.character(trees$botanical_name)
  trees$common_name <- as.character(trees$common_name)
  trees$dbh_val <- as.numeric(trees$dbh_val)

  # Assert that the common_name is character, the dbh column is numeric, and
  # the region parameter exists.
  stopifnot(
    is.character(trees$botanical_name),
    is.character(trees$common_name),
    is.numeric(trees$dbh_val),
    region %in% unique(treeco::money$region_code)
  )

  trees <- trees[, .SD, .SDcol = c("rn", "common_name", "botanical_name", "dbh_val")][trees$dbh_val > 0]
  benefits <- benefits[benefits$species_region == region]
  species <- species[species$species_region == region]

  ifelse(
    test = unit == "in",
    yes = trees$dbh_val <- trees$dbh_val * 2.54,
    no = trees
    )

  output <- list(
    trees = trees,
    benefits = benefits,
    species = species,
    money = money
  )

  return(output)
}
