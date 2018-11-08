#' @importFrom utils adist
string_dist <- function(str_1, str_2) {

  # Assert that "str_1" and "str_2" are characters
  stopifnot(
    is.character(str_1),
    is.character(str_2)
  )

  1 - (adist(str_1, str_2) / pmax(nchar(str_1), nchar(str_2)))
}
