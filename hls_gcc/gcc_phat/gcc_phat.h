#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <hls_stream.h>

constexpr int CHANNELS = 4;
constexpr int DELAYS = CHANNELS - 1;
constexpr int NFFT = 1024;

using in_sample = ap_fixed<16, 1>;

struct in_data {
  in_sample sample[CHANNELS];
};

using out_delay = ap_int<16>;

struct out_data {
  out_delay delays[DELAYS];
};

using in_frame = hls::axis<in_data, 0, 0, 0, AXIS_DISABLE_ALL>;
using out_frame = hls::axis<out_data, 0, 0, 0, AXIS_DISABLE_ALL>;

void gcc_phat(hls::stream<in_frame>& stream_in,
              hls::stream<out_frame>& stream_out);
