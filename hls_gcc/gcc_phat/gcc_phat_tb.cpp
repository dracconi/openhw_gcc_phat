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
  const int v = fread(base, sizeof(sample), NFFT, fp);
  fclose(fp);
  return v;
}

int main() {
  printf("* Testbench gccphat\r\n");

  hls::stream<in_frame> stream_in;
  hls::stream<out_frame> stream_out;

  gcc_phat(stream_in, stream_out);

  load_fn("pcm/golden_ref.pcm", &data[0][0]);
  load_fn("pcm/golden_0.pcm", &data[1][0]);
  load_fn("pcm/golden_10.pcm", &data[2][0]);
  load_fn("pcm/golden_210.pcm", &data[3][0]);


  FILE* fp = fopen("golden_fp.pcm", "w");
  
  for (int i = 0; i < NFFT; i++) {
    in_frame t;

    unsigned char b[8];

    for (int j = 0; j < CHANNELS; j++) {
      double candidate = 0.0;

      candidate = data[j][i];
      ap_fixed<16, 1> tmp = data[j][i];


      b[2*(CHANNELS-j-1)+0] = (tmp.V.VAL >> 8) & 0xff;
      b[2*(CHANNELS-j-1)+1] = tmp.V.VAL & 0xff;
      

      t.data.sample[j] = candidate;
    }

    
    fwrite(&b, 1, 8, fp);

    stream_in.write(t);
  }

  out_frame t = stream_out.read();

  ap_fixed<16,1> ff;

  for (int j = 0; j < DELAYS; j++) {
    printf("delay%d=%d\r\n", j, (int)t.data.delays[j]);
  }

  fclose(fp);

  printf("first sample 1st channel %f %f\r\n", data[1][0],
         (double)(0x1ae3) / (pow(2, 15)));
  
  return 0;
}
