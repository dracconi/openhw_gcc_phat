import numpy as np

DELAYS = [10, 40, 200, 210, 400, 410, 500]

def get_samples(base, offset=0, initial=1024, sz=1024):
    start = initial - offset;
    return base[start:start+sz]

if __name__=="__main__":
    data = np.fromfile("samples.pcm", dtype=np.float64)
    ref = get_samples(data, 0)
    data.tofile("pcm/golden_ref.pcm")
    for delay_ref in DELAYS:
        test = get_samples(data, delay_ref)
        f_ref = np.fft.fft(ref)
        f_test = np.fft.fft(test)
        f_renorm = np.conjugate(f_ref) * f_test
        f_renorm = f_renorm / abs(f_renorm)
        renorm = np.real(np.fft.ifft(f_renorm))
        delay = np.nonzero(max(renorm) == renorm)[0][0]
        print("Ok. ref=%d out=%d" % (delay_ref, delay))
        test.tofile("pcm/golden_%d.pcm" % (delay))
