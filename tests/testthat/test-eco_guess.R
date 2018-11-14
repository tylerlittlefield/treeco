context("test-eco_guess")

test_that("eco_guess works", {

  # Test that eco guess can guess the botanical names
  expect_equal(eco_guess("common fig", "botanical"), "ficus carica")

  # Test that eco guess can guess the common names
  expect_equal(eco_guess("pinus elderica", "common"), "afghan pine")

  # Test that eco guess guesses duplicates
  expect_equal(eco_guess(c("pinus elderica", "pinus elderica"), "common"), c("afghan pine", "afghan pine"))

  # Test that warning message pops up when it should
  expect_warning(val <- eco_guess(as.factor("Common fig"), "botanical"))

  # Test that eco guess converts factor to character
  expect_true(is.character(val), TRUE)

  # Test that eco guess throws an error if guess arg isn't 'common' or 'botanical'
  expect_error(eco_guess("common fig", "botancal"), "Guess arg isn't 'common' or 'botanical'.")
})
