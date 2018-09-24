context("test-eco_run_all")

species <- treeco::species
unique_species <- unique(species$scientific_name)
unique_species_sample <- sample(unique_species, size = 50)
species <- rep(unique_species_sample, length.out = 10)

df_species <- data.frame(botanical_name = species)

common_guess <- treeco::eco_guess(
  data = df_species,
  have = "botanical_name",
  guess = "common"
)

# Select required variables
my_inventory <- common_guess[c("original", "field_guess")]

# Add a DBH column
my_inventory$dbh <- rep(sample(2:45), length.out = 10)

names(my_inventory)[1] <- "botanical"
names(my_inventory)[2] <- "common"

output <- eco_run_all(
  data = my_inventory,
  common_col = "common",
  botanical_col = "botanical",
  dbh_col = "dbh",
  region = "InlEmpCLM",
  print_time = TRUE
)

test_that("eco_run_all works", {

  # Test that there are 8 variables returned
  expect_equal(dim(output)[2], 8)

  # Test that the print statement works, eco_run_all stores the elapsed
  # time as an attribute "elapsed_time"
  expect_equal(is.null(attributes(output)$elapsed_time), FALSE)
})
