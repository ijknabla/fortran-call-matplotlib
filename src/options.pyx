
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

parser.add_argument('-o', '--output', default='') # output file path

args = parser.parse_args()

cdef public struct numeric_options_t:
    int    verbose
    int    resolution[2]
    double top[2]
    double bottom[2]

cdef public api int get_numeric_options(
    numeric_options_t* opts
) except -1:

    global args
    
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

cdef public api int get_output_path_length(
    int * output_path_length
) except -1:

    encoded_output_path = str(args.output).encode("utf-8")

    output_path_length[0] = len(encoded_output_path)
    
    return 0

cdef public api int get_output_path(
    int length, unsigned char* output_path
) except -1:

    encoded_output_path = str(args.output).encode()

    assert len(encoded_output_path) == length

    for i, c in enumerate(encoded_output_path):
        output_path[i] = c
    
    return 0
