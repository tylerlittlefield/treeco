extract_data <- function(data, common_col, botanical_col, dbh_col, region) {

  # Might need to remove NA's first? Given the keep.rownames=TRUE?
  ifelse(
    test = is.object(data),
    yes = trees <- data.table::as.data.table(data, keep.rownames = TRUE),
    no = trees <- data.table::fread(data)
  )

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
  trees$dbh_val <- trees$dbh_val * 2.54

  output <- list(
    trees = trees,
    benefits = benefits,
    species = species,
    money = money
  )

  return(output)
}
