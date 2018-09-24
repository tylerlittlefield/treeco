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
extract_data <- function(data, common_col, botanical_col, dbh_col, region) {

  ifelse(
    test = is.object(data),
    yes = trees <- data.table::as.data.table(data),
    no = trees <- data.table::fread(data)
    )

  # trees    <- data.table::fread(data, select = c(common_col, botanical_col, dbh_col))
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

  trees         <- trees[, .SD, .SDcol = c("common_name", "botanical_name", "dbh_val")][trees$dbh_val > 0]
  benefits      <- benefits[grepl(region, species_region)]
  species       <- species[grepl(region, species_region)]
  trees$dbh_val <- trees$dbh_val * 2.54

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
  tbl_mat         <- as.matrix(tree_data[,6:14]) # careful with this
  tree_data$y1    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y2 <- tree_data$end
  tbl_mat         <- as.matrix(tree_data[,6:14]) # careful with this, easy to fuck up
  tree_data$y2    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  return(tree_data)
}

#-------------------------------------------------------------------------------
# Extract matches function
#-------------------------------------------------------------------------------
extract_matches <- function(tree_data, species_data) {

  message("Gathering species matches...")

  trees <- tree_data
  species <- species_data

  '%nin%' <- Negate('%in%')

  # Extract unique common names, convert to lower case, remove punctuation
  unique_commons <- unique(trees[, "common_name"])
  unique_commons <- stats::na.omit(unique_commons)
  unique_commons$common_name <- tolower(unique_commons$common_name)
  unique_commons$common_name <- gsub('[[:punct:]]+', '', unique_commons$common_name)
  unique_commons$common_name <- trimws(unique_commons$common_name, "both") # Save for end?

  # Extract unique botanical names, conver to lower case, remove punctuation
  unique_botanicals <- unique(trees[, "botanical_name"])
  unique_botanicals <- stats::na.omit(unique_botanicals)
  unique_botanicals$botanical_name <- tolower(unique_botanicals$botanical_name)
  unique_botanicals$botanical_name <- gsub('[[:punct:]]+', '', unique_botanicals$botanical_name)
  unique_botanicals$botanical_name <- trimws(unique_botanicals$botanical_name, "both") # Save for end?

  species$common_name_m <- tolower(species$common_name)
  species$common_name_m <- gsub('[[:punct:]]+', '', species$common_name_m)
  species$common_name_m <- trimws(species$common_name_m, "both") # Save for end?

  species$botanical_name_m <- tolower(species$scientific_name)
  species$botanical_name_m <- gsub('[[:punct:]]+', '', species$botanical_name_m)
  species$botanical_name_m <- trimws(species$botanical_name_m, "both") # Save for end?

  vec <- unlist(lapply(unique_commons$common_name, function(x) which.max(string_dist(x, species$common_name_m))))

  unique_commons$common_name_m <- species[vec,][["common_name_m"]]
  unique_commons$botanical_name_m <- species[vec,][["botanical_name_m"]]
  unique_commons$spp_value_assignment <- species[vec,][["spp_value_assignment"]]
  unique_commons[, "sim" := string_dist(common_name[1], common_name_m[1]), by = common_name]
  unique_commons_1 <- unique_commons[sim >= 0.80]

  species <- species[species$common_name_m %nin% unique_commons_1$common_name_m, ]

  vec <- unlist(lapply(unique_botanicals$botanical_name, function(x) which.max(string_dist(x, species$botanical_name_m))))

  unique_botanicals$botanical_name_m <- species[vec,][["botanical_name_m"]]
  unique_botanicals$common_name_m <- species[vec,][["common_name_m"]]
  unique_botanicals$spp_value_assignment <- species[vec,][["spp_value_assignment"]]
  unique_botanicals[, "sim" := string_dist(botanical_name[1], botanical_name_m[1]), by = botanical_name]
  unique_botanicals_1 <- unique_botanicals[sim >= 0.80]

  trees$common_name <- tolower(trees$common_name)
  trees$common_name <- gsub('[[:punct:]]+', '', trees$common_name)
  trees$common_name <- trimws(trees$common_name, "both") # Save for end?

  trees$botanical_name <- tolower(trees$botanical_name)
  trees$botanical_name <- gsub('[[:punct:]]+', '', trees$botanical_name)
  trees$botanical_name <- trimws(trees$botanical_name, "both") # Save for end?

  trees_common <- trees[unique_commons_1, on = "common_name"]
  trees_botanical <- trees[unique_botanicals_1, on = "botanical_name"]

  trees <- rbind(trees_common, trees_botanical)

  tree_vars <- c("common_name_m", "botanical_name_m", "dbh_val", "spp_value_assignment")
  trees <- trees[, .SD, .SDcols = tree_vars]
  trees <- trees[, ("id") := 1:nrow(trees)]

  tree_vars <- c("common_name_m", "botanical_name_m", "dbh_val", "spp_value_assignment")
  trees_unique <- trees[, .SD, .SDcols = tree_vars]
  trees_unique <- unique(trees_unique, by = c("common_name_m", "dbh_val"))

  data.table::setnames(trees, "common_name_m", "common_name")
  data.table::setnames(trees, "botanical_name_m", "botanical_name")
  data.table::setnames(trees_unique, "common_name_m", "common_name")
  data.table::setnames(trees_unique, "botanical_name_m", "botanical_name")

  output <- list(trees = trees, trees_unique = trees_unique)
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
capitalize <- function(tree_data, var) {
  var <- paste0(
    toupper(substr(tree_data[[var]], 1, 1)),
    substr(tree_data[[var]], 2, nchar(tree_data[[var]]))
  )

  return(var)
}

#-------------------------------------------------------------------------------
# Eco benefits function
#-------------------------------------------------------------------------------

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
  trees_final$common_name <- capitalize(trees_final, "common_name")
  trees_final$botanical_name <- capitalize(trees_final, "botanical_name")

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
