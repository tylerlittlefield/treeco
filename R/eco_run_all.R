#-------------------------------------------------------------------------------
# Interpolation function
#-------------------------------------------------------------------------------
eco_interp <- function(x, x1, y1, x2, y2) {

  # Assert that the interpolation values are numeric
  stopifnot(
    is.numeric(x),
    is.numeric(x1),
    is.numeric(y1),
    is.numeric(x2),
    is.numeric(y2)
  )

  message("Interpolating benefits...")

  y = ((x - x1) * (y2 - y1) / (x2 - x1)) + y1
  return(y)
}

#-------------------------------------------------------------------------------
# String similarity function
#-------------------------------------------------------------------------------
string_dist <- function(str_1, str_2) {

  # Assert that "str_1" and "str_2" are characters
  stopifnot(
    is.character(str_1),
    is.character(str_2)
  )

  1 - (utils::adist(str_1, str_2) / pmax(nchar(str_1), nchar(str_2)))
}

# ------------------------------------------------------------------------------
# Data extract function
# ------------------------------------------------------------------------------
extract_data <- function(data, species_col, dbh_col, region) {

  message("Importing ", basename(data), "...")

  trees    <- data.table::fread(data)
  benefits <- data.table::as.data.table(treeco::benefits)
  species  <- data.table::as.data.table(treeco::species)
  money    <- data.table::as.data.table(treeco::money)
  money    <- money[money$region_code == region, ]
  money    <- data.table::melt(money, id.vars = c("region_code", "region_name"))
  money    <- money[, c("variable", "value")]

  data.table::setnames(trees, species_col, "common_name")
  data.table::setnames(trees, dbh_col, "dbh_val")

  trees         <- trees[, .SD, .SDcol = c("common_name", "dbh_val")][trees$dbh_val > 0]
  benefits      <- benefits[grepl(region, species_region)]
  species       <- species[grepl(region, species_region)]
  trees$dbh_val <- trees$dbh_val * 2.54

  # Assert that the common_name is character, the dbh column is numeric, and
  # the region parameters exists.
  stopifnot(
    is.character(trees$common_name),
    is.numeric(trees$dbh_val),
    region %in% unique(treeco::money$region_code)
  )

  output <- list(trees = trees,
                 benefits = benefits,
                 species = species,
                 money = money)

  return(output)
}

#-------------------------------------------------------------------------------
# Money extract function
#-------------------------------------------------------------------------------
extract_money <- function(tree_data, money_data) {

  elec_money <- money_data[grepl("electricity", money_data$variable)][["value"]]
  gas_money  <- money_data[grepl("natural_gas", money_data$variable)][["value"]]
  h20_money  <- money_data[grepl("h20_gal", money_data$variable)][["value"]]
  co2_money  <- money_data[grepl("co2", money_data$variable)][["value"]]
  o3_money   <- money_data[grepl("o3_lb", money_data$variable)][["value"]]
  nox_money  <- money_data[grepl("nox_lb", money_data$variable)][["value"]]
  pm10_money <- money_data[grepl("pm10_lb", money_data$variable)][["value"]]
  sox_money  <- money_data[grepl("sox_lb", money_data$variable)][["value"]]
  voc_money  <- money_data[grepl("voc_lb", money_data$variable)][["value"]]

  tree_data[grepl("lb", unit), "benefit_value" := benefit_value * 2.20462]
  tree_data[grepl("gal", unit), "benefit_value" := benefit_value * 264.172052]

  tree_data[grepl("electricity", benefit), "dollars" := benefit_value * elec_money]
  tree_data[grepl("natural gas", benefit), "dollars" := benefit_value * gas_money]
  tree_data[grepl("hydro interception", benefit), "dollars" := benefit_value * h20_money]
  tree_data[grepl("co2 ", benefit), "dollars" := benefit_value * co2_money]
  tree_data[grepl("aq ozone dep", benefit), "dollars" := benefit_value * o3_money]
  tree_data[grepl("aq nox", benefit), "dollars" := benefit_value * nox_money]
  tree_data[grepl("aq pm10", benefit), "dollars" := benefit_value * pm10_money]
  tree_data[grepl("aq sox", benefit), "dollars" := benefit_value * sox_money]
  tree_data[grepl("voc", benefit), "dollars" := benefit_value * voc_money]

  tree_data$dollars       <- abs(round(tree_data$dollars, 2))
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)

  return(tree_data)
}

#-------------------------------------------------------------------------------
# Parameter extract function (for interpolation equation)
#-------------------------------------------------------------------------------
extract_parameters <- function(tree_data) {

  message("Gathering interpolation parameters...")

  dbh_values <- tree_data[["dbh_val"]]
  dbh_ranges <- c(3.81, 11.43, 22.86, 38.10, 53.34, 68.58, 83.82, 99.06, 114.30)

  z <- abs(outer(dbh_values, dbh_ranges, `-`))

  tree_data   <- stats::na.omit(tree_data)
  tree_data$a <- unlist(apply(z, 1, which.min))
  z[z==apply(z, 1, min)] <- Inf
  tree_data$b     <- unlist(apply(z, 1, which.min))
  tree_data$start <- pmin(tree_data$a, tree_data$b)
  tree_data$end   <- pmax(tree_data$a, tree_data$b)
  tree_data$x1    <- dbh_ranges[tree_data$start]
  tree_data$x2    <- dbh_ranges[tree_data$end]

  # Grab the benefit values given the start/end vectors
  # https://stackoverflow.com/questions/20617371/
  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y1 <- tree_data$start
  tbl_mat         <- as.matrix(tree_data[,7:15]) # careful with this
  tree_data$y1    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y2 <- tree_data$end
  tbl_mat         <- as.matrix(tree_data[,7:15]) # careful with this, easy to fuck up
  tree_data$y2    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  return(tree_data)
}

