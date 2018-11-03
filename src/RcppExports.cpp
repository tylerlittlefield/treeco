// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// cpp_capitalize
std::vector<std::string> cpp_capitalize(std::vector<std::string> strings);
RcppExport SEXP _treeco_cpp_capitalize(SEXP stringsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector<std::string> >::type strings(stringsSEXP);
    rcpp_result_gen = Rcpp::wrap(cpp_capitalize(strings));
    return rcpp_result_gen;
END_RCPP
}
// cpp_trimws
CharacterVector cpp_trimws(CharacterVector x, const char* which);
RcppExport SEXP _treeco_cpp_trimws(SEXP xSEXP, SEXP whichSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< CharacterVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< const char* >::type which(whichSEXP);
    rcpp_result_gen = Rcpp::wrap(cpp_trimws(x, which));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_treeco_cpp_capitalize", (DL_FUNC) &_treeco_cpp_capitalize, 1},
    {"_treeco_cpp_trimws", (DL_FUNC) &_treeco_cpp_trimws, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_treeco(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}