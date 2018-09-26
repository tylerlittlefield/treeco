guess_common <- function(common, region) {

  # Make common input lower case
  common <- tolower(common)

  # Load species data
  df <- treeco::species

  # Grab variables we need
  df <- df[c("spp_value_assignment", "common_name", "species_region")]

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
    invisible(df)
  } else {
    message("Species given: [", common, "]\nClosest match: [", df$common_name[1], "]\n...\nUsing closest match", sep = "")
    invisible(df)
  }
}
