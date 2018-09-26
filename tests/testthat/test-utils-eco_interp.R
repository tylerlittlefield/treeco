context("test-utils-eco_interp")

test_that("eco_interp works", {
  expect_equal(eco_interp(50.8, 38.10, 55.7, 53.34, 55.7), 55.7)
  expect_equal(eco_interp(50.8, 38.10, 24.6, 53.34, 0.0), 4.1)
})
