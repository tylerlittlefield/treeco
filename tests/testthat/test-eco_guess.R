context("test-eco_guess")

# Common guess toy data frame
botanical_species <- rep(sample(unique(treeco::species$scientific_name), size = 50), length.out=1)
df_botanical <- data.frame(botanical_name = botanical_species)
common_guess <- eco_guess(
  data = df_botanical,
  have = "botanical_name",
  guess = "common"
)

# Botanical guess toy data frame
common_species <- rep(sample(unique(treeco::species$common_name), size = 50), length.out=1)
df_common <- data.frame(common_name = common_species)
botanical_guess <- eco_guess(
  data = df_common,
  have = "common_name",
  guess = "botanical"
)

test_that("eco_guess works", {
  expect_equal(
    common_guess$field_guess %in% treeco::species$common_name, TRUE
  )
  expect_equal(
    botanical_guess$field_guess %in% treeco::species$scientific_name, TRUE
  )
})
