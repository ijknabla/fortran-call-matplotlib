
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--nr", help="real part resolution",
                    type=int, default=1024)

parser.add_argument("--ni", help="imaginary part resolution",
                    type=int, default=1024)

cdef public struct options_t:
    int    resolution[2]
    double top[2]
    double bottom[2]

cdef public void parse_args(
    options_t* opts
):
    args = parser.parse_args()

    opts.resolution[0] = args.nr
    opts.resolution[1] = args.ni

    opts.top    = (+1.0, +1.5)
    opts.bottom = (-2.0, -1.5)
