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

Importing data...
Cleaning data...
Guessing species codes...
Linking benefits to data...
Calculating eco benefits...
Calculating $ benefits...
Eco benefits complete!
Time difference of 14.26213 secs
             id         scientific_name common_name dbh_val benefit_value            benefit unit dollars
      1:      1           Abies procera   Noble fir       1        0.0053     aq nox avoided   lb    0.02
      2:      1           Abies procera   Noble fir       1        0.0022         aq nox dep   lb    0.01
      3:      1           Abies procera   Noble fir       1        0.0077       aq ozone dep   lb    0.03
      4:      1           Abies procera   Noble fir       1        0.0013    aq pm10 avoided   lb    0.01
      5:      1           Abies procera   Noble fir       1        0.0033        aq pm10 dep   lb    0.02
     ---                                                                                                 
5275061: 400000 Liquidambar styraciflua    Sweetgum      40       86.6416    co2 sequestered   lb    0.29
5275062: 400000 Liquidambar styraciflua    Sweetgum      40    12147.0153        co2 storage   lb   40.57
5275063: 400000 Liquidambar styraciflua    Sweetgum      40      219.0000        electricity  kwh   44.12
5275064: 400000 Liquidambar styraciflua    Sweetgum      40     1093.6723 hydro interception  gal    6.02
5275065: 400000 Liquidambar styraciflua    Sweetgum      40      -87.0825        natural gas   lb    0.58
```

Use `eco_run` to calculate benefits for a single tree:

```r
treeco::eco_run("Common fig", 20, "InlEmpCLM")

    common_name dbh benefit_value            benefit unit dollars
 1:  Common fig  20        0.2429     aq nox avoided   lb    0.93
 2:  Common fig  20        0.2623         aq nox dep   lb    1.01
 3:  Common fig  20        0.7716       aq ozone dep   lb    2.96
 4:  Common fig  20        0.0602    aq pm10 avoided   lb    0.28
 5:  Common fig  20        0.4079        aq pm10 dep   lb    1.89
 6:  Common fig  20        0.4813     aq sox avoided   lb    1.17
 7:  Common fig  20        0.0353         aq sox dep   lb    0.09
 8:  Common fig  20        0.0602     aq voc avoided   lb    0.12
 9:  Common fig  20        0.0000               bvoc   lb    0.00
10:  Common fig  20      122.7973        co2 avoided   lb    0.41
11:  Common fig  20        9.0389    co2 sequestered   lb    0.03
12:  Common fig  20     1255.7516        co2 storage   lb    4.19
13:  Common fig  20      189.2000        electricity  kwh   38.12
14:  Common fig  20      834.7837 hydro interception  gal    4.59
15:  Common fig  20     -179.4561        natural gas   lb    1.20
```

These functions guess the species codes on the fly. For example, if we misspell "Common fig" as "Commn fig":

```r
treeco::eco_run("Commn fig", 20, "InlEmpCLM")

Species given: [commn fig]
Closest match: [common fig]
...
Using closest match
    common_name dbh benefit_value            benefit unit dollars
 1:  Common fig  20        0.2429     aq nox avoided   lb    0.93
 2:  Common fig  20        0.2623         aq nox dep   lb    1.01
 3:  Common fig  20        0.7716       aq ozone dep   lb    2.96
 4:  Common fig  20        0.0602    aq pm10 avoided   lb    0.28
 5:  Common fig  20        0.4079        aq pm10 dep   lb    1.89
 6:  Common fig  20        0.4813     aq sox avoided   lb    1.17
 7:  Common fig  20        0.0353         aq sox dep   lb    0.09
 8:  Common fig  20        0.0602     aq voc avoided   lb    0.12
 9:  Common fig  20        0.0000               bvoc   lb    0.00
10:  Common fig  20      122.7973        co2 avoided   lb    0.41
11:  Common fig  20        9.0389    co2 sequestered   lb    0.03
12:  Common fig  20     1255.7516        co2 storage   lb    4.19
13:  Common fig  20      189.2000        electricity  kwh   38.12
14:  Common fig  20      834.7837 hydro interception  gal    4.59
15:  Common fig  20     -179.4561        natural gas   lb    1.20
```
