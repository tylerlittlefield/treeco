#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
CharacterVector cpp_trimws(CharacterVector x, const char* which = "both") {
  return trimws(x, which);
}

// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically
// run after the compilation.
//

/*** R
cpp_trimws("  x y z \t \n \r   ")
# [1] "x y z"

cpp_trimws("  x y z \t \n \r   ", "left")
# [1] "x y z \t \n \r   "

cpp_trimws("  x y z \t \n \r   ", "right")
# [1] "  x y z"
*/
