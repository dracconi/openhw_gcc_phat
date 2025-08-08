#include "findmax.h"

#include <cassert>
#include <cstdlib>
#include <random>

constexpr int ITERATIONS = 6400;

int main() {
    hls::stream<channels_in_t> stream_in;
    hls::stream<maxima_out_t> stream_out;

    sample_t max_value[CHANNELS] = {0, 0, 0};
    index_t max_index[CHANNELS] = {0, 0, 0};
    index_t current_index = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        channels_in_t in;

        for (int j = 0; j < CHANNELS; j++) {
            in.data.v[j] = hls::x_complex<sample_t>((double)std::rand() / RAND_MAX, (double)std::rand() / RAND_MAX);
            printf("%d:%f ", j, (double)in.data.v[j].real());
            if (in.data.v[j].real() > max_value[j]) {
                max_value[j] = in.data.v[j].real();
                max_index[j] = current_index;
            }
        }

        printf("\r\n");
        in.set_last(std::rand() > RAND_MAX / 8 * 7 || i == ITERATIONS - 1);

        stream_in.write(in);

        findmax(stream_in, stream_out);

        current_index++;

        if (in.get_last()) {
            printf("Last\r\n");

            maxima_out_t out = stream_out.read();

            for (int j = 0; j < CHANNELS; j++) {
                printf("max ch=%d, ip=%d, ref=%d\r\n", j, (int)out.data.v[j], (int)max_index[j]);
                assert(out.data.v[j] == max_index[j]);

                max_value[j] = 0.0;
                max_index[j] = 0;
            }

            current_index = 0;
        }
    }

    return 0;
}