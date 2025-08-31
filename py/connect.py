import numpy as np
import serial
from golden_gcc import get_samples, gccphat
import struct
import random
import time

GOLDEN="samples.pcm"
WINDOW = 1024 * 4 * 16
ITERATIONS=5

with serial.Serial("/dev/ttyUSB1", 3000000, timeout=1) as ser:
    data = np.fromfile(GOLDEN, dtype=np.float64)
    bad = 0
    with open(GOLDEN,"rb") as f:
        for k in range(ITERATIONS):
            print(".", end="")
            #print("Setup:")
            initial = random.randrange(1024, 2048)
            delays = [random.randrange(0, 500) for _ in range(1, 4)]
            delays = [0] + delays
            #print(initial, delays)
            streams = [get_samples(data, delay, initial)+random.random()/10 for delay in delays]
            for i in range(1024):
                for j in range(4):
                    ser.write(struct.pack('h', int(streams[j][i] * (2**16))))
                if i == 1022:
                    ser.flush()
            start = time.time()
            res = ser.read(6)
            stop = time.time()
            res0 = list(struct.unpack('hhh', res))
            ok = True
            for i in range(3):
                gold = int(gccphat(streams[0], streams[1+i]))
                if (res0[i] != gold and gold == delays[i + 1]):
                    ok = False
                    print("\n---")
                    print("oops", i, delays, res0, gold, delays)
                    print("---")
            if not ok:
                bad = bad + 1
            #print("Result", res0)
            #print("Golden", [int(gccphat(streams[0], streams[j])) for j in range(1, 4)])
            cpu = time.time()
            #print("fast %fs slow %fs" % (stop - start, cpu - stop))
    print("\nok %d out of %d, %f%%" % (ITERATIONS-bad, ITERATIONS, 100-100*bad/ITERATIONS))
