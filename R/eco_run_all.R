#' Run eco benefits for an entire tree inventory
#'
#' @param data path to csv file containing tree inventory
#' @param common_col the name of the column containing common names
#' @param botanical_col the name of the column containing botanical names
#' @param dbh_col the name of the column containing dbh values
#' @param region region code, see \code{species} or \code{benefits}
#' @param print_time Logical TRUE or FALSE for printing the elapsed time
#'
#' @import data.table
#' @export
eco_run_all <- function(data, common_col, botanical_col, dbh_col, region, print_time = NULL) {

  start_time <- Sys.time()

  # Extract and reshape the input data
  tree_data <- extract_data(data, common_col, botanical_col, dbh_col, region)

  # Output is stored in a list, assign each list element to an object
  trees <- tree_data$trees
  benefits <- tree_data$benefits
  species <- tree_data$species
  money <- tree_data$money

  # Extract the species matches with a similarity score > 90%
  matches <- extract_matches(tree_data = trees, species_data = species)

  # Output is (again) stored as a list, assign each list element to an object
  trees <- matches$trees
  trees_unique <- matches$trees_unique

  # Set keys to join data to benefit data
  data.table::setkey(trees_unique, "spp_value_assignment")
  data.table::setkey(benefits, "species_code")
  data.table::setkey(trees, "spp_value_assignment")

  # Join the data
  trees_unique <- trees_unique[benefits, allow.cartesian=TRUE]
  trees <- trees[benefits, allow.cartesian=TRUE]

  # Extract x, x1, x2, y1, y2 values for interpolation function
  trees_unique <- extract_parameters(trees_unique)

  # Select the variables we need
  tree_vars <- c("id", "botanical_name", "common_name", "dbh_val", "x1", "x2", "y1", "y2", "benefit", "unit")
  trees_unique <- trees_unique[, .SD, .SDcols = tree_vars]

  message("Interpolating benefits...")

  # Extract the benefit values given the x, x1, x2, y1, y2 values we just gathered
  trees_unique <- extract_benefits(trees_unique)

  # Select variables we need
  tree_vars <- c("id", "common_name", "dbh_val", "benefit")
  trees <- trees[, .SD, .SDcols = tree_vars]

  # Remove any NA values
  trees_unique <- stats::na.omit(trees_unique)
  trees <- stats::na.omit(trees)

  # Extract the money benefits
  trees_unique <- extract_money(trees_unique, money)

  # Set keys to join the unique trees (which has had all the stuff done to it)
  # and join to the original/full dataset
  data.table::setkey(trees, "common_name", "dbh_val", "benefit")
  data.table::setkey(trees_unique, "common_name", "dbh_val", "benefit")

  # Join the data, store as a separate object called 'trees_final'
  trees_final <- trees[trees_unique, allow.cartesian=TRUE]

  # i-Tree requires centimeters so converting back to inches
  trees_final$dbh_val <- round(trees_final$dbh_val * 0.393701, 2)

  # Set key as 'id' to get the data sorted by 'id'
  data.table::setkey(trees_final, "id")

  # Grab the variables we need
  tree_vars <- c("id", "botanical_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit", "dollars")
  trees_final <- trees_final[, .SD, .SDcols = tree_vars]

  # Capitalize the first word of common name
  trees_final$common_name <- capitalize(trees_final[["common_name"]])
  trees_final$botanical_name <- capitalize(trees_final[["botanical_name"]])

  # Rename the 'dbh_val' var to just 'dbh'
  data.table::setnames(trees_final, "dbh_val", "dbh")
  data.table::setnames(trees_final, "common_name", "common")
  data.table::setnames(trees_final, "botanical_name", "botanical")

  end_time <- Sys.time()
  elapsed_time <- end_time - start_time

  if(isTRUE(print_time)) {
    et <- utils::capture.output(elapsed_time);
    message(et);
    attr(trees_final, "elapsed_time") <- elapsed_time
    }

  return(trees_final)
}
