#' Guess common or botanical names
#'
#' @description This function tries to guess the botanical or common name of
#' tree for users with only one of these fields, not both. Since \code{eco_run}
#' attempts to find matches in both common and botanical, running this can
#' increase the number of records you can grab to run eco benefits.
#'
#' @param data A vector containing "common" or "botanical" names.
#' @param have The name of the existing field.
#' @param guess The missing field, either "common" or "botanical".
#'
#' @export
eco_guess <- function(data, have, guess) {

  # Which field is it? Common or botanical?
  if(guess == "common") {species <- treeco::species$scientific_name}
  if(guess %in% c("botanical", "scientific")) {species <- treeco::species$common_name}

  # Lower case for user data and species master list in hopes it improve the
  # guessing.
  tree_vec <- unique(tolower(as.character(data[[have]])))
  field_vec <- unique(tolower(species))

  # Remove NA's from them both.
  tree_vec <- tree_vec[!is.na(tree_vec)]
  field_vec <- field_vec[!is.na(field_vec)]

  # Remove punctuation.
  tree_vec <- gsub('[[:punct:]]+', '', tree_vec)
  field_vec <- gsub('[[:punct:]]+', '', field_vec)

  # Trim any white space.
  tree_vec <- trimws(tree_vec, "both")
  field_vec <- trimws(field_vec, "both")

  # Grab the index of the highest match for each unique tree
  field_idx <- unlist(lapply(tree_vec, function(x) which.max(string_dist(x, field_vec))))

  # Grab the guessed species
  if(guess == "common") {field_vec <- treeco::species$common_name[field_idx]}
  if(guess == "botanical") {field_vec <- treeco::species$scientific_name[field_idx]}

  # Store as data.frame
  tree_df <- data.frame(
    original = tree_vec,
    field_guess = field_vec
  )

  return(tree_df)

}

# # Toy data
# df <- data.frame(
#   common_name = c("Common fig", "Common fig", "Deodar' Cedar", NA),
#   botanical_name = c("Ficus carica", NA, "Cedrus deodara ", "Ficus carica")
#   )
#
# # Run
# eco_guess(
#   data = df,
#   have = "botanical_name",
#   guess = "common"
#   )
