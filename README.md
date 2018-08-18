# treeco [![Travis build status](https://travis-ci.org/tyluRp/treeco.svg?branch=master)](https://travis-ci.org/tyluRp/treeco) <img src="inst/figures/treeco.png" align="right" width=150/>


Eco benefits in R

## Installation

```r
# install.packages("devtools")
devtools::install_github("tylurp/treeco")
```

## Demo

We can compute 15 eco benefits for a Common fig in the Inland Empire region with a 20" DBH using the following:

```r
library(treeco)
eco_run("common fig", 20, "InlEmpCLM")

#    scientific_name common_name dbh benefit_value            benefit  unit
# 1     Ficus carica  Common fig  20        0.1102     aq nox avoided  <NA>
# 2     Ficus carica  Common fig  20        0.1190         aq nox dep  <NA>
# 3     Ficus carica  Common fig  20        0.3500       aq ozone dep  <NA>
# 4     Ficus carica  Common fig  20        0.0273    aq pm10 avoided  <NA>
# 5     Ficus carica  Common fig  20        0.1850        aq pm10 dep  <NA>
# 6     Ficus carica  Common fig  20        0.2183     aq sox avoided  <NA>
# 7     Ficus carica  Common fig  20        0.0160         aq sox dep  <NA>
# 8     Ficus carica  Common fig  20        0.0273     aq voc avoided  <NA>
# 9     Ficus carica  Common fig  20        0.0000               bvoc  <NA>
# 10    Ficus carica  Common fig  20       55.7000        co2 avoided   kgs
# 11    Ficus carica  Common fig  20        4.1000    co2 sequestered   kgs
# 12    Ficus carica  Common fig  20      569.6000        co2 storage   kgs
# 13    Ficus carica  Common fig  20      189.2000        electricity   kwh
# 14    Ficus carica  Common fig  20        3.1600 hydro interception   m^3
# 15    Ficus carica  Common fig  20      -81.4000        natural gas kbtus
```

Adding units for the other benefits soon.

## Components

`treeco` has three available functions and two datasets: `eco_run.R`, `eco_run_all.R`, `eco_demo.R`, `eco_data` and `species_data`.

### eco_run.R

