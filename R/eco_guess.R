#' Guess common or botanical names
#'
#' @description This function tries to guess the botanical or common names of
#' trees for users with only one of these fields, not both. Since
#' \code{eco_run_all} attempts to find matches in both common and botanical,
#' running this is required for users that are missing one of these fields.
#'
#' @param x A vector containing "common" or "botanical" names.
#' @param guess The missing field, either "common" or "botanical".
#'
#' @examples
#' eco_guess("common fig", "botanical")
#'
#' eco_guess("pinus eldarica", "common")
#'
#' @export
eco_guess <- function(x, guess) {

  '%nin%' <- Negate('%in%')

  if(guess %nin% c("common", "botanical"))
  {stop("Guess arg isn't 'common' or 'botanical'.")}

  if(is.factor(x))
  {warning("Note: x is factor, converting to character.", call. = FALSE); x <- as.character(x)}

  ifelse(
    test = guess == "common",
    yes = x <- data.table::data.table("botanical_name" = x, "key_var" = x),
    no = x <- data.table::data.table("common_name" = x, "key_var" = x)
    )

  species <- unique(treeco::species[c("common_name", "scientific_name")])

  # Lower case for user data and species master list in hopes it improve the
  # guessing.
  x$key_var <- tolower(as.character(x$key_var))
  species$common_name <- tolower(species$common_name)
  species$scientific_name <- tolower(species$scientific_name)

  # Remove NA's from them both.
  x <- stats::na.omit(x)
  species <- species[stats::complete.cases(species), ]

  # Remove punctuation.
  x$key_var <- gsub('[[:punct:]]+', '', x$key_var)
  species$common_name <- gsub('[[:punct:]]+', '', species$common_name)
  species$scientific_name <- gsub('[[:punct:]]+', '', species$scientific_name)

  # Trim any white space.
  x$key_var <- trimws(x$key_var, "both")
  species$common_name <- trimws(species$common_name, "both")
  species$scientific_name <- trimws(species$scientific_name, "both")

  x_unique <- unique(x)

  # Grab the index of the highest match for each unique tree

  ifelse(
    test = guess == "common",
    yes = field_idx <- unlist(lapply(x_unique$botanical_name, function(x) which.max(string_dist(x, species$scientific_name)))),
    no = field_idx <- unlist(lapply(x_unique$common_name, function(x) which.max(string_dist(x, species$common_name))))
    )

  # Grab the guessed species
  if(guess == "common") {
    x_unique$common_name <- species$common_name[field_idx]
    output <- x_unique[x, on = "key_var"]
    output <- output$common_name
    }
  if(guess == "botanical") {
    x_unique$botanical_name <- species$scientific_name[field_idx]
    output <- x_unique[x, on = "key_var"]
    output <- output$botanical_name
    }

  output <- capitalize(output)

  return(output)

}
