#include "gcc_phat.h"

#include <hls_fft.h>
#include <hls_math.h>
#include <hls_task.h>

#include <complex>

#include <stdio.h>

struct fft_params : hls::ip_fft::params_t {
  static const unsigned input_width = 32;
  static const unsigned output_width = 32;
  static const unsigned status_width = 8;
  static const unsigned config_width = 8;
  static const unsigned max_nfft = 10;

  static const bool has_nfft = false;
  static const unsigned channels = 1;
  static const unsigned arch_opt = hls::ip_fft::pipelined_streaming_io;
  static const unsigned phase_factor_width = 25;
  static const unsigned ordering_opt = hls::ip_fft::natural_order;
  static const bool ovflo = false;
  static const unsigned scaling_opt = hls::ip_fft::block_floating_point;
  static const unsigned rounding_opt = hls::ip_fft::convergent_rounding;
  static const unsigned mem_data = hls::ip_fft::block_ram;
  static const unsigned mem_phase_factors = hls::ip_fft::block_ram;
  static const unsigned mem_reorder = hls::ip_fft::block_ram;
  static const unsigned stages_block_ram = (max_nfft < 10) ? 0 : (max_nfft - 9);
  static const bool mem_hybrid = false;
  static const unsigned complex_mult_type = hls::ip_fft::use_mults_resources;
  static const unsigned butterfly_type = hls::ip_fft::use_luts;
  static const unsigned super_sample_rate = hls::ip_fft::ssr_1;
  static const bool use_native_float = false;
};

using fft_config = hls::ip_fft::config_t<fft_params>;
using fft_status = hls::ip_fft::status_t<fft_params>;
using fft_in = std::complex<ap_fixed<32, 1>>;
using fft_out = std::complex<ap_fixed<32, 1>>;

fft_in mult_and_normalize(fft_out ref, fft_out test) {
  std::complex<float> f_ref(ref.real(), ref.imag());
  std::complex<float> f_test(test.real(), test.imag());
  
  std::complex<float> mul = f_test * std::conj(f_ref);

  float abs = hls::sqrt(mul.real() * mul.real() + mul.imag() * mul.imag());

#ifndef __SYNTHESIS__
  printf("mult: %f %fi ", float(mul.real()), float(mul.imag()));
  printf("abs: %f\r\n", float(abs));
#endif
  
  if (abs == 0.0f)
    return fft_in(0);
    
  return fft_in(mul.real() / abs, mul.imag() / abs);
}

void load(in_sample src[NFFT], hls::stream<fft_in>& dst) {
  for (int i = 0; i < NFFT; i++) {
    dst.write(fft_in(float(src[i])));
  }
}

void save(hls::stream<fft_out>& src, fft_out* ref) {
  #pragma HLS INLINE
  for (int i = 0; i < NFFT; i++) {
    ref[i] = src.read();
  }
}

void load_config(bool dir, hls::stream<fft_config>& stream) {
  fft_config config = {};

  config.setDir(dir);

  stream.write(config);
}

void load_output(hls::stream<out_frame>& out) {
  out_frame frame = {};
  frame.data.delays[0] = 1;
  out.write(frame);
}

template <typename T>
void consume(hls::stream<T>& stream) {
  while (!stream.empty()) {
    stream.read();
  }
}

void mult_streams(hls::stream<fft_out>& in, fft_out ref[NFFT],
             hls::stream<fft_in>& out) {
  for (int i = 0; i < NFFT; i++) {
    fft_out test = in.read();
    out.write(mult_and_normalize(ref[i], test));
  }
}

void fft_wrap(hls::stream<fft_in>& in, hls::stream<fft_out>& out,
              hls::stream<fft_status>& status,
              hls::stream<fft_config>& config) {
  hls::fft<fft_params>(in, out, status, config);

  status.read();
}

out_delay find_maximum(hls::stream<fft_out>& in) {
  out_delay index = 0;
  fft_out::value_type maximum = 0;

  for (int i = 0; i < NFFT; i++) {
    fft_out::value_type tmp = in.read().real();
    if (maximum < tmp) {
      maximum = tmp;
      index = i;
      index = (i > NFFT / 2) ? -index : index;
    }
  }

  return index;
}

void run(hls::stream<in_frame>& in, hls::stream<out_frame>& out) {
  in_sample inputs[CHANNELS][NFFT];
  
  fft_out reference[NFFT];

  hls::stream<fft_in, NFFT> fft_stream_in;
  hls::stream<fft_out, NFFT> fft_stream_out;
  hls::stream<fft_config, 2> fft_stream_config;
  hls::stream<fft_status, 2> fft_stream_status;

  for (int i = 0; i < NFFT; i++) {
    in_frame frame = in.read();
    for (int j = 0; j < CHANNELS; j++) {
      inputs[j][i] = frame.data.sample[j];
    }
  }

  load(inputs[0], fft_stream_in);
  load_config(1, fft_stream_config);

  fft_wrap(fft_stream_in, fft_stream_out, fft_stream_status, fft_stream_config);

  save(fft_stream_out, reference);

  out_frame delays;

  for (int i = 0; i < DELAYS; i++) {
    load(inputs[i + 1], fft_stream_in);
    load_config(1, fft_stream_config);

    fft_wrap(fft_stream_in, fft_stream_out, fft_stream_status,
             fft_stream_config);

    mult_streams(fft_stream_out, reference, fft_stream_in);

    load_config(0, fft_stream_config);
    fft_wrap(fft_stream_in, fft_stream_out, fft_stream_status,
             fft_stream_config);

    delays.data.delays[i] = find_maximum(fft_stream_out);
  }

  out.write(delays);
}

void split_wrap(hls::stream<in_frame>& in,
                hls::stream<in_sample> split[CHANNELS]) {
  in_frame frame = in.read();

  for (int i = 0; i < CHANNELS; i++) {
#pragma HLS UNROLL
    split[i].write(frame.data.sample[i]);
  }
}

void gcc_phat(hls::stream<in_frame>& stream_in,
              hls::stream<out_frame>& stream_out) {
#pragma HLS DATAFLOW
#pragma HLS INTERFACE port = return mode = ap_ctrl_none
#pragma HLS INTERFACE port = stream_in mode = axis
#pragma HLS INTERFACE port = stream_out mode = axis

  hls_thread_local hls::task t_run(run, stream_in, stream_out);
}
