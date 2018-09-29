#' Guess common or botanical names
#'
#' @description This function tries to guess the botanical or common name of
#' tree for users with only one of these fields, not both. Since \code{eco_run}
#' attempts to find matches in both common and botanical, running this can
#' increase the number of records you can grab to run eco benefits.
#'
#' @param x A vector containing "common" or "botanical" names.
#' @param guess The missing field, either "common" or "botanical".
#'
#' @export
eco_guess <- function(x, guess) {

  species <- unique(treeco::species[c("common_name", "scientific_name")])

  # Lower case for user data and species master list in hopes it improve the
  # guessing.
  tree_vec <- unique(tolower(as.character(x)))
  species$common_name <- tolower(species$common_name)
  species$scientific_name <- tolower(species$scientific_name)

  # Remove NA's from them both.
  tree_vec <- tree_vec[!is.na(tree_vec)]
  species <- species[stats::complete.cases(species), ]

  # Remove punctuation.
  tree_vec <- gsub('[[:punct:]]+', '', tree_vec)
  species$common_name <- gsub('[[:punct:]]+', '', species$common_name)
  species$scientific_name <- gsub('[[:punct:]]+', '', species$scientific_name)

  # Trim any white space.
  tree_vec <- trimws(tree_vec, "both")
  species$common_name <- trimws(species$common_name, "both")
  species$scientific_name <- trimws(species$scientific_name, "both")

  # Grab the index of the highest match for each unique tree

  ifelse(
    test = guess == "common",
    yes = field_idx <- unlist(lapply(tree_vec, function(x) which.max(string_dist(x, species$scientific_name)))),
    no = field_idx <- unlist(lapply(tree_vec, function(x) which.max(string_dist(x, species$common_name))))
    )

  # Grab the guessed species
  if(guess == "common") {output <- species$common_name[field_idx]}
  if(guess == "botanical") {output <- species$scientific_name[field_idx]}

  output <- capitalize(output)

  return(output)

}
