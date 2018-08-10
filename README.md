# treeco
Eco benefits in R

## Installation

```
# install.packages("devtools")
devtools::install_github("tylurp/treeco")
```

## Demo

We can compute 6 eco benefits for a Common fig in the Inland Empire with a 20" dbh using the following:

```
library(treeco)
eco_run("FICA", 20, "InlEmpCLM")

#   scientific_name common_name  dbh benefit_value             benefit
# 1    Ficus carica  Common fig 50.8         55.70         co2 avoided
# 2    Ficus carica  Common fig 50.8         50.52     co2 sequestered
# 3    Ficus carica  Common fig 50.8        569.60         co2 storage
# 4    Ficus carica  Common fig 50.8        189.20         electricity
# 5    Ficus carica  Common fig 50.8          3.16  hydro interception
# 6    Ficus carica  Common fig 50.8        -81.40         natural gas
```

Alternatively, `eco_demo()` will produce the same output.

## Components

`treeco` has two functions and two datasets: `eco_run.R`, `eco_demo.R`, `eco_data` and `species_data`.

### `eco_run.R`

`eco_run.R` takes and requires 3 arguments.

1. species: the species code found in `species_data`
2. dbh: the dbh value of a tree, this can be any sensible number (i.e. no negative numbers)
3. region: the region code, also found in `species_data` as well as `eco_data`

### `eco_demo.R`

This is just a demo function that executes `eco_run(species = "FICA", dbh = 20, region = "InlEmpCLM")`.

## Future updates

* Units column that corresponds with benefit value
* Choose species by name instead of code
* Clean up region codes for something more readable
* Inches/centimeter option for dbh argument
