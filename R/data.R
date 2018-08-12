#' Eco data
#'
#' A dataset containing the benefits and other attributes.
#'
#' @format A data frame with 34164 rows and 5 variables:
#' \describe{
#'   \item{X}{id number}
#'   \item{species_code}{species code of tree}
#'   \item{species_region}{region of tree}
#'   \item{dbh_range}{dbh ranges for tree to fall under}
#'   \item{benefit_value}{benefit value associate with each dbh range}
#'   \item{benefit}{benefit type}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"eco_data"

#' Species data
#'
#' A dataset containing species data and other attributes
#'
#' @format A data frame with 3178 rows and 11 variables:
#' \describe{
#'   \item{species_code}{species code}
#'   \item{scientific_name}{scientific name of tree}
#'   \item{common_name}{common name of tree}
#'   \item{tree_type}{type of tree}
#'   \item{spp_value_assignment}{another tree code for linking trees to benefits}
#'   \item{species_rating}{to be determined...}
#'   \item{basic_price_sq_in}{to be determined...}
#'   \item{palm_trunk_cost_ft}{to be determined...}
#'   \item{replacement_cost}{to be determined...}
#'   \item{t_ar_sq_inches}{to be determined...}
#'   \item{species_region}{region of tree}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"species_data"
