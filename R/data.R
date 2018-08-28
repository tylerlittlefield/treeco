#' Benefits data
#'
#' A dataset containing benefits, dbh ranges, and other attributes for specific
#' species using the "spp_value_assignment", i-Tree's way of linking species to
#' their appropriate benefit values.
#'
#' @format A data frame with 7440 rows and 12 variables:
#' \describe{
#'   \item{id}{id variable.}
#'   \item{species_code}{This is the "spp_value_assignment" and acts as a key linking trees to their appropriate benefit values.}
#'   \item{x3_81}{DBH range of 3.81 centimeters.}
#'   \item{x11_43}{DBH range of 11.43 centimeters.}
#'   \item{x22_86}{DBH range of 22.86 centimeters.}
#'   \item{x38_10}{DBH range of 38.10 centimeters.}
#'   \item{x53_34}{DBH range of 53.34 centimeters.}
#'   \item{x68_58}{DBH range of 68.58 centimeters.}
#'   \item{x83_82}{DBH range of 83.82 centimeters.}
#'   \item{x99_06}{DBH range of 99.06 centimeters.}
#'   \item{x114_30}{DBH range of 114.30 centimeters.}
#'   \item{species_region}{The region code representing a specific region. Benefit values change depending on the region.}
#'   \item{benefit}{The type of benefit.}
#'   \item{unit}{The unit of measurment for a benefit.}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"benefits"

#' Species data
#'
#' A dataset containing species data and other attributes.
#'
#' @format A data frame with 4006 rows and 11 variables:
#' \describe{
#'   \item{id}{id variable.}
#'   \item{species_code}{species code}
#'   \item{scientific_name}{scientific name of tree}
#'   \item{common_name}{common name of tree}
#'   \item{tree_type}{type of tree}
#'   \item{spp_value_assignment}{another tree code for linking trees to benefits}
#'   \item{species_rating_percent}{to be determined...}
#'   \item{basic_price_sq_in}{to be determined...}
#'   \item{palm_trunk_cost_ft}{to be determined...}
#'   \item{replacement_cost}{to be determined...}
#'   \item{t_ar_sq_inches}{to be determined...}
#'   \item{species_region}{region of tree}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"species"

#' Money data
#'
#' A dataset containing benefit to currency conversion values. This dataset is how benefit values get converted to dollar amounts.
#'
#' @format A data frame with 16 rows and 11 variables:
#' \describe{
#'   \item{region_code}{The region code.}
#'   \item{region_name}{The region name, meant to be human readable for users to pick the appropriate region code.}
#'   \item{electricity_kwh_to_currency}{Electricity in kwh to dollar amount.}
#'   \item{natural_gas_kbtu_to_currency}{Natural gas in kbtu to dollar amount.}
#'   \item{h20_gal_to_currency}{H20 in gallons to dollar amount.}
#'   \item{co2_lb_to_currency}{CO2 in lbs to dollar amount.}
#'   \item{o3_lb_to_currency}{O3 in lbs to dollar amount.}
#'   \item{nox_lb_to_currency}{NOX in lbs to dollar amount.}
#'   \item{pm10_lb_to_currency}{PM10 in lbs to dollar amount.}
#'   \item{sox_lb_to_currency}{SOX in lbs to dollar amount.}
#'   \item{voc_lb_to_currency}{VOC in lbs to dollar amount.}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"money"
