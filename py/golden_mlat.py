import numpy as np
import random

# w.l.o.g. ref mic = (0, 0, 0)

REF = np.array([0, 0, 0])
SENSORS = np.array([[1, 0, 0], [-0.77, -0.77, -0.5], [-0.77, 0.77, 1]])*10
ITERATIONS = 500
EPS = 10

MINIMUM_DISTANCE_LATERAL = 100
CENTER_DISTANCE = 300

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
    darr = [get_rel_dist(REF, src, sens) + random.randrange(-5, 5)/2000.0 for sens in SENSORS]
    res = mlat_sx(np.linalg.inv(SENSORS), [get_dist(REF, sens) for sens in SENSORS], darr)
    
    #assert (res > MINIMUM_DISTANCE_LATERAL).all(axis=0)[2] == False, f"Ooops.. could not determine the result {src} {res}"

    dist = [0, 0]
    
    for i in range(2):
        dist[i] = abs(get_dist(REF, res[i]) - CENTER_DISTANCE)
        if res[i][2] < 0:
            dist[i] = 9999999
        
    if dist[0] < dist[1]:
        pos = res[0]
    else:
        pos = res[1]

    ok = np.linalg.norm(pos-src) < EPS

    if ok == False:
        print("\n\n-- ERROR BIGGER THAN EPS!")
        print(dist)
        print("res")
        print(res)
        print("src")
        print(src)
        print("pos")
        print(pos)


    return (pos, ok)
    
    

def main():
    random.seed(0)
    count_ok = 0;
    for i in range(ITERATIONS):
        (res, ok) = mlat_sx_easy(np.array([random.randrange(a, 400, 1) for a in [-200, -200, MINIMUM_DISTANCE_LATERAL]]))
        if ok:
            count_ok = count_ok + 1
        print(".", end="")
    print("")
    print("Total %d, ok %d, %f%% rate" % (ITERATIONS, count_ok, 100*count_ok/ITERATIONS))


if __name__ == "__main__":
    main()
