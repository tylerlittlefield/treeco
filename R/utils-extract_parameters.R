extract_parameters <- function(tree_data) {

  message("Gathering interpolation parameters...")

  dbh_values <- tree_data[["dbh_val"]]
  dbh_ranges <- c(3.81, 11.43, 22.86, 38.10, 53.34, 68.58, 83.82, 99.06, 114.30)

  z <- abs(outer(dbh_values, dbh_ranges, `-`))

  tree_data   <- stats::na.omit(tree_data)
  tree_data$a <- unlist(apply(z, 1, which.min))
  z[z==apply(z, 1, min)] <- Inf
  tree_data$b     <- unlist(apply(z, 1, which.min))
  tree_data$start <- pmin(tree_data$a, tree_data$b)
  tree_data$end   <- pmax(tree_data$a, tree_data$b)
  tree_data$x1    <- dbh_ranges[tree_data$start]
  tree_data$x2    <- dbh_ranges[tree_data$end]

  # Grab the benefit values given the start/end vectors
  # https://stackoverflow.com/questions/20617371/
  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y1 <- tree_data$start
  tbl_mat         <- as.matrix(tree_data[,6:14]) # careful with this
  tree_data$y1    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y2 <- tree_data$end
  tbl_mat         <- as.matrix(tree_data[,6:14]) # careful with this, easy to fuck up
  tree_data$y2    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  return(tree_data)
}
