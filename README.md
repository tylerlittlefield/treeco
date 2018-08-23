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
  data = data/50000_trees.csv, # data directory
  species_col = "common_name", # name of my common name field
  dbh_col = "dbh_val",         # name of my dbh field
  region = "InlEmpCLM"         # region
)

# Importing: 50000_trees.csv...
# 50000_trees.csv imported.
# Reconfiguring data...
# Data reconfigured.
# Guessing species codes...
# Species codes gathered.
# Linking species codes to the data...
# Note: Cannot guess 10118 trees, similarity score below 90%
# Species codes linked.
# Calculating benefits for 39882 trees...
# Complete.
# Time difference of 13.54323 secs
# 
#            id scientific_name common_name dbh benefit_value            benefit  unit dollars
#      1:     4 Punica granatum pomegranate  72        0.2429     aq nox avoided   lbs    0.93
#      2:     4 Punica granatum pomegranate  72        0.2623         aq nox dep   lbs    1.01
#      3:     4 Punica granatum pomegranate  72        0.7716       aq ozone dep   lbs    2.96
#      4:     4 Punica granatum pomegranate  72        0.0602    aq pm10 avoided   lbs    0.28
#      5:     4 Punica granatum pomegranate  72        0.4079        aq pm10 dep   lbs    1.89
#     ---                                                                                     
# 598226: 50000 Maytenus boaria      mayten  20      141.4632    co2 sequestered   lbs    0.47
# 598227: 50000 Maytenus boaria      mayten  20     3203.2026        co2 storage   lbs   10.70
# 598228: 50000 Maytenus boaria      mayten  20      184.9333        electricity   kwh   37.26
# 598229: 50000 Maytenus boaria      mayten  20     3856.9120 hydro interception  gals   21.21
# 598230: 50000 Maytenus boaria      mayten  20      -66.0167        natural gas kbtus    0.44
```

Use `eco_run` to calculate benefits for a single tree:

```r
library(treeco)
eco_run("common fig", 20, "InlEmpCLM")

#    scientific_name common_name dbh benefit_value            benefit  unit
# 1     Ficus carica  Common fig  20        0.1102     aq nox avoided   kgs
# 2     Ficus carica  Common fig  20        0.1190         aq nox dep   kgs
# 3     Ficus carica  Common fig  20        0.3500       aq ozone dep   kgs
# 4     Ficus carica  Common fig  20        0.0273    aq pm10 avoided   kgs
# 5     Ficus carica  Common fig  20        0.1850        aq pm10 dep   kgs
# 6     Ficus carica  Common fig  20        0.2183     aq sox avoided   kgs
# 7     Ficus carica  Common fig  20        0.0160         aq sox dep   kgs
# 8     Ficus carica  Common fig  20        0.0273     aq voc avoided   kgs
# 9     Ficus carica  Common fig  20        0.0000               bvoc   kgs
# 10    Ficus carica  Common fig  20       55.7000        co2 avoided   kgs
# 11    Ficus carica  Common fig  20        4.1000    co2 sequestered   kgs
# 12    Ficus carica  Common fig  20      569.6000        co2 storage   kgs
# 13    Ficus carica  Common fig  20      189.2000        electricity   kwh
# 14    Ficus carica  Common fig  20        3.1600 hydro interception   m^3
# 15    Ficus carica  Common fig  20      -81.4000        natural gas kbtus
```
