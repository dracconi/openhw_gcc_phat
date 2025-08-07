#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <hls_x_complex.h>

constexpr int CHANNELS = 3;

typedef ap_fixed<16, 1> sample_t;
typedef ap_int<16> index_t;

struct channels_t {
    hls::x_complex<sample_t> v[CHANNELS];
};

struct maxima_t {
    index_t v[CHANNELS];
};

typedef hls::axis<channels_t, 0, 0, 0, AXIS_ENABLE_LAST> channels_in_t;
typedef hls::axis<maxima_t, 0, 0, 0, AXIS_DISABLE_ALL> maxima_out_t;

void findmax(hls::stream<channels_in_t>& stream_in, hls::stream<maxima_out_t>& stream_out);