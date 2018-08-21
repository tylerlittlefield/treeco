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

  # Create a vector which stores all unique common names in users tree inventory
  # unique_common_names <- unique(trees_tbl, by = "common_name")[["common_name"]]

  # Filter the master species list to include only the records that include
  # common names from users inventory. On second thought, why is the 'guess and
  # grab species codes' lines needed? The common names from both the master list
  # and the users inventory should be consistent as a result from the filter?
  # species_tbl <- species_tbl[species_tbl$common_name %in% unique_common_names]

  # Subset eco benfits and master species list data by region
  eco_tbl     <- eco_tbl[eco_tbl$species_region == region]
  species_tbl <- species_tbl[species_tbl$species_region == region, ]

  # Grab variables needed
  species_tbl <- species_tbl[, c("scientific_name", "common_name", "species_code", "spp_value_assignment")]

  # Message: guessing species codes
  message("Guessing species codes...")

  # Guess and grab species_codes
  # Unsure if this is needed. See comments near lines 72-75. Update, lines 72-75
  # weren't needed and were actually creating incorrect values.
  vector <- unlist(lapply(trees_tbl$common_name, function(x) {which.max(string_dist(x, species_tbl$common_name))}))
  trees_tbl$species_code <- species_tbl$species_code[vector]

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
  message("Note: Cannot guess ", low_match_scores, " trees, similarity score below 80%")
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

  # If 'x1' == 'x2' no need to interpolate benefits over a horizontal. However,
  # if they don't equal, interpolate the benefit value.
  trees_tbl[, benefit_value := ifelse(x1 == x2, y1, eco_interp(x = trees_tbl$dbh_val, x1 = trees_tbl$x1, x2 = trees_tbl$x2, y1 = trees_tbl$y1, y2 = trees_tbl$y2))]

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

  # Convert kilograms and cubic meters to lbs and gallons. Not sure if the
  # `==TRUE` is needed.
  trees_tbl[grepl("kgs", unit)==TRUE, "benefit_value" := benefit_value * 2.20462]
  trees_tbl[grepl("kgs", unit)==TRUE, "unit" := "lbs"]
  trees_tbl[grepl("[m^3]", unit)==TRUE, "benefit_value" := benefit_value * 264.172052]
  trees_tbl[grepl("[m^3]", unit)==TRUE, "unit" := "gals"]

  # Multiply $ values by the benefit value to get the $ saved
  trees_tbl[grepl("electricity", benefit)==TRUE, "dollars" := benefit_value * elec_money]
  trees_tbl[grepl("natural gas", benefit)==TRUE, "dollars" := benefit_value * gas_money]
  trees_tbl[grepl("hydro interception", benefit)==TRUE, "dollars" := benefit_value * h20_money]
  trees_tbl[grepl("co2 ", benefit)==TRUE, "dollars" := benefit_value * co2_money]
  trees_tbl[grepl("aq ozone dep", benefit)==TRUE, "dollars" := benefit_value * o3_money]
  trees_tbl[grepl("aq nox", benefit)==TRUE, "dollars" := benefit_value * nox_money]
  trees_tbl[grepl("aq pm10", benefit)==TRUE, "dollars" := benefit_value * pm10_money]
  trees_tbl[grepl("aq sox", benefit)==TRUE, "dollars" := benefit_value * sox_money]
  trees_tbl[grepl("voc", benefit)==TRUE, "dollars" := benefit_value * voc_money]

  # Because davey takes values like -0.54 from natural gas and makes it 0.54?
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

