#' Eco benefits for multiple trees
#'
#' @description This function calculates the benefits for an entire dataset,
#' sometimes called a tree inventory. This works similar to i-Trees Eco software
#' where the user supplies data, the common name field, the botanical name
#' field, the dbh field, and the region. All calculations are done on unique
#' species/dbh pairs to avoid redundant computation and speed up the
#' calculation.
#'
#' @param data path to csv file containing tree inventory
#' @param common_col the name of the column containing common names
#' @param botanical_col the name of the column containing botanical names
#' @param dbh_col the name of the column containing dbh values
#' @param region region code, see \code{species} or \code{benefits}
#' @param n guessing threshold from 0.0 to 1.0, defaults at 0.8
#' @param print_time Logical TRUE or FALSE for printing the elapsed time
#'
#' @import data.table
#' @export
eco_run_all <- function(data, common_col, botanical_col, dbh_col, region, n = 0.8, print_time = NULL) {

  start_time <- Sys.time()

  if(n > 1){
    warning("n > 1, please use a number from 0-1. Using 0.8, finding matches that are 80% similar.", call. = FALSE)
    n <- 0.8
  }
  if(n < 0){
    warning("n < 0, please use a number from 0-1. Using 0.8, finding matches that are 80% similar.", call. = FALSE)
    n <- 0.8
  }

  # Extract and reshape the input data
  tree_data <- extract_data(data, common_col, botanical_col, dbh_col, region)

  # Output is stored in a list, assign each list element to an object
  trees <- tree_data$trees
  benefits <- tree_data$benefits
  species <- tree_data$species
  money <- tree_data$money

  # Extract the species matches with a similarity score > 80% by default
  matches <- extract_matches(tree_data = trees, species_data = species, n = n)

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
  tree_vars <- c("id", "botanical_name", "common_name", "dbh_val", "x1", "x2", "y1", "y2", "benefit", "unit", "rn")
  trees_unique <- trees_unique[, .SD, .SDcols = tree_vars]

  message("Interpolating benefits...")

  # Extract the benefit values given the x, x1, x2, y1, y2 values we just gathered
  trees_unique <- extract_benefits(trees_unique)

  # Select variables we need
  tree_vars <- c("id", "rn", "common_name", "dbh_val", "benefit")
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
  tree_vars <- c("id", "botanical_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit", "dollars", "rn")
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
