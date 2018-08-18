#' Eco data
#'
#' A dataset containing the benefits and other attributes.
#'
#' @format A data frame with 62775 rows and 6 variables:
#' \describe{
#'   \item{species_code}{species code of tree}
#'   \item{species_region}{region of tree}
#'   \item{dbh_range}{dbh ranges for tree to fall under}
#'   \item{benefit_value}{benefit value associate with each dbh range}
#'   \item{benefit}{benefit type}
#'   \item{unit}{measurement unit for each benefit type}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"eco_data"

#' Species data
#'
#' A dataset containing species data and other attributes
#'
#' @format A data frame with 4006 rows and 11 variables:
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

#' Currency data
#'
#' A dataset containing benefit to currency conversion values
#'
#' @format A data frame with 4006 rows and 11 variables:
#' \describe{
#'   \item{region_code}{region code}
#'   \item{region_name}{region name}
#'   \item{electricity_kwh_to_currency}{electricity in kwh to currency}
#'   \item{natural_gas_kbtu_to_currency}{natural gas in kbtu to currency}
#'   \item{h20_gal_to_currency}{h20 in gallons to currency}
#'   \item{co2_lb_to_currency}{co2 in lbs to currency}
#'   \item{o3_lb_to_currency}{o3 in lbs to currency}
#'   \item{nox_lb_to_currency}{nox in lbs to currency}
#'   \item{pm10_lb_to_currency}{pm10 in lbs to currency}
#'   \item{sox_lb_to_currency}{sox in lbs to currency}
#'   \item{voc_lb_to_currency}{voc in lbs to currency}
#'   ...
#' }
#' @source \url{https://www.itreetools.org}
"currency_data"
