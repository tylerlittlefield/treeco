#' Run eco demo
#' @export
eco_demo <- function() {

  # Interpolation function
  eco_interp <- function(x, x1, y1, x2, y2) {
    y <- ((x - x1) * (y2 - y1) / (x2 - x1)) + y1
    return(y)
  }

  # Example data
  fig <- data.frame(
    species_code = "FICA",
    dbh_val = 20 * 2.54 # Need argument for units so we can convert inches to centimeters
  )

  # Subset data by region
  eco_tbl <- eco_data[eco_data$species_region == "InlEmpCLM", ]
  species_tbl <- species_data[species_data$species_region == "InlEmpCLM", ]

  # Select variables we need
  species_tbl <- species_tbl[1:5]

  # Join species_tbl to fig example data
  fig <- merge(
    x = species_tbl,
    y = fig,
    by.x = "species_code",
    by.y = "species_code",
    all.x = FALSE
  )

  # Remove duplicates, this wasn't required before, figure this out
  fig <- subset(fig, !duplicated(fig$species_code))

  # Join fig to eco_tbl
  fig <- merge(
    x = fig,
    y = eco_tbl,
    by.x = "spp_value_assignment",
    by.y = "species_code",
    all.x = TRUE
  )

  # Select variables we need
  fig <- fig[c("scientific_name", "common_name", "dbh_val", "dbh_range", "benefit_value", "benefit", "unit")]

  # Calculate absolute value of dbh - dbh_range
  fig$dbh_diff <- abs(fig$dbh_val - fig$dbh_range)

  # Order dbh_diff in ascending order
  fig <- fig[order(fig$dbh_diff, decreasing = FALSE), ]

  # Grab the first two records grouped by benefit, this will be the lowest dbh_diff values
  fig <- fig[stats::ave(fig$dbh_diff, fig$benefit, FUN = seq_along) <= 2, ]

  # Order dbh_range in ascending order
  fig <- fig[order(fig$dbh_range, fig$benefit, decreasing = FALSE), ]

  # Set up variables for interpolation function
  fig$x1 <- min(fig$dbh_range)
  fig$x2 <- max(fig$dbh_range)
  fig$y1 <- fig[stats::ave(fig$benefit_value, fig$benefit, FUN = seq_along) == 1, ][["benefit_value"]]
  fig$y2 <- fig[stats::ave(fig$benefit_value, fig$benefit, FUN = seq_along) == 2, ][["benefit_value"]]

  # Remove duplicate benefits
  fig <- subset(fig, !duplicated(fig$benefit))

  # Run interpolation function
  fig$benefit_value <- eco_interp(x = fig$dbh_val, x1 = fig$x1, x2 = fig$x2, y1 = fig$y1, y2 = fig$y2)

  # Round benefit values to second second digit
  fig$benefit_value <- round(fig$benefit_value, digits = 2)

  # Select variables we need
  fig <- fig[c("scientific_name", "common_name", "dbh_val", "benefit_value", "benefit", "unit")]

  # Rename dbh_val to dbh
  names(fig)[names(fig) == "dbh_val"] <- "dbh"

  # Reset row names
  rownames(fig) <- NULL

  return(fig)

  rm(fig, species_tbl, eco_tbl)

}