This function acts like a calculator similiar to [this one](http://www.treebenefits.com/calculator/) but much less content. `eco_run.R` takes and requires 3 arguments.

1. species: the common name of the species, if a match isn't found, the function will make it's best guess
2. dbh: the dbh value of a tree, this can be any sensible number (i.e. no negative numbers)
3. region: the region code, also found in `species_data` as well as `eco_data`

### eco_run_all.R

_Note: Currently a work in progress, use with caution_

This function calculates eco benefits for an entire tree inventory. `eco_run_all.R` utilizes the popular [`data.table`](https://github.com/Rdatatable/data.table) package for speed. Calculating the eco benefits of 400,000 trees takes ~10-20 seconds. `eco_run_all.R` takes and requires 4 arguments:

1. `data`: the path to a `csv` file containing the tree data
    * The `csv` must have the following 2 fields: common name for tree species and dbh for dbh values
2. `species_col`: the name of the common name field, case sensitive (for now).
3. `dbh_col`: the name of the dbh field, case sensitive (for now).
4. `region`: the region the trees are located in. For now, not a convient way to figure this field out. You can see a list of the region values in the `eco_data` or `species_data` datasets. I will update this readme with the region codes and what they represent, it isn't very clear at the moment.

```r
treeco::eco_run_all(
  data = "data/toy.csv",
  species_col = "common_name",
  dbh_col = "dbh_val",
  region = "InlEmpCLM"
)

# Importing: toy.csv...
# toy.csv imported.
# Reconfiguring data...
# Data reconfigured.
# Guessing species codes...
# Species codes gathered.
# Linking species codes to the data...
# Species codes linked.
# Calculating benefits for 400001 trees...
# Complete.
# 
#              id         scientific_name common_name dbh benefit_value            benefit  unit
#       1:      1           Abies procera   Noble fir   1        0.0024     aq nox avoided  <NA>
#       2:      1           Abies procera   Noble fir   1        0.0010         aq nox dep  <NA>
#       3:      1           Abies procera   Noble fir   1        0.0035       aq ozone dep  <NA>
#       4:      1           Abies procera   Noble fir   1        0.0006    aq pm10 avoided  <NA>
#       5:      1           Abies procera   Noble fir   1        0.0015        aq pm10 dep  <NA>
#      ---                                                                                      
# 5999996: 400000 Liquidambar styraciflua    Sweetgum  40        0.0000    co2 sequestered   kgs
# 5999997: 400000 Liquidambar styraciflua    Sweetgum  40     5509.8000        co2 storage   kgs
# 5999998: 400000 Liquidambar styraciflua    Sweetgum  40      219.0000        electricity   kwh
# 5999999: 400000 Liquidambar styraciflua    Sweetgum  40        4.1400 hydro interception   m^3
# 6000000: 400000 Liquidambar styraciflua    Sweetgum  40      -39.5000        natural gas kbtus
```

### eco_interp.R

This function is nested in `eco_run.R`. It interpolates benefit values (always) and will eventually interpolate values only when necessary. The following equation is used:

<p align="center"><a href="http://www.codecogs.com/eqnedit.php?latex=y&space;=&space;\frac{(x&space;-&space;x1)(y2&space;-&space;y1)}{x2&space;-&space;x1}&space;&plus;&space;y1" target="_blank"><img src="http://latex.codecogs.com/svg.latex?y&space;=&space;\frac{(x&space;-&space;x1)(y2&space;-&space;y1)}{x2&space;-&space;x1}&space;&plus;&space;y1" title="y = \frac{(x - x1)(y2 - y1)}{x2 - x1} + y1" /></a></p>

### eco_guess.R

This function guesses the user input for the `species` argument when a match isn't found. For example, "comon fig" will be interpreted as "common fig":

```r
eco_run("comon fig", 20, "InlEmpCLM")

# Species given: [comon fig]
# Closest match: [common fig]
# ...
# Using closest match
#    scientific_name common_name dbh benefit_value            benefit  unit
# 1     Ficus carica  Common fig  20        0.1102     aq nox avoided  <NA>
# 2     Ficus carica  Common fig  20        0.1190         aq nox dep  <NA>
# 3     Ficus carica  Common fig  20        0.3500       aq ozone dep  <NA>
# 4     Ficus carica  Common fig  20        0.0273    aq pm10 avoided  <NA>
# 5     Ficus carica  Common fig  20        0.1850        aq pm10 dep  <NA>
# 6     Ficus carica  Common fig  20        0.2183     aq sox avoided  <NA>
# 7     Ficus carica  Common fig  20        0.0160         aq sox dep  <NA>
# 8     Ficus carica  Common fig  20        0.0273     aq voc avoided  <NA>
# 9     Ficus carica  Common fig  20        0.0000               bvoc  <NA>
# 10    Ficus carica  Common fig  20       55.7000        co2 avoided   kgs
# 11    Ficus carica  Common fig  20        4.1000    co2 sequestered   kgs
# 12    Ficus carica  Common fig  20      569.6000        co2 storage   kgs
# 13    Ficus carica  Common fig  20      189.2000        electricity   kwh
# 14    Ficus carica  Common fig  20        3.1600 hydro interception   m^3
# 15    Ficus carica  Common fig  20      -81.4000        natural gas kbtus
```

### string_dist.R

This function calculates the similarity of two strings and allows `eco_guess.R` to do it's thing.

### eco_demo.R

This is just a demo function that executes:

```r
eco_run(species = "FICA", dbh = 20, region = "InlEmpCLM")
```

## Future plans

* An Imperial/Metric arugment to display units differently depending on what the user wants.
* Better documentation, a vignette
* Add monetary values to benefits
* Suppress messages option
