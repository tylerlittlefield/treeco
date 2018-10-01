context("test-eco_guess")

test_that("eco_guess works", {

  # Test that eco guess can guess the botanical names
  expect_equal(eco_guess("common fig", "botanical"), "Ficus carica")

  # Test that eco guess can guess the common names
  expect_equal(eco_guess("pinus elderica", "common"), "Afghan pine")

  # Test that eco guess guesses duplicates
  expect_equal(eco_guess(c("pinus elderica", "pinus elderica"), "common"), c("Afghan pine", "Afghan pine"))

  # Test that eco guess converts factor to character
  expect_equal(is.character(eco_guess(as.factor("Common fig"), "botanical")), TRUE)

  # Test that eco guess throws an error if guess arg isn't 'common' or 'botanical'
  expect_error(eco_guess("common fig", "botancal"), "Guess arg isn't 'common' or 'botanical'.")
})
