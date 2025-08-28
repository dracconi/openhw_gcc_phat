#include "tdoa_mlat.h"

#include <hls_task.h>
#include <hls_math.h>

typedef float el;

constexpr int DIM = 3;

el mul(el l, el r) { return l * r; }

// do 3x3 * 3x1 or 3x3' * 3x1
void mulmv(const el left[DIM][DIM], bool left_transpose,
          const el right[DIM],
          el (&result)[DIM]) {
  for (int i = 0; i < DIM; i++) {
    el sum = 0;
    for (int k = 0; k < DIM; k++) {
      el a_val = left_transpose ? left[k][i] : left[i][k];  // transpozycja
      sum += mul(a_val, right[k]);
    }
    result[i] = sum;
  }
}

// perform 1x3 * 3x1 = 1x1
el mulvv(const el left[DIM], const el right[DIM]) {
  el sum = 0;
  for (int i = 0; i < DIM; i++) {
    sum += mul(left[i], right[i]);
  }
  return sum;
}

// generated with py/golden_mlat.py
const el M_INV[DIM][DIM] = {{0.1f, 0.0f, 0.0f},
                            {-0.3f, -0.28571429f, -0.14285714f},
                            {0.28f, 0.2f, 0.2f}};

const el R_MICS[DIM] = {10.0f, 11.0905365f, 14.0712473f};

el calculate_a(const el delays[DIM]) {
  el a0[DIM];
  mulmv(M_INV, false, delays, a0);
  el a1[DIM];
  mulmv(M_INV, true, a0, a1);
  return 4 * (1 - mulvv(delays, a1));
}

el calculate_b(const el delays[DIM], const el delta[DIM]) { return 0; }

el calculate_c(const el delta[DIM]) {
  return 0;
}


void run(hls::stream<frame_in>& in, hls::stream<frame_out>& out) {
  frame_in frame = in.read();

  el delays[DIM];
  for (int i = 0; i < DIM; i++) {
    #pragma HLS UNROLL
    delays[i] = frame.data.v[i];
  }

  el delta[DIM];
  for (int i = 0; i < DIM; i++) {
    delta[i] = R_MICS[i]*R_MICS[i] - delays[i]*delays[i];
  }
  
  //--------------
  el a = calculate_a(delays);
  el b = calculate_b(delays, delta);
  el c = calculate_c(delta);

  el root = hls::sqrt(b * b - 4 * a * c);

  if (root < 0)
    root = 0;
  
  el rs[2];
  rs[0] = (-b + root) / (2 * a);
  rs[1] = (-b - root) / (2 * a);
  
  frame_out result;
  
}

void tdoa_mlat(hls::stream<frame_in>& stream_in,
               hls::stream<frame_out>& stream_out) {
#pragma HLS INTERFACE port = return mode = ap_ctrl_none
#pragma HLS INTERFACE port = stream_in mode = axis
#pragma HLS INTERFACE port = stream_out mode = axis

  hls_thread_local hls::task t_run(run, stream_in, stream_out);
}
