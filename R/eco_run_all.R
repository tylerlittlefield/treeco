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

# ------------------------------------------------------------------------------
# Data extract function
# ------------------------------------------------------------------------------

extract <- function(data, species_col, dbh_col, region) {
  trees    <- data.table::fread(data)
  benefits <- data.table::as.data.table(treeco::benefits)
  species  <- data.table::as.data.table(treeco::species)
  money    <- data.table::as.data.table(treeco::money)
  money    <- money[money$region_code == region, ]                               # Filter currency dataset by region
  money    <- data.table::melt(money, id.vars = c("region_code", "region_name")) # Melt the dataset to 'tidy' format
  money    <- money[, c("variable", "value")]                                    # Select the variables we need

  data.table::setnames(trees, species_col, "common_name")                        # Rename species column to stay consistent
  data.table::setnames(trees, dbh_col, "dbh_val")                                # Rename dbh column to stay consistent

  trees         <- trees[, .SD, .SDcol = c("common_name", "dbh_val")][trees$dbh_val > 0] # Arrange columns consistently, then extract all records where dbh > 0
  benefits      <- benefits[grepl(region, species_region)]                            # Extract benefits within user defined region
  species       <- species[grepl(region, species_region)]                              # Extract species within user defined region
  trees$dbh_val <- trees$dbh_val * 2.54

  output   <- list(trees = trees,
                   benefits = benefits,
                   species = species,
                   money = money)

  return(output)
}

#-------------------------------------------------------------------------------
# Money extract function
#-------------------------------------------------------------------------------

extract_money <- function(tree_data, money_data) {
  # A bunch of copy/paste (yuck) to grab eco benefit money values so we can
  # multiply the benefit by these values to get $ saved. Figure out a more
  # elegant way of doing this. Looks ugly.
  elec_money <- money_data[grepl("electricity", money_data$variable)][["value"]]
  gas_money  <- money_data[grepl("natural_gas", money_data$variable)][["value"]]
  h20_money  <- money_data[grepl("h20_gal", money_data$variable)][["value"]]
  co2_money  <- money_data[grepl("co2", money_data$variable)][["value"]]
  o3_money   <- money_data[grepl("o3_lb", money_data$variable)][["value"]]
  nox_money  <- money_data[grepl("nox_lb", money_data$variable)][["value"]]
  pm10_money <- money_data[grepl("pm10_lb", money_data$variable)][["value"]]
  sox_money  <- money_data[grepl("sox_lb", money_data$variable)][["value"]]
  voc_money  <- money_data[grepl("voc_lb", money_data$variable)][["value"]]

  # Convert kilograms and cubic meters to lbs and gallons
  tree_data[grepl("lb", unit), "benefit_value" := benefit_value * 2.20462]
  tree_data[grepl("gal", unit), "benefit_value" := benefit_value * 264.172052]

  # Multiply $ values by the benefit value to get the $ saved
  tree_data[grepl("electricity", benefit), "dollars" := benefit_value * elec_money]
  tree_data[grepl("natural gas", benefit), "dollars" := benefit_value * gas_money]
  tree_data[grepl("hydro interception", benefit), "dollars" := benefit_value * h20_money]
  tree_data[grepl("co2 ", benefit), "dollars" := benefit_value * co2_money]
  tree_data[grepl("aq ozone dep", benefit), "dollars" := benefit_value * o3_money]
  tree_data[grepl("aq nox", benefit), "dollars" := benefit_value * nox_money]
  tree_data[grepl("aq pm10", benefit), "dollars" := benefit_value * pm10_money]
  tree_data[grepl("aq sox", benefit), "dollars" := benefit_value * sox_money]
  tree_data[grepl("voc", benefit), "dollars" := benefit_value * voc_money]

  # Because davey takes $ values like -0.54 from natural gas and makes it 0.54?
  tree_data$dollars <- abs(round(tree_data$dollars, 2))
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)
  tree_data <- data.table::as.data.table(tree_data)
}

#-------------------------------------------------------------------------------
# Parameter extract function (for interpolation equation)
#-------------------------------------------------------------------------------

