# treeco [![Travis build status](https://travis-ci.org/tyluRp/treeco.svg?branch=master)](https://travis-ci.org/tyluRp/treeco) <img src="inst/figures/treeco.png" align="right" width=150/>


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
# 1     Ficus carica  Common fig 50.8        0.1102     aq nox avoided  <NA>
# 2     Ficus carica  Common fig 50.8        0.1190         aq nox dep  <NA>
# 3     Ficus carica  Common fig 50.8        0.3500       aq ozone dep  <NA>
# 4     Ficus carica  Common fig 50.8        0.0273    aq pm10 avoided  <NA>
# 5     Ficus carica  Common fig 50.8        0.1850        aq pm10 dep  <NA>
# 6     Ficus carica  Common fig 50.8        0.2183     aq sox avoided  <NA>
# 7     Ficus carica  Common fig 50.8        0.0160         aq sox dep  <NA>
# 8     Ficus carica  Common fig 50.8        0.0273     aq voc avoided  <NA>
# 9     Ficus carica  Common fig 50.8        0.0000               bvoc  <NA>
# 10    Ficus carica  Common fig 50.8       55.7000        co2 avoided   kgs
# 11    Ficus carica  Common fig 50.8        4.1000    co2 sequestered   kgs
# 12    Ficus carica  Common fig 50.8      569.6000        co2 storage   kgs
# 13    Ficus carica  Common fig 50.8      189.2000        electricity   kwh
# 14    Ficus carica  Common fig 50.8        3.1600 hydro interception   m^3
# 15    Ficus carica  Common fig 50.8      -81.4000        natural gas kbtus
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

## Future plans

I'm hoping to improve the user experience quite a bit. For example, it's a pain to select a tree at the moment because this package relies on the user inputting the species code instead of the common name. For now, the best solution for looking up these codes is to run something like `unique(species_data[c("species_code", "common_name")])` where the first 6 rows would look something like:

```
#   species_code   common_name
# 1           AB           Fir
# 2         ABCO     White fir
# 3        ACBA2 Bailey acacia
# 4         ACBU Trident maple
# 5         ACCA   Hedge maple
# 6         ACFR Freeman maple
```

I would suggest using the `View` function in RStudio so you can search for the specific tree by common or scientific name. So something like: `View(unique(species_data[c("species_code", "common_name")]))`

Additionally, I'm also interested in:

* An Imperial/Metric arugment to display units differently depending on what the user wants.
* Calculating benefits for an entire dataset
* Better documentation, a vignette
* Add monetary values to benefits
