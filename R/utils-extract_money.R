extract_money <- function(tree_data, money_data) {

  elec_money <- money_data[grepl("electricity", money_data$variable)][["value"]]
  gas_money  <- money_data[grepl("natural_gas", money_data$variable)][["value"]]
  h20_money  <- money_data[grepl("h20_gal", money_data$variable)][["value"]]
  co2_money  <- money_data[grepl("co2", money_data$variable)][["value"]]
  o3_money   <- money_data[grepl("o3_lb", money_data$variable)][["value"]]
  nox_money  <- money_data[grepl("nox_lb", money_data$variable)][["value"]]
  pm10_money <- money_data[grepl("pm10_lb", money_data$variable)][["value"]]
  sox_money  <- money_data[grepl("sox_lb", money_data$variable)][["value"]]
  voc_money  <- money_data[grepl("voc_lb", money_data$variable)][["value"]]

  tree_data[grepl("lb", unit), "benefit_value" := benefit_value * 2.20462]
  tree_data[grepl("gal", unit), "benefit_value" := benefit_value * 264.172052]

  tree_data[grepl("electricity", benefit), "dollars" := benefit_value * elec_money]
  tree_data[grepl("natural gas", benefit), "dollars" := benefit_value * gas_money]
  tree_data[grepl("hydro interception", benefit), "dollars" := benefit_value * h20_money]
  tree_data[grepl("co2 ", benefit), "dollars" := benefit_value * co2_money]
  tree_data[grepl("aq ozone dep", benefit), "dollars" := benefit_value * o3_money]
  tree_data[grepl("aq nox", benefit), "dollars" := benefit_value * nox_money]
  tree_data[grepl("aq pm10", benefit), "dollars" := benefit_value * pm10_money]
  tree_data[grepl("aq sox", benefit), "dollars" := benefit_value * sox_money]
  tree_data[grepl("voc", benefit), "dollars" := benefit_value * voc_money]

  tree_data$dollars       <- abs(round(tree_data$dollars, 2))
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)

  return(tree_data)
}
