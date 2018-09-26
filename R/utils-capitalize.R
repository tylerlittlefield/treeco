capitalize <- function(tree_data, var) {
  var <- paste0(
    toupper(substr(tree_data[[var]], 1, 1)),
    substr(tree_data[[var]], 2, nchar(tree_data[[var]]))
  )

  return(var)
}
