context("test-eco_run_all")

species <- treeco::species
unique_species <- unique(species$scientific_name)
unique_species_sample <- sample(unique_species, size = 50)
species <- rep(unique_species_sample, length.out = 10)

df_species <- data.frame(botanical_name = species, stringsAsFactors = FALSE)

df_species$common_name <- eco_guess(df_species$botanical_name, "common")

# Add a DBH column
df_species$dbh <- rep(sample(2:45), length.out = 10)

output <- eco_run_all(
  data = df_species,
  common_col = "common_name",
  botanical_col = "botanical_name",
  dbh_col = "dbh",
  region = "InlEmpCLM",
  print_time = TRUE
)

test_that("eco_run_all works", {

  # Test that there are 9 variables returned
  expect_equal(dim(output)[2], 9)

  # Test that the print statement works, eco_run_all stores the elapsed
  # time as an attribute "elapsed_time"
  expect_equal(is.null(attributes(output)$elapsed_time), FALSE)

  # Test that inappropriate values to n are handled correctly
  expect_warning(eco_run_all(
    data = df_species,
    common_col = "common_name",
    botanical_col = "botanical_name",
    dbh_col = "dbh",
    region = "InlEmpCLM",
    n = 1.1,
    print_time = TRUE
  ))
  expect_warning(eco_run_all(
    data = df_species,
    common_col = "common_name",
    botanical_col = "botanical_name",
    dbh_col = "dbh",
    region = "InlEmpCLM",
    n = -0.1,
    print_time = TRUE
  ))

})
