import numpy as np

# w.l.o.g. ref mic = (0, 0, 0)

REF = np.array([0, 0, 0])
SENSORS = np.array([[1, 0, 0], [-0.77, -0.77, -2], [-0.77, 0.77, 1]])
SOURCE = np.array([1, 2, 5])

def get_rel_dist(ref, source, sensor):
#    print(ref)
#    print(source)
#    print(sensor)
    nref = np.linalg.norm(source-ref)
    nsens = np.linalg.norm(source-sensor)
#    print("to ref: %f, to sensor: %f" % (nref, nsens))
    return nsens - nref

def get_dist(ref, to):
    return np.linalg.norm(to-ref)

def main():
    tr = np.transpose
    mm = np.matmul
    rsideal = get_dist(REF, SOURCE)
    print("proper rs:", rsideal)
    d = tr(np.array([[get_rel_dist(REF, SOURCE, sens) for sens in SENSORS]]))
    delta = tr(np.array([[get_dist(REF, sens)**2 - get_rel_dist(REF, SOURCE, sens)**2 for sens in SENSORS]]))
    print(d)
    print(delta)
    sinv = np.linalg.inv(SENSORS)
    xideal = 1/2 * mm(sinv, (delta-2*rsideal*d))
    print(xideal)
    print(np.sqrt(np.dot(SOURCE, SOURCE)))
    print("---")
    a = 4*(1 - d.T @ sinv.T @ sinv @ d)
    print(a)
    b = 2*(d.T @ sinv.T @ sinv @ delta + delta.T @ sinv.T @ sinv @ d)
    print(b)
    c = -(delta.T @ sinv.T @ sinv @ delta)
    print(c)
    inter = np.sqrt(b**2 - 4 * a * c)
    rs1 = (-b - inter) / (2*a)
    rs2 = (-b + inter) / (2*a)
    print("Results:")
    print(rs1, rs2)


if __name__ == "__main__":
    main()
