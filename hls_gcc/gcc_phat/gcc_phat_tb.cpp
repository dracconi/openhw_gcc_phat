#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <cstdlib>
#include <random>

#include "gcc_phat.h"

using sample = double;

sample data[CHANNELS][NFFT];

bool load_fn(const char* fn, sample* base) {
  FILE* fp = fopen(fn, "rb");
  return fread(base, sizeof(sample), NFFT, fp);
  fclose(fp);
}

int main() {
  printf("* Testbench gccphat\r\n");

  hls::stream<in_frame> stream_in;
  hls::stream<out_frame> stream_out;

  gcc_phat(stream_in, stream_out);

  load_fn("pcm/golden_ref.pcm", &data[0][0]);
  load_fn("pcm/golden_200.pcm", &data[1][0]);
  load_fn("pcm/golden_400.pcm", &data[2][0]);
  load_fn("pcm/golden_410.pcm", &data[3][0]);

  for (int i = 0; i < NFFT; i++) {
    in_frame t;

    for (int j = 0; j < CHANNELS; j++) {
      double candidate = 0.0;
        
      candidate = data[j][i];

      t.data.sample[j] = candidate;
    }

    stream_in.write(t);
  }

  out_frame t = stream_out.read();

  for (int j = 0; j < DELAYS; j++) {
    printf("delay%d=%d\r\n", j, (int)t.data.delays[j]);
  }

  return 0;
}
