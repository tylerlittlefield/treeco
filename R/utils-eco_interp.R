eco_interp <- function(x, x1, y1, x2, y2) {

  # Assert that the interpolation values are numeric
  stopifnot(
    is.numeric(x),
    is.numeric(x1),
    is.numeric(y1),
    is.numeric(x2),
    is.numeric(y2)
  )

  y = ((x - x1) * (y2 - y1) / (x2 - x1)) + y1
  return(y)
}
