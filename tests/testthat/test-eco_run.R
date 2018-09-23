context("test-eco_run")

test_that("eco_run works", {

  # Test that guessing works p. 1
  expect_equal(
    unique(eco_run("common ig", 20, "InlEmpCLM")[[1]]), "Common fig"
  )

  # Test that guessing works p. 2
  expect_equal(
    unique(eco_run("ed MaPle", 20, "InlEmpCLM")[[1]]), "Red maple"
  )

  # Test that all 15 observations are returned
  expect_equal(
    dim(eco_run("Common fig", 20, "InlEmpCLM"))[1], 15
  )

  # Test that all 6 variables are returned
  expect_equal(
    dim(eco_run("Common fig", 20, "InlEmpCLM"))[2], 6
  )

  # Test that structure is correct
  expect_equal(
    is.character(eco_run("Common fig", 20, "InlEmpCLM")$common_name), TRUE
  )
  expect_equal(
    is.numeric(eco_run("Common fig", 20, "InlEmpCLM")$dbh), TRUE
  )
  expect_equal(
    is.numeric(eco_run("Common fig", 20, "InlEmpCLM")$benefit_value), TRUE
  )
  expect_equal(
    is.character(eco_run("Common fig", 20, "InlEmpCLM")$benefit), TRUE
  )
  expect_equal(
    is.character(eco_run("Common fig", 20, "InlEmpCLM")$unit), TRUE
  )
  expect_equal(
    is.numeric(eco_run("Common fig", 20, "InlEmpCLM")$dollars), TRUE
  )
})
