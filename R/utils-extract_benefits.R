extract_benefits <- function(tree_data) {
  tree_data[, benefit_value := ifelse(y1 == y2, y1, eco_interp(x = tree_data$dbh_val, x1 = tree_data$x1, x2 = tree_data$x2, y1 = tree_data$y1, y2 = tree_data$y2))]
  tree_data$benefit_value <- round(tree_data$benefit_value, 4)
  return(tree_data)
}
