#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
std::vector<std::string> cpp_capitalize(std::vector<std::string> strings) {

  int len = strings.size();

  for( int i=0; i < len; i++ ) {
    std::transform(strings[i].begin(), strings[i].end(), strings[i].begin(), ::tolower);
    strings[i][0] = toupper( strings[i][0] );
  }

  return strings;

}


// See: https://stackoverflow.com/questions/23712366/
// The R code will be automatically run after the compilation.
//

/*** R
cpp_capitalize("hello world")
*/
