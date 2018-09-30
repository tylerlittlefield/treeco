#' Eco benefits calculator
#'
#' @description Run the eco benefits for a single tree. This function acts like
#' a benefits calculator in that you give a common name and it calculates the
#' benefits. Similar to Davey Tree's benefits calculator.
#'
#' @param common the common name of the tree
#' @param dbh the dbh value in inches
#' @param region region code, see \code{money} dataset for region codes
#'
#' @examples
#' eco_run("common fig", 20, "InlEmpCLM")
#' eco_run("red maple", 15, "PacfNWLOG")
#'
#' @import data.table
#' @export
eco_run <- function(common, dbh, region) {

  species_guess <- guess_common(common, region)
  species_val <- species_guess$spp_value_assignment
  species_common_guess <- species_guess$common_name

  tree     <- data.table::data.table(common_name = species_common_guess,
                                     dbh_val = dbh,
                                     region = region,
                                     stringsAsFactors = FALSE)
  benefits <- data.table::as.data.table(treeco::benefits)
  species  <- data.table::as.data.table(treeco::species)
  money    <- data.table::as.data.table(treeco::money)
  money    <- money[money$region_code == region, ]                               # Filter currency dataset by region
  money    <- data.table::melt(money, id.vars = c("region_code", "region_name")) # Melt the dataset to 'tidy' format
  money    <- money[, c("variable", "value")]                                    # Select the variables we need

  benefits <- benefits[grepl(region, species_region)]                            # Extract benefits within user defined region
  species <- species[grepl(region, species_region)]                              # Extract species within user defined region

  tree$dbh_val <- tree$dbh_val * 2.54

  tree$spp_value <- species_val

  benefits <- benefits[grepl(species_val, species_code)]

  data.table::setkey(tree, "spp_value")
  data.table::setkey(benefits, "species_code")

  tree <- tree[benefits, allow.cartesian=TRUE]

  dbh_values <- tree[["dbh_val"]]
  dbh_ranges <- c(3.81, 11.43, 22.86, 38.10, 53.34, 68.58, 83.82, 99.06, 114.30)

  z <- abs(outer(dbh_values, dbh_ranges, `-`))

  # A function that returns the position of n-th largest
  # https://stackoverflow.com/questions/10296866/
  tree$a <- apply(z, 1, which.min)
  z[z==apply(z, 1, min)] <- Inf
  tree$b <- apply(z, 1, which.min)
  tree$start <- pmin(tree$a, tree$b)
  tree$end <- pmax(tree$a, tree$b)
  tree$x1 <- dbh_ranges[tree$start]
  tree$x2 <- dbh_ranges[tree$end]

  # Grab the benefit values given the start/end vectors
  # https://stackoverflow.com/questions/20617371/
  tbl_rows <- seq_along(tree$id)
  tbl_indicies_y1 <- tree$start
  tbl_mat <- as.matrix(tree[,6:14]) # careful with this
  tree$y1 <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows <- seq_along(tree$id)
  tbl_indicies_y2 <- tree$end
  tbl_mat <- as.matrix(tree[,6:14]) # careful with this, easy to fuck up
  tree$y2 <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  tree[, benefit_value := ifelse(y1 == y2, y1, eco_interp(x = tree$dbh_val, x1 = tree$x1, x2 = tree$x2, y1 = tree$y1, y2 = tree$y2))]
  tree$benefit_value <- round(tree$benefit_value, 4)

  # A bunch of copy/paste (yuck) to grab eco benefit money values so we can
  # multiply the benefit by these values to get $ saved. Figure out a more
  # elegant way of doing this. Looks ugly.
  elec_money <- money[grepl("electricity", money$variable)][["value"]]
  gas_money  <- money[grepl("natural_gas", money$variable)][["value"]]
  h20_money  <- money[grepl("h20_gal", money$variable)][["value"]]
  co2_money  <- money[grepl("co2", money$variable)][["value"]]
  o3_money   <- money[grepl("o3_lb", money$variable)][["value"]]
  nox_money  <- money[grepl("nox_lb", money$variable)][["value"]]
  pm10_money <- money[grepl("pm10_lb", money$variable)][["value"]]
  sox_money  <- money[grepl("sox_lb", money$variable)][["value"]]
  voc_money  <- money[grepl("voc_lb", money$variable)][["value"]]

  # Convert kilograms and cubic meters to lbs and gallons
  tree[grepl("lb", unit), "benefit_value" := benefit_value * 2.20462]
  tree[grepl("gal", unit), "benefit_value" := benefit_value * 264.172052]

  # Multiply $ values by the benefit value to get the $ saved
  tree[grepl("electricity", benefit), "dollars" := benefit_value * elec_money]
  tree[grepl("natural gas", benefit), "dollars" := benefit_value * gas_money]
  tree[grepl("hydro interception", benefit), "dollars" := benefit_value * h20_money]
  tree[grepl("co2 ", benefit), "dollars" := benefit_value * co2_money]
  tree[grepl("aq ozone dep", benefit), "dollars" := benefit_value * o3_money]
  tree[grepl("aq nox", benefit), "dollars" := benefit_value * nox_money]
  tree[grepl("aq pm10", benefit), "dollars" := benefit_value * pm10_money]
  tree[grepl("aq sox", benefit), "dollars" := benefit_value * sox_money]
  tree[grepl("voc", benefit), "dollars" := benefit_value * voc_money]

  # Because davey takes $ values like -0.54 from natural gas and makes it 0.54?
  tree$dollars <- abs(round(tree$dollars, 2))
  tree$benefit_value <- round(tree$benefit_value, 4)

  data.table::setkey(tree, NULL)

  tree$dbh_val <- round(tree$dbh_val * 0.393701, 2)

  tree_vars <- c("common_name", "dbh_val", "benefit_value", "benefit", "unit", "dollars")
  tree <- tree[, .SD, .SDcols = tree_vars]
  data.table::setnames(tree, "dbh_val", "dbh")
  tree$common_name <- paste0(toupper(substr(tree$common_name, 1, 1)), substr(tree$common_name, 2, nchar(tree$common_name)))

  return(tree)

}

