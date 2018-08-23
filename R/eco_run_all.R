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

#-------------------------------------------------------------------------------
# Eco benefits function
#-------------------------------------------------------------------------------

#' Run eco benefits for an entire tree inventory
#'
#' @param data path to csv file containing tree inventory
#' @param species_col the name of the column containing common names of species
#' @param dbh_col the name of the column containing dbh values
#' @param region region code, see \code{species_data} or \code{eco_data}
#'
#' @import data.table
#' @export
eco_run_all <- function(data, species_col, dbh_col, region) {

  begin_time <- Sys.time()

  # Message: importing data
  message("Importing: ", basename(data), "...")

  # Import data
  eco_tbl     <- data.table::as.data.table(treeco::eco_data)
  species_tbl <- data.table::as.data.table(treeco::species_data)
  trees_tbl   <- data.table::fread(data, stringsAsFactors = FALSE)
  df_money    <- as.data.table(treeco::currency_data)
  df_money    <- df_money[df_money$region_code == region]                              # Filter currency dataset by region
  df_money    <- data.table::melt(df_money, id.vars = c("region_code", "region_name")) # Melt the dataset to 'tidy' format
  df_money    <- df_money[, c("variable", "value")]                                    # Select the variables we need

  # Message: data imported
  message(basename(data), " imported.")

  # Message: reconfiguring data
  message("Reconfiguring data...")

  # Reconfigure data
  trees_tbl <- trees_tbl[, c(species_col, dbh_col), with = FALSE]       # Grab variables we need
  trees_tbl[, ("id") := 1:nrow(trees_tbl)]                              # Create 'id' variable
  trees_tbl <- trees_tbl[, c("id", species_col, dbh_col), with = FALSE] # Arrange columns for consistency
  data.table::setnames(trees_tbl, species_col, "common_name")           # Set name of species variable for consistency
  data.table::setnames(trees_tbl, dbh_col, "dbh_val")                   # Set name of dbh variable for consistency
  trees_tbl <- trees_tbl[trees_tbl$dbh_val > 0]                         # Data must have dbh > 0

  # Convert dbh values to centimeters. Here, we make the assumption that it's
  # always going to be recorded in inches. Will one day need an option to either
  # avoid or allow this step depending on if the users data is centimeters or
  # inches.
  trees_tbl$dbh_val <- trees_tbl$dbh_val * 2.54

  # Message: data reconfigured
  message("Data reconfigured.")

  # Subset eco benfits and master species list data by region
  eco_tbl     <- eco_tbl[eco_tbl$species_region == region]
  species_tbl <- species_tbl[species_tbl$species_region == region, ]

  # Grab variables needed
  species_tbl <- species_tbl[, c("scientific_name", "common_name", "species_code", "spp_value_assignment")]

  # Message: guessing species codes
  message("Guessing species codes...")

  # Grab the unique common names from the users inventory data. We don't want
  # to calculate the similarity of duplicates records. Instead, we will calculate
  # the similarity for all unique common names to the species master list and
  # then join them to the users data.
  unique_common_names <- unique(trees_tbl[, c("common_name")])

  # Grab indices of the species master list for the most similar matches
  vec <- unlist(lapply(unique_common_names$common_name, function(x) which.max(string_dist(x, species_tbl$common_name))))

  # Store the species code to the smaller/unique datatable.
  unique_common_names$code <- species_tbl[vec,][["species_code"]]

  # Grab the common names
  unique_common_names$species_master <- species_tbl[vec,][["common_name"]]

  # Conver the common names from users data and the species master list to lower
  # case for better similarity scores
  unique_common_names$common_name <- tolower(unique_common_names$common_name)
  unique_common_names$species_master <- tolower(unique_common_names$species)

  # Convert entire inventory to lower case for the join
  trees_tbl$common_name <- tolower(trees_tbl$common_name)

  # Now that we have paired up the master list to the unique common names from
  # the users inventory data (keeping in mind that some of these pairs have a
  # really low score). We run the string_dist function to compare the pairs and
  # save the score as 'sim'
  unique_common_names[, "sim" := string_dist(common_name[1], species_master[1]), by = common_name]

  # Remove any records with a similarity score below 90%
  unique_common_names <- unique_common_names[sim >= 0.90]

  # Select the variables we need
  unique_common_names <- unique_common_names[, c("common_name", "code")]

  # Set the keys to prepare for the join
  setkey(unique_common_names, "common_name")
  setkey(trees_tbl, "common_name")

  # Join the table back to the entire inventory
  trees_tbl <- trees_tbl[unique_common_names, allow.cartesian=TRUE]

  # Rename 'code' var to 'species_code'. Should probably just change this above
  # to avoid this unnessary line.
  data.table::setnames(trees_tbl, "code", "species_code")

  # Message: species codes gathered
  message("Species codes gathered.")

  # Set keys for users inventory data and the master species list
  data.table::setkey(trees_tbl, "species_code")
  data.table::setkey(species_tbl, "species_code")

  # Message: linking species code to inventory data
  message("Linking species codes to the data...")

  # Perform join to grab species codes. This join among others and the guess/grab
  # are some of the chunks that make this so slow. Also, why not just grab the
  # species value assignments since that's all we need? Or maybe this does that
  # see lines 121-122, can't remember...
  trees_tbl <- trees_tbl[species_tbl, allow.cartesian = TRUE]

  trees_tbl[, "similarity" := string_dist(common_name[1], i.common_name[1]), by = "id"]
  low_match_scores <- length(unique(trees_tbl[trees_tbl$similarity < 0.8][["id"]]))
  message("Note: Cannot guess ", low_match_scores, " trees, similarity score below 90%")
  trees_tbl <- trees_tbl[similarity >= 0.8]

  # Message: species codes linked
  message("Species codes linked.")

  # Remove previously set keys
  data.table::setkey(trees_tbl, NULL)
  data.table::setkey(species_tbl, NULL)

  # Don't need to grab unique ids anymore? Leaving this comment here because
  # before (in old scripts) grabbing unique id's was required and the absense
  # of this line made everything weird.

  # Grab unique value assignments from users data, then grab the records from
  # eco benefits data that contain these value assignments.
  unique_value_assignments <- unique(trees_tbl, by = "spp_value_assignment")[["spp_value_assignment"]]
  eco_tbl                  <- eco_tbl[eco_tbl$species_code %in% unique_value_assignments]

  # Grab variables needed, remove the junk
  trees_tbl <- trees_tbl[, c("id", "scientific_name", "common_name", "dbh_val", "spp_value_assignment")]
  eco_tbl   <- eco_tbl[, c("species_code", "dbh_range", "benefit_value", "benefit", "unit")]

  # Set keys of the users data and the eco benefits data. Here, I believe the
  # 'species_code' variable from the eco benefits table is actually the
  # 'spp_value_assignment' so may want to rename this to make things easier.
  data.table::setkey(trees_tbl, "spp_value_assignment")
  data.table::setkey(eco_tbl, "species_code")

  # Message: calculating benefits for n trees.
  # This always shows n + 1 trees so I things I'm counting the rows incorrectly.
  message("Calculating benefits for ", length(unique(trees_tbl$id)), " trees...")

  # Join users data to the eco benefits data
  trees_tbl <- trees_tbl[eco_tbl, nomatch=0L, allow.cartesian=TRUE]

  # Remove keys
  data.table::setkey(trees_tbl, NULL)
  data.table::setkey(eco_tbl, NULL)

  # Calculate absolute value of dbh - dbh_range. The assumption here is that the
  # lowest two dbh_diff values will represent the range that the trees dbh falls
  # under.
  trees_tbl[, ("dbh_diff") := abs(trees_tbl$dbh_val - trees_tbl$dbh_range)]

  # Sort dbh_diff in ascending order
  data.table::setkey(trees_tbl, "dbh_diff")
  trees_tbl <- unique(trees_tbl)

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

  # Remove any instances of NA, should probably create a message that reports
  # the number of records being removed.
  trees_tbl <- stats::na.omit(trees_tbl)

  # Grab unique records by 'id' and 'benefit'. Don't need all the additional
  # duplicates since 'x1', 'x2', etc. have been created.
  trees_tbl <- unique(trees_tbl, by = c("id", "benefit"))

  # If 'y1' == 'y2' no need to interpolate benefits over a horizontal. However,
  # if they don't equal, interpolate the benefit value.
  trees_tbl[, benefit_value := ifelse(y1 == y2, y1, eco_interp(x = trees_tbl$dbh_val, x1 = trees_tbl$x1, x2 = trees_tbl$x2, y1 = trees_tbl$y1, y2 = trees_tbl$y2))]

  # Grab data we need
  trees_tbl <- trees_tbl[, c("id", "scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit")]

  # Remove the remaining duplicates (why are there remaining dupes?)
  trees_tbl <- unique(trees_tbl, by = c("id", "benefit"))

  # Round the benefit value to the 4th decimal
  trees_tbl[, "benefit_value" := round(trees_tbl$benefit_value, 4)]

  # Convert dbh values from centimeters back to inches and then round to the
  # 2nd decimal.
  trees_tbl$dbh_val <- round(trees_tbl$dbh_val * 0.393701, 2)

  # Rename dbh column. Perhaps avoid this step by setting name to dbh at the
  # beginning?
  data.table::setnames(trees_tbl, "dbh_val", "dbh")

  # Remove any NAs (again). Probably report the number of records being omitted
  # for debugging purposes.
  trees_tbl <- trees_tbl[!is.na(trees_tbl$common_name), ]

  # Set 'id' as key, thereby sorting the datatable by id in ascending order
  data.table::setkey(trees_tbl, "id")

  # A bunch of copy/paster (yuck) to grab eco benefit money values so we can
  # multiply the benefit by these values to get $ saved. Figure out a more
  # elegant way of doing this. Looks ugly.
  elec_money <- df_money[grepl("electricity", df_money$variable)][["value"]]
  gas_money  <- df_money[grepl("natural_gas", df_money$variable)][["value"]]
  h20_money  <- df_money[grepl("h20_gal", df_money$variable)][["value"]]
  co2_money  <- df_money[grepl("co2", df_money$variable)][["value"]]
  o3_money   <- df_money[grepl("o3_lb", df_money$variable)][["value"]]
  nox_money  <- df_money[grepl("nox_lb", df_money$variable)][["value"]]
  pm10_money <- df_money[grepl("pm10_lb", df_money$variable)][["value"]]
  sox_money  <- df_money[grepl("sox_lb", df_money$variable)][["value"]]
  voc_money  <- df_money[grepl("voc_lb", df_money$variable)][["value"]]

  # Convert kilograms and cubic meters to lbs and gallons
  trees_tbl[grepl("kgs", unit), "benefit_value" := benefit_value * 2.20462]
  trees_tbl[grepl("kgs", unit), "unit" := "lbs"]
  trees_tbl[grepl("[m^3]", unit), "benefit_value" := benefit_value * 264.172052]
  trees_tbl[grepl("[m^3]", unit), "unit" := "gals"]

  # Multiply $ values by the benefit value to get the $ saved
  trees_tbl[grepl("electricity", benefit), "dollars" := benefit_value * elec_money]
  trees_tbl[grepl("natural gas", benefit), "dollars" := benefit_value * gas_money]
  trees_tbl[grepl("hydro interception", benefit), "dollars" := benefit_value * h20_money]
  trees_tbl[grepl("co2 ", benefit), "dollars" := benefit_value * co2_money]
  trees_tbl[grepl("aq ozone dep", benefit), "dollars" := benefit_value * o3_money]
  trees_tbl[grepl("aq nox", benefit), "dollars" := benefit_value * nox_money]
  trees_tbl[grepl("aq pm10", benefit), "dollars" := benefit_value * pm10_money]
  trees_tbl[grepl("aq sox", benefit), "dollars" := benefit_value * sox_money]
  trees_tbl[grepl("voc", benefit), "dollars" := benefit_value * voc_money]

  # Because davey takes $ values like -0.54 from natural gas and makes it 0.54?
  trees_tbl$dollars <- abs(round(trees_tbl$dollars, 2))
  trees_tbl$benefit_value <- round(trees_tbl$benefit_value, 4)

  # Message: complete
  message("Complete.")

  # Grab end time, subtract it from begin time and print the time it took to
  # run the benefits.
  end_time <- Sys.time()
  elapsed_time <- end_time - begin_time
  print(elapsed_time)

  # # Return the users data
  return(trees_tbl)

}

