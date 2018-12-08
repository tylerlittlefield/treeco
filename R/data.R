#' tbenefits dataset
#'
#' A dataset containing benefits, dbh ranges, and other attributes for specific
#' species using the "spp_value_assignment", i-Tree's way of linking species to
#' their appropriate benefit values.
#'
#' @format A data frame with 62,775 rows and 6 variables:
#' \describe{
#'   \item{code}{This is the "spp_value_assignment" and acts as a key linking trees to their appropriate benefit values.}
#'   \item{region}{The region code representing a specific region.}
#'   \item{benefit}{The type of benefit.}
#'   \item{unit}{The unit of measurement for a benefit type.}
#'   \item{dbh}{DBH Measured in centimeters.}
#'   \item{value}{The value associated with the benefit.}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"tbenefits"

#' tspecies dataset
#'
#' A dataset containing species data and other attributes.
#'
#' @format A data frame with 3178 rows and 11 variables:
#' \describe{
#'   \item{code}{The species code}
#'   \item{botanical}{Botanical tree name}
#'   \item{common}{Common tree name}
#'   \item{region}{Tree region}
#'   \item{type}{Tree type}
#'   \item{assignment}{Another tree code for linking trees to benefits}
#'   \item{rating}{Percent species rating}
#'   \item{price_sq_in}{Price per square inch}
#'   \item{palm_trunk_cost_ft}{Palm trunk cost per feet}
#'   \item{replacement_cost}{Tree replacement cost}
#'   \item{t_ar_sq_inches}{to be determined...}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"tspecies"

#' tmoney dataset
#'
#' A dataset containing benefit to currency conversion values. This dataset is how benefit values get converted to dollar amounts.
#'
#' @format A data frame with 144 rows and 4 variables:
#' \describe{
#'   \item{region}{Region code}
#'   \item{region_name}{Region name associated with region code}
#'   \item{conversion}{Conversion description}
#'   \item{value}{Value in dollars}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"tmoney"
