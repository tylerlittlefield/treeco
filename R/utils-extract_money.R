find_conversion <- function(x, pattern) {
  x[grepl(pattern, x$variable)][["value"]]
}

dollars <- function(x, pattern, conversion) {
  `:=` = NULL

  benefit = NULL
  benefit_value = NULL
  x[grepl(pattern, benefit), "dollars" := benefit_value * conversion]
}

extract_money <- function(tree_data, money_data) {

  # To avoid notes about global variables
  # See: https://github.com/Rdatatable/data.table/issues/850
  unit = NULL
  benefit = NULL
  benefit_value = NULL
  `:=` = NULL

  elec_money <- find_conversion(money_data, "electricity")
  gas_money  <- find_conversion(money_data, "natural_gas")
  h20_money  <- find_conversion(money_data, "h20_gal")
  co2_money  <- find_conversion(money_data, "co2")
  o3_money   <- find_conversion(money_data, "o3_lb")
  nox_money  <- find_conversion(money_data, "nox_lb")
  pm10_money <- find_conversion(money_data, "pm10_lb")
  sox_money  <- find_conversion(money_data, "sox_lb")
  voc_money  <- find_conversion(money_data, "voc_lb")

  tree_data[grepl("lb", unit), "benefit_value" := benefit_value * 2.20462]
  tree_data[grepl("gal", unit), "benefit_value" := benefit_value * 264.172052]

  dollars(tree_data, "electricity", elec_money)
  dollars(tree_data, "natural gas", gas_money)
  dollars(tree_data, "hydro interception", h20_money)
  dollars(tree_data, "co2", co2_money)
  dollars(tree_data, "aq ozone dep", o3_money)
  dollars(tree_data, "aq nox", nox_money)
  dollars(tree_data, "aq pm10", pm10_money)
  dollars(tree_data, "aq sox", sox_money)
  dollars(tree_data, "voc", voc_money)

  tree_data$dollars <- abs(round(tree_data$dollars, 2))
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)

  return(tree_data)
}
