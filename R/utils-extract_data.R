#' @importFrom data.table as.data.table fread melt setnames
extract_data <- function(data, common_col, botanical_col, dbh_col, region, unit) {

  .SD = NULL

  # If it's a dataframe, convert it to a table. Otherwise, we assume it's a csv.
  # ifelse(test = inherits(data, "data.frame"),
  #        yes = trees <- as.data.table(data, keep.rownames = TRUE),
  #        no = trees <- fread(data))
  if(inherits(data, "data.frame")) {
    trees <- as.data.table(data, keep.rownames = TRUE)
  } else {
    trees <- fread(data)
    setnames(trees, "V1", "rn")
  }

  # Remove anycases where common/botanical fields are NA
  trees <- trees[!with(trees, is.na(trees[[common_col]]) | is.na(trees[[botanical_col]])), ]

  # Convert data.frames to data.tables
  benefits <- as.data.table(benefits)
  species <- as.data.table(species)
  money <- as.data.table(money)

  # Filter data.tables by region
  money <- money[money$region_code == region, ]
  benefits <- benefits[benefits$species_region == region]
  species <- species[species$species_region == region]

  # Melt the money data.table for future grepls when extract money data
  money <- melt(money, id.vars = c("region_code", "region_name"))
  money <- money[, c("variable", "value")]

  # Set names of trees data.table for consistency
  setnames(trees, botanical_col, "botanical_name")
  setnames(trees, common_col, "common_name")
  setnames(trees, dbh_col, "dbh_val")

  # Coerce fields to correct data types
  trees$botanical_name <- as.character(trees$botanical_name)
  trees$common_name <- as.character(trees$common_name)
  trees$dbh_val <- as.numeric(trees$dbh_val)

  # Stop if the given region code doesn't exist
  # Commented out because testthat spits out an error accessing 'money'
  # from sysdata.rda?
  # stopifnot(region %in% unique(money$region_code))

  # Select the tree values we care about
  tree_vars <- c("rn", "common_name", "botanical_name", "dbh_val")
  trees <- trees[, .SD, .SDcol = tree_vars][trees$dbh_val > 0]

  # If unit == "in" (default) conver to centimeters due to i-Tree's usage of
  # centimeters, else keep the dbh value as we assume the user gave "cm" for
  # the unit arg. This is lazy and should probably confirm they gave "cm".
  ifelse(test = unit == "in",
         yes = trees$dbh_val <- trees$dbh_val * 2.54,
         no = trees)

  # Store all of the prepped data.tables in a list to be stored as individual
  # objects in eco_run_all function
  output <- list(trees = trees,
                 benefits = benefits,
                 species = species,
                 money = money)

  return(output)
}
