extract_parameters <- function(tree_data) {

  # Grab the dbh values from the users tree data. Also grab the dbh ranges
  # i-Tree uses, these ranges are actually column names and represent x1 and x2
  # in the interpolation equation.
  dbh_values <- tree_data[["dbh_val"]]
  dbh_ranges <- c(3.81, 11.43, 22.86, 38.10, 53.34, 68.58, 83.82, 99.06, 114.30)

  # Basically magic to me, this takes the absolute value of the
  # dbh values - dbh ranges which we can then use to find x1 and x2.
  z <- abs(outer(dbh_values, dbh_ranges, `-`))

  # Remove any NAs in the users tree data, if any
  tree_data   <- stats::na.omit(tree_data)

  # Rowwise, find the position of the minimum value of z
  tree_data$a <- unlist(apply(z, 1, which.min))

  # Then convert that minimum to Inf so we can find the second minimum. This
  # is sorta hacky, but it's fast. See Richie Cotton's answer on stackoverflow:
  # https://stackoverflow.com/questions/5569038/
  z[z == apply(z, 1, min)] <- Inf

  # Grab the position of second minimum
  tree_data$b     <- unlist(apply(z, 1, which.min))

  # Now grab the parellel minimum of the two positions. This insures that we
  # don't store incorrect values in x1 and x2. See the example below for a more
  # clear/visual explanation:
  # dbh_val a b start end    x1    x2
  # 18      3 2     2   3 11.43 22.86
  # Note how a and b are then switched from 3/2 to 2/3 so that x1 and x2 are
  # correct. There is certainly a better logic for this but this is what we got
  # at the moment.
  tree_data$start <- pmin(tree_data$a, tree_data$b)
  tree_data$end   <- pmax(tree_data$a, tree_data$b)
  tree_data$x1    <- dbh_ranges[tree_data$start]
  tree_data$x2    <- dbh_ranges[tree_data$end]

  # Grab the benefit values given the start/end vectors
  # https://stackoverflow.com/questions/20617371/
  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y1 <- tree_data$start
  tbl_mat         <- as.matrix(tree_data[,7:15]) # careful, easy to mess up
  tree_data$y1    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y1)]

  tbl_rows        <- seq_along(tree_data$id)
  tbl_indicies_y2 <- tree_data$end
  tbl_mat         <- as.matrix(tree_data[,7:15]) # careful, easy to mess up
  tree_data$y2    <- tbl_mat[cbind(tbl_rows, tbl_indicies_y2)]

  return(tree_data)
}
