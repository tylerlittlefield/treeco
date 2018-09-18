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
  data = "inventory_data/trees.csv, # Path to csv file
  common_col = "common_name",       # Common field
  botanical_col = "botanical_name", # Botanical field
  dbh_col = "dbh_in",               # DBH column
  region = "InlEmpCLM",             # Tree region
  print_time = TRUE                 # Optional, print the elapsed time
  )

Importing trees.csv...
Gathering species matches...
Gathering interpolation parameters...
Interpolating benefits...
Time difference of 0.3816578 secs
         id           botanical             common dbh benefit_value            benefit unit dollars
    1:    1         Acer rubrum          Red maple  14        0.1314     aq nox avoided   lb    0.50
    2:    1         Acer rubrum          Red maple  14        0.1548         aq nox dep   lb    0.59
    3:    1         Acer rubrum          Red maple  14        0.4736       aq ozone dep   lb    1.82
    4:    1         Acer rubrum          Red maple  14        0.0322    aq pm10 avoided   lb    0.15
    5:    1         Acer rubrum          Red maple  14        0.2487        aq pm10 dep   lb    1.15
   ---                                                                                              
44261: 2951 Celtis occidentalis Northern hackberry   7       46.8358    co2 sequestered   lb    0.16
44262: 2951 Celtis occidentalis Northern hackberry   7      281.8975        co2 storage   lb    0.94
44263: 2951 Celtis occidentalis Northern hackberry   7       40.9333        electricity  kwh    8.25
44264: 2951 Celtis occidentalis Northern hackberry   7      127.9649 hydro interception  gal    0.70
44265: 2951 Celtis occidentalis Northern hackberry   7      -25.8430        natural gas   lb    0.17
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

If you are missing a field, you can use `eco_guess` to try and find it:

```r
# Toy data
df <- data.frame(
  botanical_name = c("Ficus carica", NA, "Cedrus deodara ", "Ficus carica")
  )

# Run
treeco::eco_guess(
  data = df,
  have = "botanical_name",
  guess = "common"
  )
  
        original  field_guess
1   ficus carica   Common fig
2 cedrus deodara Deodar cedare
```
