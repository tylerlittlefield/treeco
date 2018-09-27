context("test-utils-capitalize")

test_that("utils-capitalize works", {
  expect_equal(capitalize("cat dog"), "Cat dog")
})
