#include "crosscorr.h"
#include <hls_math.h>
#include <hls_x_complex.h>

typedef hls::x_complex<ap_fixed<32, 8>> int_complex_t;

int_complex_t cabs(complex_t a) {
  return int_complex_t(hls::sqrt(a.real()*a.real() + a.imag()*a.imag()));
}

void crosscorr(hls::stream<channels_in_t>& stream_in, hls::stream<channels_out_t>& stream_out) {
    #pragma HLS DATAFLOW
    #pragma HLS INTERFACE port=stream_in mode=axis
    #pragma HLS INTERFACE port=stream_out mode=axis

    channels_t<CHANNELS> in = stream_in.read();

    channels_t<CHANNELS - 1> out = {};

    for (int i = 1; i < CHANNELS; i++) {
        int_complex_t tmp = int_complex_t(in.data[i]) * int_complex_t(in.data[0]) / 4;
        int_complex_t comp = cabs(tmp);
        if (comp.real() != int_complex_t(0.0f)) {
            tmp = tmp / comp;
        } else {
            tmp = complex_t(0.0f);
        }
        out.data[i - 1] = tmp / 4;
    }

    stream_out.write(out);
}
