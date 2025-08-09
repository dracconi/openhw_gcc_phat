#include "findmax.h"
#include <cstring>
#include <hls_task.h>


void run(hls::stream<channels_in_t>& stream_in, hls::stream<maxima_out_t>& stream_out) {
    static sample_t max_value[CHANNELS] = {0, 0, 0};
    static index_t current_index = 0;

    static maxima_out_t out = {.data = {.v = {0, 0, 0}}};

    channels_in_t in = stream_in.read();

    for (int i = 0; i < CHANNELS; i++) {
        #pragma HLS UNROLL
        if (max_value[i] < in.data.v[i].real()) {
            max_value[i] = in.data.v[i].real();
            out.data.v[i] = current_index;
        }
    }

    current_index++;

    if (in.get_last())
    {
        current_index = 0;
        stream_out.write(out);
        for (int i = 0; i < CHANNELS; i++)
        {
            #pragma HLS UNROLL
            max_value[i] = 0.0;
        }
    }
}


void findmax(hls::stream<channels_in_t>& stream_in, hls::stream<maxima_out_t>& stream_out) {
    #pragma HLS INTERFACE port=return mode=ap_ctrl_none
    #pragma HLS INTERFACE port=stream_in mode=axis
    #pragma HLS INTERFACE port=stream_out mode=axis

    hls_thread_local hls::task trun(run, stream_in, stream_out);
}