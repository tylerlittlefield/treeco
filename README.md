# treeco [![Travis build status](https://travis-ci.org/tyluRp/treeco.svg?branch=master)](https://travis-ci.org/tyluRp/treeco) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/tyluRp/treeco?branch=master&svg=true)](https://ci.appveyor.com/project/tyluRp/treeco) [![Coverage status](https://codecov.io/gh/tyluRp/treeco/branch/master/graph/badge.svg)](https://codecov.io/github/tyluRp/treeco?branch=master) [![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) <img src="inst/figures/treeco.png" align="right" width=150/>

The goal of `treeco` is to provide R users a tool for calculating the eco benefits of trees. All data used to calculate benefits is ripped from [OpenStreetMaps ecoservice repository](https://github.com/OpenTreeMap/otm-ecoservice) which was (probably) ripped from [i-Tree](https://www.itreetools.org/)'s Eco or Streets software. The output returned is "[tidy](https://www.jstatsoft.org/article/view/v059i10)" and as a result, 1 record is represented by 15 rows as there are 15 benefits calculated for every tree. Since tree inventories can be rather large, `treeco` utilizes the [`data.table`](https://github.com/Rdatatable/data.table) package for speed. All calculations are done on unique species/dbh pairs to avoid redundant computation. 

## Installation

`treeco` isn't available on CRAN but you can install it directly from github using [`devtools`](https://github.com/r-lib/devtools):

```r
# install.packages("devtools")
devtools::install_github("tylurp/treeco")
```

## A reproducible example:

We can use the [`trees`](https://stat.ethz.ch/R-manual/R-patched/library/datasets/html/trees.html) dataset to demonstrate how `eco_guess` and `eco_run_all` works:

```r
library(dplyr)
library(treeco)

df_trees <- trees %>% 
  mutate(common_name = "Black cherry") %>% 
  select(common_name, Girth) %>% 
  mutate(botanical_name = eco_guess(.$common_name, "botanical"))

eco_run_all(
  data = df_trees, 
  common_col = "common_name", 
  botanical_col = "botanical_name", 
  dbh_col = "Girth", 
  region = "PiedmtCLT"
  )
```

Returns:

```r
     id       botanical       common  dbh benefit_value            benefit unit dollars
  1:  1 Prunus serotina Black cherry  8.3        0.0776     aq nox avoided   lb    0.51
  2:  1 Prunus serotina Black cherry  8.3        0.0260         aq nox dep   lb    0.17
  3:  1 Prunus serotina Black cherry  8.3        0.0556       aq ozone dep   lb    0.36
  4:  1 Prunus serotina Black cherry  8.3        0.0150    aq pm10 avoided   lb    0.04
  5:  1 Prunus serotina Black cherry  8.3        0.0633        aq pm10 dep   lb    0.16
 ---                                                                                   
461: 31 Prunus serotina Black cherry 20.6      606.2412    co2 sequestered   lb    4.55
462: 31 Prunus serotina Black cherry 20.6     7909.7504        co2 storage   lb   59.32
463: 31 Prunus serotina Black cherry 20.6      144.7267        electricity  kwh   10.98
464: 31 Prunus serotina Black cherry 20.6     5476.4716 hydro interception  gal   54.22
465: 31 Prunus serotina Black cherry 20.6     1194.6395        natural gas   lb   12.50
```

## More examples:

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

One issue with eco benefits is that they all rely on i-Tree's `master_species_list` which is a list of 3,000+ species, therefore a users data needs to fit this list in order to extract benefits. For example, "Fig tree" doesn't match i-Tree's "Common fig". So far, there really isn't a great solution to this. For now, `treeco` guesses the species code on the fly by quantifying the "similarity", anything below 90% similar is immediately discarded.

For example, if we misspell "Common fig" as "Commn fig":

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
