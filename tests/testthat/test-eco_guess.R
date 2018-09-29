context("test-eco_guess")

test_that("eco_guess works", {
  expect_equal(eco_guess("common fig", "botanical"), "Ficus carica")
  expect_equal(eco_guess("pinus elderica", "common"), "Afghan pine")
})
