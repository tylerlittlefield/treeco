# treeco [![Travis build status](https://travis-ci.org/tyluRp/treeco.svg?branch=master)](https://travis-ci.org/tyluRp/treeco) <img src="inst/figures/treeco.png" align="right" width=150/>


Eco benefits in R

## Installation

```r
# install.packages("devtools")
devtools::install_github("tylurp/treeco")
```

## Demo

Use `eco_run_all` to calculate benefits for an entire tree inventory:

```r
treeco::eco_run_all(
  data = "data/trees.csv",     # data directory
  species_col = "common_name", # name of my common name field
  dbh_col = "dbh_val",         # name of my dbh field
  region = "InlEmpCLM"         # region
)

# Importing data...
# Cleaning data...
# Guessing species codes...
# Linking benefits to data...
# Calculating eco benefits...
# Calculating $ benefits...
# Eco benefits complete!
# Time difference of 20.4605 secs
# 
#              id         scientific_name common_name dbh_val benefit_value            benefit unit dollars
#       1:      1           Abies procera   Noble fir       1        0.0053     aq nox avoided   lb    0.02
#       2:      1           Abies procera   Noble fir       1        0.0022         aq nox dep   lb    0.01
#       3:      1           Abies procera   Noble fir       1        0.0077       aq ozone dep   lb    0.03
#       4:      1           Abies procera   Noble fir       1        0.0013    aq pm10 avoided   lb    0.01
#       5:      1           Abies procera   Noble fir       1        0.0033        aq pm10 dep   lb    0.02
#      ---                                                                                                 
# 5275061: 400000 Liquidambar styraciflua    Sweetgum      40        0.0000    co2 sequestered   lb    0.00
# 5275062: 400000 Liquidambar styraciflua    Sweetgum      40    12147.0153        co2 storage   lb   40.57
# 5275063: 400000 Liquidambar styraciflua    Sweetgum      40      219.0000        electricity  kwh   44.12
# 5275064: 400000 Liquidambar styraciflua    Sweetgum      40     1093.6723 hydro interception  gal    6.02
# 5275065: 400000 Liquidambar styraciflua    Sweetgum      40      -87.0825        natural gas   lb    0.58
```

