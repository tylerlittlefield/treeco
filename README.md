# treeco <img src="inst/figures/treeco.png" align="right" width=150/>
[![Travis build status](https://travis-ci.org/tyluRp/treeco.svg?branch=master)](https://travis-ci.org/tyluRp/treeco)

Eco benefits in R

## Installation

```
# install.packages("devtools")
devtools::install_github("tylurp/treeco")
```

## Demo

We can compute 15 eco benefits for a Common fig in the Inland Empire region with a 20" DBH using the following:

```
library(treeco)
eco_run("FICA", 20, "InlEmpCLM")

#    scientific_name common_name  dbh benefit_value            benefit  unit
# 1     Ficus carica  Common fig 50.8          0.11     aq nox avoided  <NA>
# 2     Ficus carica  Common fig 50.8          0.12         aq nox dep  <NA>
# 3     Ficus carica  Common fig 50.8          0.35       aq ozone dep  <NA>
# 4     Ficus carica  Common fig 50.8          0.03    aq pm10 avoided  <NA>
# 5     Ficus carica  Common fig 50.8          0.18        aq pm10 dep  <NA>
# 6     Ficus carica  Common fig 50.8          0.22     aq sox avoided  <NA>
# 7     Ficus carica  Common fig 50.8          0.02         aq sox dep  <NA>
# 8     Ficus carica  Common fig 50.8          0.03     aq voc avoided  <NA>
# 9     Ficus carica  Common fig 50.8          0.00               bvoc  <NA>
# 10    Ficus carica  Common fig 50.8         55.70        co2 avoided   kgs
# 11    Ficus carica  Common fig 50.8          4.10    co2 sequestered   kgs
# 12    Ficus carica  Common fig 50.8        569.60        co2 storage   kgs
# 13    Ficus carica  Common fig 50.8        189.20        electricity   kwh
# 14    Ficus carica  Common fig 50.8          3.16 hydro interception   m^3
# 15    Ficus carica  Common fig 50.8        -81.40        natural gas kbtus
```

Adding units for the other benefits soon.

## Components

`treeco` has two available functions and two datasets: `eco_run.R`, `eco_demo.R`, `eco_data` and `species_data`.

### eco_run.R

`eco_run.R` takes and requires 3 arguments.

1. species: the species code found in `species_data`
2. dbh: the dbh value of a tree, this can be any sensible number (i.e. no negative numbers)
3. region: the region code, also found in `species_data` as well as `eco_data`

### eco_demo.R

This is just a demo function that executes:

```
eco_run(species = "FICA", dbh = 20, region = "InlEmpCLM")
```

### eco_interp.R

This function is nested in `eco_run.R`. It interpolates benefit values (always) and will eventually interpolate values only when necessary. The following equation is used:

<p align="center"><a href="http://www.codecogs.com/eqnedit.php?latex=y&space;=&space;\frac{(x&space;-&space;x1)(y2&space;-&space;y1)}{x2&space;-&space;x1}&space;&plus;&space;y1" target="_blank"><img src="http://latex.codecogs.com/svg.latex?y&space;=&space;\frac{(x&space;-&space;x1)(y2&space;-&space;y1)}{x2&space;-&space;x1}&space;&plus;&space;y1" title="y = \frac{(x - x1)(y2 - y1)}{x2 - x1} + y1" /></a></p>

## Future updates

* Units column that corresponds with benefit value
* Calculate benefits for more than a single tree
* Choose species by name instead of code
* Clean up region codes for something more readable
* Inches/centimeter option for dbh argument
