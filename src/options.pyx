
import argparse

def PositiveInteger(arg):
    result = int(arg)
    if not 0 < result:
        raise ValueError(f"argument must be positive got {arg!r}")
    return result

def ComplexAsTuple(arg):
    def to_complex(arg):
        try:
            return complex(arg)
        except ValueError:
            return complex(*eval(arg))

    try:
        complexValue = to_complex(arg)
        return complexValue.real, complexValue.imag
    except ValueError as originalError:
        message = (
            "argumant must be complex or Tuple[float, float] got {arg!r}"
        )
        raise ValueError(message) from originalError
    

parser = argparse.ArgumentParser()
parser.add_argument("--resolution", metavar="N", help="output figure resolution",
                    type=PositiveInteger, nargs=2, default=[1024, 1024])

parser.add_argument("--bottom", type=ComplexAsTuple, default=(-2.0, -1.5))
parser.add_argument("--top"   , type=ComplexAsTuple, default=(+1.0, +1.5))

parser.add_argument('-v', '--verbose', help='increase verbosity', action='count', default=0)

cdef public struct options_t:
    int    verbose
    int    resolution[2]
    double top[2]
    double bottom[2]
    
cdef public int parse_args(
    options_t* opts
) except -1:

    args = parser.parse_args()
    
    opts.resolution = args.resolution
    opts.top        = args.top
    opts.bottom     = args.bottom

    from logging import getLogger, StreamHandler, DEBUG, INFO

    opts.verbose    = args.verbose
    
    rootLogger = getLogger()
    if args.verbose == 1:
        rootLogger.setLevel(INFO)
    if args.verbose >= 2:
        rootLogger.setLevel(DEBUG)

    handler    = StreamHandler()
    rootLogger.addHandler(handler)

    return 0