#-------------------------------------------------------------------------------
# Extract matches function
#-------------------------------------------------------------------------------
extract_matches <- function(tree_data, species_data) {

  message("Gathering species matches...")

  trees_unique <- unique(tree_data, by = c("common_name", "dbh_val"))
  unique_common_names <- unique(tree_data[, c("common_name")])

  tree_data[, ("id") := 1:nrow(tree_data)]
  trees_unique[, ("id") := 1:nrow(trees_unique)]

  vec <- unlist(lapply(unique_common_names$common_name, function(x) which.max(string_dist(x, species_data$common_name))))
  unique_common_names$spp_value <- species_data[vec,][["spp_value_assignment"]]
  unique_common_names$common_master <- tolower(species_data[vec,][["common_name"]])
  unique_common_names$scientific_name <- species_data[vec,][["scientific_name"]]
  unique_common_names$common_name <- tolower(unique_common_names$common_name)
  trees_unique$common_name <- tolower(trees_unique$common_name)
  tree_data$common_name <- tolower(tree_data$common_name)
  unique_common_names[, "sim" := string_dist(common_name[1], common_master[1]), by = common_name]
  unique_common_names <- unique_common_names[sim >= 0.90]
  unique_common_names <- unique_common_names[, c("scientific_name", "common_name", "spp_value")]
  tree_data <- tree_data[tree_data$common_name %in% unique_common_names$common_name]
  trees_unique <- trees_unique[trees_unique$common_name %in% unique_common_names$common_name]

  data.table::setkey(unique_common_names, "common_name")
  data.table::setkey(trees_unique, "common_name")
  data.table::setkey(tree_data, "common_name")
  trees_unique <- trees_unique[unique_common_names, allow.cartesian=TRUE]
  tree_data <- tree_data[unique_common_names, allow.cartesian=TRUE]
  tree_data <- unique(tree_data, by = "id") # Why is this needed? Something wrong here...
  output <- list(trees = tree_data, trees_unique = trees_unique)
  return(output)
}

#-------------------------------------------------------------------------------
# Extract benefits function
#-------------------------------------------------------------------------------
extract_benefits <- function(tree_data) {
  tree_data[, benefit_value := ifelse(y1 == y2, y1, eco_interp(x = tree_data$dbh_val, x1 = tree_data$x1, x2 = tree_data$x2, y1 = tree_data$y1, y2 = tree_data$y2))]
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)
  return(tree_data)
}

#-------------------------------------------------------------------------------
# Capitalize first word function
#-------------------------------------------------------------------------------
capitalize <- function(tree_data) {
  var <- paste0(
    toupper(substr(tree_data$common_name, 1, 1)),
    substr(tree_data$common_name, 2, nchar(tree_data$common_name))
  )

  return(var)
}

#-------------------------------------------------------------------------------
# Eco benefits function
#-------------------------------------------------------------------------------

#' Run eco benefits for an entire tree inventory
#'
#' @param data path to csv file containing tree inventory
#' @param species_col the name of the column containing common names of species
#' @param dbh_col the name of the column containing dbh values
#' @param region region code, see \code{species} or \code{benefits}
#' @param print_time Logical TRUE or FALSE for printing the elapsed time
#'
#' @import data.table
#' @export
eco_run_all <- function(data, species_col, dbh_col, region, print_time = NULL) {

  start_time <- Sys.time()

  # Extract and reshape the input data
  tree_data <- extract_data(data, species_col, dbh_col, region)

  # Output is store in a list, assign each list element to an object
  trees <- tree_data$trees
  benefits <- tree_data$benefits
  species <- tree_data$species
  money <- tree_data$money

  # Extract the species matches with a similarity score > 90%
  matches <- extract_matches(tree_data = trees, species_data = species)

  # Output is (again) store as a list, assign each list element to an object
  trees <- matches$trees
  trees_unique <- matches$trees_unique

  # Set keys to join data to benefit data
  data.table::setkey(trees_unique, "spp_value")
  data.table::setkey(benefits, "species_code")
  data.table::setkey(trees, "spp_value")

  # Join the data
  trees_unique <- trees_unique[benefits, allow.cartesian=TRUE]
  trees <- trees[benefits, allow.cartesian=TRUE]

  # Extract x, x1, x2, y1, y2 values for interpolation function
  trees_unique <- extract_parameters(trees_unique)

  # Select the variables we need
  tree_vars <- c("id", "scientific_name", "common_name", "dbh_val", "x1", "x2", "y1", "y2", "benefit", "unit")
  trees_unique <- trees_unique[, .SD, .SDcols = tree_vars]

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
  tree_vars <- c("id", "scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit", "dollars")
  trees_final <- trees_final[, .SD, .SDcols = tree_vars]

  # Capitalize the first word of common name
  trees_final$common_name <- capitalize(trees_final)

  # Rename the 'dbh_val' var to just 'dbh'
  data.table::setnames(trees_final, "dbh_val", "dbh")

  end_time <- Sys.time()
  elapsed_time <- end_time - start_time

  if(isTRUE(print_time)) {print(elapsed_time)}

  return(trees_final)
}
