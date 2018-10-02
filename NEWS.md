# treeco 0.0.1.9000

* Added `pkgdown` support.
* Fixes bug where `eco_guess` only guessed unique values of `x`, this meant a 
user with duplicates would have issues assigning `x` to a `data.frame` as their lengths would differ.
* Added threshold for guessing in `eco_run_all`, 0.8 is the default value.
* Converted `message` to `warning` in `eco_guess` when `x` vector is coerced from `factor` to `character`.
* Added warnings to `eco_run_all` for cases where `n` > 1 or `n` < 0. If this happens, `n` defaults to 0.8.
* Added tests for warnings where threshold doesn't make sense and where factors converted to character.

# treeco 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
