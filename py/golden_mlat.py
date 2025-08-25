import numpy as np
import random

# w.l.o.g. ref mic = (0, 0, 0)

REF = np.array([0, 0, 0])
SENSORS = np.array([[1, 0, 0], [-0.77, -0.77, -2], [-0.77, 0.77, 1]])
ITERATIONS = 100
EPS = 10

MINIMUM_DISTANCE_LATERAL = 100

def get_rel_dist(ref, source, sensor):
    nref = np.linalg.norm(source-ref)
    nsens = np.linalg.norm(source-sensor)
    return nsens - nref

def get_dist(ref, to):
    return np.linalg.norm(to-ref)


def mlat_sx(minv, rmics, darr):
    """Perform MLAT based on Schau&Robinson 1987 paper

    minv = inverse of matrix M
    rmics = array of absolute distances to sensors from origin
    darr = array of TDOAs"""
    assert len(darr) == len(rmics)
    delta = np.zeros((len(darr), 1))
    for i in range(len(darr)):
        delta[i] = rmics[i] ** 2 - darr[i] ** 2
    d = np.transpose(np.array([darr]))
    # @ is matmul ;)
    # and .T is the transposed version
    a = 4 * (1 - d.T @ minv.T @ minv @ d)
    b = 2 * (d.T @ minv.T @ minv @ delta + delta.T @ minv.T @ minv @ d)
    c = -(delta.T @ minv.T @ minv @ delta)
    discr = np.sqrt(b**2 - 4*a*c)
    rs = ((discr * np.array([1, -1]) - b) / (2 * a)).ravel()
    x = np.zeros((len(rs), 3))
    for i in range(len(rs)):
        x[i] = np.transpose(1/2 * minv @ (delta - 2 * rs[i] * d))
    return x
    

def mlat_sx_easy(src):
    darr = [get_rel_dist(REF, src, sens) for sens in SENSORS]
    res = mlat_sx(np.linalg.inv(SENSORS), [get_dist(REF, sens) for sens in SENSORS], darr)
    
    assert (res > MINIMUM_DISTANCE_LATERAL).all(axis=0)[2] == False, "Ooops.. could not determine the result"
    
    if res[0][2] > MINIMUM_DISTANCE_LATERAL:
        pos = res[0]
    else:
        pos = res[1]

    if (pos - src < EPS).all() == False:
        print(res)
        print(src)
        print(pos)


    return pos
    
    

def main():
    random.seed(0)
    for i in range(ITERATIONS):
        res = mlat_sx_easy(np.array([random.randrange(a, 400, 1) for a in [-200, -200, MINIMUM_DISTANCE_LATERAL]]))
        print(".", end="")
    print("")


if __name__ == "__main__":
    main()