extract_parameters <- function(tree_data) {
  dbh_values <- tree_data[["dbh_val"]]
  dbh_ranges <- c(3.81, 11.43, 22.86, 38.10, 53.34, 68.58, 83.82, 99.06, 114.30)

  z <- abs(outer(dbh_values, dbh_ranges, `-`))

  tree_data$a <- apply(z, 1, which.min)
  z[z==apply(z, 1, min)] <- Inf
  tree_data$b <- apply(z, 1, which.min)
  tree_data$start <- pmin(tree_data$a, tree_data$b)
  tree_data$end <- pmax(tree_data$a, tree_data$b)
  tree_data$x1 <- dbh_ranges[tree_data$start]
  tree_data$x2 <- dbh_ranges[tree_data$end]

  # Grab the benefit values given the start/end vectors
  # https://stackoverflow.com/questions/20617371/
  tbl_rows <- seq_along(tree_data$id)
  tbl_indicies_y1 <- tree_data$start
  tbl_mat <- as.matrix(tree_data[,7:15]) # careful with this
  tree_data$y1 <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows <- seq_along(tree_data$id)
  tbl_indicies_y2 <- tree_data$end
  tbl_mat <- as.matrix(tree_data[,7:15]) # careful with this, easy to fuck up
  tree_data$y2 <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  return(tree_data)
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
#'
#' @import data.table
#' @export
eco_run_all <- function(data, species_col, dbh_col, region) {
  start_time <- Sys.time()

  message("Importing data...")

  tree_data <- extract(data, species_col, dbh_col, region)
  trees     <- tree_data$trees
  benefits  <- tree_data$benefits
  species   <- tree_data$species
  money     <- tree_data$money

  # Extract unique records by common_name/dbh_val pairs, we want to run the
  # benefits on the minimum number of records possible and then join to the non
  # unique (original) user data once everythings done. No need to do everything
  # on duplicates when we can just join at the end.
  trees_unique <- unique(trees, by = c("common_name", "dbh_val"))

  unique_common_names <- unique(trees[, c("common_name")]) # Extract unique common names from user data (should we just grab from trees_unique?)

  trees[, ("id") := 1:nrow(trees)]               # Add id var to user data
  trees_unique[, ("id") := 1:nrow(trees_unique)] # Add id var to unique data (is this needed?)

  message("Guessing species codes...")

  # Extract indices of the species master list for the most similar matches
  vec <- unlist(lapply(unique_common_names$common_name, function(x) which.max(string_dist(x, species$common_name))))

  # Store the SppValueAssignment to the smaller/unique datatable (not trees_unique)
  unique_common_names$spp_value <- species[vec,][["spp_value_assignment"]]

  # Store the common_name/scientific_name to the smaller/unique datatable (not trees_unique)
  unique_common_names$species_master <- species[vec,][["common_name"]]
  unique_common_names$scientific_name <- species[vec,][["scientific_name"]]

  # Convert the common names from users data and the species master list to lower
  # case for better similarity scores
  unique_common_names$common_name <- tolower(unique_common_names$common_name)
  unique_common_names$species_master <- tolower(unique_common_names$species)

  # Convert entire inventory to lower case for the join
  trees_unique$common_name <- tolower(trees_unique$common_name)
  trees$common_name <- tolower(trees$common_name)

  # Now that we have paired up the master list to the unique common names from
  # the users inventory data (keeping in mind that some of these pairs have a
  # really low score). We run the string_dist function to compare the pairs and
  # save the score as 'sim'
  unique_common_names[, "sim" := string_dist(common_name[1], species_master[1]), by = common_name]

  # Remove any records with a similarity score below 90%
  unique_common_names <- unique_common_names[sim >= 0.90]

  # Select the variables we need
  unique_common_names <- unique_common_names[, c("scientific_name", "common_name", "spp_value")]

  trees <- trees[trees$common_name %in% unique_common_names$common_name]
  trees_unique <- trees_unique[trees_unique$common_name %in% unique_common_names$common_name]


  # Set the keys to prepare for the join
  data.table::setkey(unique_common_names, "common_name")
  data.table::setkey(trees_unique, "common_name")
  data.table::setkey(trees, "common_name")

  # Join the table back to the entire inventory
  trees_unique <- trees_unique[unique_common_names, allow.cartesian=TRUE]
  trees <- trees[unique_common_names, allow.cartesian=TRUE]
  trees <- unique(trees, by = "id") # Why is this needed? Something wrong here...

  message("Linking benefits to data...")

  data.table::setkey(trees_unique, "spp_value")
  data.table::setkey(benefits, "species_code")
  data.table::setkey(trees, "spp_value")

  trees_unique <- trees_unique[benefits, allow.cartesian=TRUE]
  trees <- trees[benefits, allow.cartesian=TRUE]

  message("Calculating eco benefits...")

  trees_unique <- extract_parameters(trees_unique)

  tree_vars <- c("id", "scientific_name", "common_name", "dbh_val", "x1", "x2", "y1", "y2", "benefit", "unit")
  trees_unique <- trees_unique[, .SD, .SDcols = tree_vars]

  trees_unique[, benefit_value := ifelse(y1 == y2, y1, eco_interp(x = trees_unique$dbh_val, x1 = trees_unique$x1, x2 = trees_unique$x2, y1 = trees_unique$y1, y2 = trees_unique$y2))]
  trees_unique$benefit_value <- round(trees_unique$benefit_value, 4)

  message("Calculating $ benefits...")

  tree_vars <- c("id", "common_name", "dbh_val", "benefit")
  trees <- trees[, .SD, .SDcols = tree_vars]

  # Figure out where the NA's come from...
  trees_unique <- stats::na.omit(trees_unique)
  trees <- stats::na.omit(trees)

  trees_unique <- extract_money(trees_unique, money)

  data.table::setkey(trees, NULL)
  data.table::setkey(trees_unique, NULL)
  data.table::setkey(trees, "common_name", "dbh_val", "benefit")
  data.table::setkey(trees_unique, "common_name", "dbh_val", "benefit")

  trees_final <- trees[trees_unique, allow.cartesian=TRUE]
  trees_final$dbh_val <- round(trees_final$dbh_val * 0.393701, 2)

  data.table::setkey(trees_final, NULL)
  data.table::setkey(trees_final, "id")

  tree_vars <- c("id", "scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit", "dollars")
  trees_final <- trees_final[, .SD, .SDcols = tree_vars]

  # Capitalize first word in common name
  trees_final$common_name <- paste0(toupper(substr(trees_final$common_name, 1, 1)), substr(trees_final$common_name, 2, nchar(trees_final$common_name)))
  data.table::setnames(trees_final, "dbh_val", "dbh")

  message("Eco benefits complete!")

  end_time <- Sys.time()
  elapsed_time <- end_time - start_time
  print(elapsed_time)

  return(trees_final)
}
