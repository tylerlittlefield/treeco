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

## Future updates

* Units column that corresponds with benefit value
* Choose species by name instead of code
* Clean up region codes for something more readable
* Inches/centimeter option for dbh argument
