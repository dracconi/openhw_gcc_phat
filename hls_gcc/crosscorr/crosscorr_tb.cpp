#include "crosscorr.h"

#include <complex>
#include <random>

int main()
{
  hls::stream<channels_in_t> stream_in;
  hls::stream<channels_out_t> stream_out;

  double sum = 0.0f;
  constexpr int ITERATIONS = 50;

  for (int i = 0; i < ITERATIONS; i++) {
    std::complex<double> test[CHANNELS];

    channels_in_t in;

    for (int j = 0; j < CHANNELS; j++) {
      test[j] = std::complex<double>((double)std::rand() / RAND_MAX - 0.5, (double)std::rand() / RAND_MAX - 0.5) * 2.0;
      printf("in=%f+i*%f\r\n", test[j].real(), test[j].imag());
      in.data.v[j] = complex_t(test[j]);
    }

    stream_in.write(in);

    crosscorr(stream_in, stream_out);

    channels_out_t out = stream_out.read();

    for (int j = 1; j < CHANNELS; j++) {
      auto t = test[j] * test[0];
      auto d = out.data.v[j - 1];

      std::complex<double> ref = t / std::abs(t) / 4.0;
      //std::complex<double> dat = std::complex<double>(d);

      printf("ref=%f+i*%f, out=%f+i*%f\r\n", ref.real(), ref.imag(), (double)d.real(), (double)d.imag());

      std::complex<double> fp(d.real(), d.imag());
      sum += std::abs(ref - fp) / std::abs(ref);

      if (std::abs(ref - fp) > 0.01 * std::abs(ref)) {
        printf("not ok %f\r\n", std::abs(ref - fp));
        printf("mult %f+i*%f abs %f\r\n", t.real(), t.imag(), std::abs(t));
        return 1;
      }
    }
  }

  printf("* Average error: %f\r\n", sum / ITERATIONS);

  return 0;
}
