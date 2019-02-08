
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--resolution", metavar="N", help="output figure resolution",
                    type=int, nargs=2, default=[1024, 1024])

cdef public struct options_t:
    int    resolution[2]
    double top[2]
    double bottom[2]

cdef public void parse_args(
    options_t* opts
):
    args = parser.parse_args()

    for i, reso in enumerate(args.resolution):
        opts.resolution[i] = reso

    opts.top    = (+1.0, +1.5)
    opts.bottom = (-2.0, -1.5)
