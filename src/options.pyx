
import argparse

def PositiveInteger(arg):
    result = int(arg)
    if not 0 < result:
        raise ValueError(f"argument must be positive got {arg!r}")
    return result

parser = argparse.ArgumentParser()
parser.add_argument("--resolution", metavar="N", help="output figure resolution",
                    type=PositiveInteger, nargs=2, default=[1024, 1024])

cdef public struct options_t:
    int    resolution[2]
    double top[2]
    double bottom[2]

cdef public void parse_args(
    options_t* opts
):
    args = parser.parse_args()

    opts.resolution = args.resolution
    opts.top        = (+1.0, +1.5)
    opts.bottom     = (-2.0, -1.5)
