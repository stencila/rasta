// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// stream_write_message
bool stream_write_message(std::string message, std::string stream, long offset);
RcppExport SEXP _rasta_stream_write_message(SEXP messageSEXP, SEXP streamSEXP, SEXP offsetSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type message(messageSEXP);
    Rcpp::traits::input_parameter< std::string >::type stream(streamSEXP);
    Rcpp::traits::input_parameter< long >::type offset(offsetSEXP);
    rcpp_result_gen = Rcpp::wrap(stream_write_message(message, stream, offset));
    return rcpp_result_gen;
END_RCPP
}
// stream_read_message
std::string stream_read_message(std::string stream, long offset, bool blocking);
RcppExport SEXP _rasta_stream_read_message(SEXP streamSEXP, SEXP offsetSEXP, SEXP blockingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type stream(streamSEXP);
    Rcpp::traits::input_parameter< long >::type offset(offsetSEXP);
    Rcpp::traits::input_parameter< bool >::type blocking(blockingSEXP);
    rcpp_result_gen = Rcpp::wrap(stream_read_message(stream, offset, blocking));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_rasta_stream_write_message", (DL_FUNC) &_rasta_stream_write_message, 3},
    {"_rasta_stream_read_message", (DL_FUNC) &_rasta_stream_read_message, 3},
    {NULL, NULL, 0}
};

RcppExport void R_init_rasta(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
