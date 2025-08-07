#include <ap_fixed.h>
#include <hls_stream.h>

#include <hls_x_complex.h>

constexpr int WIDTH = 16;
constexpr int CHANNELS = 4;

typedef hls::x_complex<ap_fixed<WIDTH, 1>> complex_t;

template <int N>
struct channels_t {
    complex_t data[N];
};

typedef channels_t<CHANNELS> channels_in_t;
typedef channels_t<CHANNELS - 1> channels_out_t;

void crosscorr(hls::stream<channels_in_t>& in, hls::stream<channels_out_t>& out);