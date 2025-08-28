#include <hls_stream.h>
#include <ap_axi_sdata.h>
#include <ap_int.h>

typedef ap_int<16> delay;
struct delays_in {
  delay v[3];
};
typedef hls::axis<delays_in, 0, 0, 0, AXIS_DISABLE_ALL> frame_in;

struct results_out {
  ap_int<16> pos[2][3];
};
typedef hls::axis<results_out, 0, 0, 0, AXIS_DISABLE_ALL> frame_out;

void tdoa_mlat(hls::stream<frame_in>& stream_in, hls::stream<frame_out>& stream_out);
