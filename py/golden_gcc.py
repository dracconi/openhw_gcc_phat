import numpy as np

DELAYS = [0, 10, 40, 200, 210, 400, 410]

def get_samples(base, offset=0, initial=1024, sz=1024):
    start = initial - offset;
    return base[start:start+sz]

def gccphat(ref, test):
    r = np.fft.fft(ref)
    t = np.fft.fft(test)
    n = np.conjugate(r) * t
    if np.any(abs(n) == 0):
        n = np.zeros_like(n)
    else:
        n = n / abs(n)
    res = np.real(np.fft.ifft(n))
    test = np.nonzero(max(res) == res)
    if len(test[0]) > 0:
        return test[0][0]
    return 0

if __name__=="__main__":
    arrays = []
    data = np.fromfile("samples.pcm", dtype=np.float64)
    ref = get_samples(data, 0)
    ref.tofile("pcm/golden_ref.pcm")
    for delay_ref in DELAYS:
        test = get_samples(data, delay_ref)
        arrays.push(test)
        f_ref = np.fft.fft(ref)
        f_test = np.fft.fft(test)
        f_renorm = np.conjugate(f_ref) * f_test
        if (abs(f_renorm) != 0):
            f_renorm = f_renorm / abs(f_renorm)
        else:
            f_renorm = 0.0
        renorm = np.real(np.fft.ifft(f_renorm))
        delay = np.nonzero(max(renorm) == renorm)[0][0]
        print("Ok. ref=%d out=%d" % (delay_ref, delay))
        test.tofile("pcm/golden_%d.pcm" % (delay))
    
