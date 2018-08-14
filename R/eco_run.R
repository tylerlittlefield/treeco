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
# Function for guessing the common name
#-------------------------------------------------------------------------------
eco_guess <- function(common, region) {

  # Make common input lower case
  common <- tolower(common)

  # Load species data
  df <- treeco::species_data

  # Grab variables we need
  df <- df[c("species_code", "common_name", "species_region")]

  # Filter by region
  df <- df[df$species_region == region, ]

  # Remove duplicates
  df <- unique(df)

  # Make common_name variable lower case
  df$common_name <- tolower(df$common_name)

  # Compute similarity score
  df$similarity_score <- string_dist(df$common_name, common)

  # Extract max match score (what about cases where two scores == max score??)
  df <- df[df$similarity_score == max(df$similarity_score), ]

  # If common name given by user matches common name found, no message
  # else, print message of which species will be used
  if (df$common_name[1] == common) {
    invisible(df[["species_code"]][1])
  } else {
    message("Entered '", common, "'. Using closest match: '", df$common_name[1], "'.", sep = "")
    invisible(df[["species_code"]][1])
  }
}

#-------------------------------------------------------------------------------
# Function for calculating benefits
#-------------------------------------------------------------------------------

#' Run eco benefits for a tree
#'
#' @param species species common name, see \code{species_data}
#' @param dbh dbh value, any positive number
#' @param region region code, see \code{species_data} or \code{eco_data}
#'
#' @export
eco_run <- function(species, dbh, region) {

  # Debugging procedure, make sure datatypes are sound
  ifelse(is.character(species), species, stop("Species value must be character type."))
  ifelse(is.numeric(dbh), dbh, stop("DBH value must be numeric type."))
  ifelse(is.character(region), region, stop("Region value must be character type."))
  ifelse(dbh > 0, dbh, stop("DBH value must be > 0."))

  species <- eco_guess(species, region)

  # Construct dataframe
  tree_tbl <- data.frame(
    species_code = species,
    dbh_val = dbh * 2.54 # Need argument for units so we can convert inches to centimeters
  )

  # Subset data by region
  eco_tbl <- eco_data[eco_data$species_region == region, ]
  species_tbl <- species_data[species_data$species_region == region, ]

  # Select variables we need
  species_tbl <- species_tbl[1:5]

  # Join species_tbl to tree_tbl example data
  tree_tbl <- merge(x = species_tbl,
                    y = tree_tbl,
                    by.x = "species_code",
                    by.y = "species_code",
                    all.x = FALSE)

  # Remove duplicates, this wasn't required before, figure this out
  # tree_tbl <- subset(tree_tbl, !duplicated(tree_tbl$species_code))
  tree_tbl <- tree_tbl[!duplicated(tree_tbl[, "species_code"]),]

  # Join tree_tbl to eco_tbl
  tree_tbl <- merge(x = tree_tbl,
                    y = eco_tbl,
                    by.x = "spp_value_assignment",
                    by.y = "species_code",
                    all.x = TRUE)

  # Select variables we need
  tree_tbl <- tree_tbl[c("scientific_name", "common_name", "dbh_val", "dbh_range", "benefit_value", "benefit", "unit")]

  # Calculate absolute value of dbh - dbh_range
  tree_tbl$dbh_diff <- abs(tree_tbl$dbh_val - tree_tbl$dbh_range)

  # Order dbh_diff in ascending order
  tree_tbl <- tree_tbl[order(tree_tbl$dbh_diff, tree_tbl$benefit, decreasing = FALSE),]

  # Grab the first two records grouped by benefit, this will be the lowest dbh_diff values
  tree_tbl <- tree_tbl[stats::ave(tree_tbl$dbh_diff, tree_tbl$benefit, FUN = seq_along) <= 2, ]

  # Order dbh_range in ascending order
  tree_tbl <- tree_tbl[order(tree_tbl$dbh_range, tree_tbl$benefit, decreasing = FALSE),]

  # Set up variables for interpolation function
  tree_tbl$x1 <- min(tree_tbl$dbh_range)
  tree_tbl$x2 <- max(tree_tbl$dbh_range)
  tree_tbl$y1 <- tree_tbl[stats::ave(tree_tbl$benefit_value, tree_tbl$benefit, FUN = seq_along) == 1, ][["benefit_value"]]
  tree_tbl$y2 <- tree_tbl[stats::ave(tree_tbl$benefit_value, tree_tbl$benefit, FUN = seq_along) == 2, ][["benefit_value"]]

  # Remove duplicate benefits
  # tree_tbl <- subset(tree_tbl, !duplicated(tree_tbl$benefit))
  tree_tbl <- tree_tbl[!duplicated(tree_tbl[, "benefit"]),]

  # Run interpolation function
  tree_tbl$benefit_value <- eco_interp(x = tree_tbl$dbh_val, x1 = tree_tbl$x1, x2 = tree_tbl$x2, y1 = tree_tbl$y1, y2 = tree_tbl$y2)

  # Round benefit values to second second digit
  tree_tbl$benefit_value <- round(tree_tbl$benefit_value, digits = 4)

  # Select variables we need
  tree_tbl <- tree_tbl[c("scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit")]

  # Revert dbh back to inches from centimeters
  tree_tbl$dbh_val <- dbh

  # Rename dbh_val to dbh
  names(tree_tbl)[names(tree_tbl) == 'dbh_val'] <- 'dbh'

  # Reset row names
  rownames(tree_tbl) <- NULL

  return(tree_tbl)

  }
