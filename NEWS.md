# treeco 0.0.1.9000

* Added `pkgdown` support.
* Fixes bug where `eco_guess` only guessed unique values of `x`, this meant a 
user with duplicates would have issues assigning `x` to a `data.frame` as their lengths would differ.
* Added threshold for guessing in `eco_run_all`, 0.8 is the default value.
* Converted `message` to `warning` in `eco_guess` when `x` vector is coerced from `factor` to `character`.
* Added warnings to `eco_run_all` for cases where `n` > 1 or `n` < 0. If this happens, `n` defaults to 0.8.
* Added tests for warnings where threshold doesn't make sense and where factors converted to character.
* Modified `eco_guess` to make it faster. This function takes a vector, converts it to a `data.table`, and does all the matching on unique values only. Then joins the missing field to the original (non unique) `data.table` and returns a vector containing values for the missing field.
* The utility function `extract_data` now preserves the original rownames as a column `rn` using the `keep.rownames = TRUE` argument in `as.data.table`. This allows users to join additional variables back to the benefits dataframe. Especially important given this type of data is usually spatial. There is still the issue of reading data as the `fread` function isn't preserving rownames. Will come back to that at some point. 
* Added [`Vignettes`](http://r-pkgs.had.co.nz/vignettes.html).
* Added first vignette, getting started article.
* Using RMarkdown to generate README.md
* Added unit parameter for rare cases where user data measures DBH in centimeters instead of inches.

# treeco 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
