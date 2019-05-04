
import re
import sys
import argparse
from cpython.mem cimport PyMem_Malloc, PyMem_Free

class CommandArgumentCallbackError(RuntimeError):

    @classmethod
    def check(cls, returncode):
        if returncode != 0:
            raise cls(returncode)

cdef argv_from_callbacks(
    ArgCount_GetterFunc  argc_getter,
    ArgLength_GetterFunc arg_len_getter,
    Argument_GetterFunc  arg_getter,
):

    def get_argument(int iarg):
        cdef int   arg_len
        cdef char* arg = NULL

        CommandArgumentCallbackError.check(
            arg_len_getter(iarg, &arg_len)
        )

        try:
            arg = <char*> PyMem_Malloc(
                sizeof(char*) * arg_len
            )
            CommandArgumentCallbackError.check(
                arg_getter(iarg, arg_len, arg)
            )
            return arg[:arg_len].decode()

        finally:
            PyMem_Free(arg)

    cdef int   argc
    CommandArgumentCallbackError.check(
        argc_getter(&argc) )

    return list(map(get_argument, range(argc+1)))

cdef public api int set_argv_from_callbacks(
    ArgCount_GetterFunc  argc_getter,
    ArgLength_GetterFunc arg_len_getter,
    Argument_GetterFunc  arg_getter,
) except -1:

    sys.argv = argv_from_callbacks(
        argc_getter,
        arg_len_getter,
        arg_getter,
    )

def positiveInteger(arg):
    result = int(arg)
    if not 0 < result:
        raise ValueError(f"argument must be positive got {arg!r}")
    return result

def commandLineFloat(arg):
    REPLACE_TO_MINUS = [
        '_', 'm', 'M'
    ] # -> '-'

    REPLACE_TO_PLUS = [
        'p', 'P'
    ] # -> '+'

    def characters2pattern(chars):
        return "^\s*({})".format('|'.join(chars))

    minusPattern = characters2pattern(REPLACE_TO_MINUS)
    plusPattern  = characters2pattern(REPLACE_TO_PLUS )

    arg = re.sub(minusPattern, '-', arg)
    arg = re.sub(plusPattern , '+', arg)

    return float(arg)



from collections import namedtuple

ComplexPlaneExtentBase = namedtuple(
    "ComplexPlaneExtentBase",
    'realMin, realMax, imagMin, imagMax'
)

class ComplexPlaneExtent(ComplexPlaneExtentBase):
    def __new__(cls, realMin, realMax, imagMin, imagMax):

        if not realMin < realMax:
            raise ValueError(
                f"realMin(= {realMin}) must be larger than realMax(= {realMax})")
        if not imagMin < imagMax:
            raise ValueError(
                f"imagMin(= {imagMin}) must be larger than imagMax(= {imagMax})")

        self = super().__new__(
            cls, realMin, realMax, imagMin, imagMax
        )
        return self

class ComplexPlaneExtentAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        try:
            extent = ComplexPlaneExtent(*values)
        except ValueError as valueError:
            raise argparse.ArgumentError(self, str(valueError))
        setattr(namespace, self.dest, extent)



def getParser():

    parser = argparse.ArgumentParser(
        prog = "mandelbrot",
        description = """\
Draw mandelbrot set""",
        epilog = """\
To avoid confusion with parsing command line arguments, 
you can use 'm' or '_' (underscore) character instead of '-' (minus) 
as first character of negative real.""",
    )

    parser.add_argument(
        "--resolution", metavar=("real", "imag"),
        help="complex plane Resolution (positive integer)",
        type=positiveInteger, nargs=2, default=(1024, 1024)
    )

    parser.add_argument(
        "--extent", metavar = ("realMin","realMax","imagMin","imagMax"),
        help = (
            "complex plane extent (real number)."
        ),
        type=commandLineFloat,
        nargs=4, action=ComplexPlaneExtentAction,
        default=ComplexPlaneExtent(
            realMin=-2.0, realMax=+1.0,
            imagMin=-1.5, imagMax=+1.5
        )
    )

    parser.add_argument(
        '-v', '--verbose', help='increase verbosity',
        action='count', default=0
    )

    parser.add_argument(
        '-o', '--output', default='',
        help = "output file path (s.t. 'mandelbrot.png')"
    )

    return parser

def set_verbosity(verbosity):
    import logging
    rootLogger       = logging.getLogger()
    matplotlibLogger = logging.getLogger("matplotlib")
    handler          = logging.StreamHandler()

    rootLogger.setLevel(logging.DEBUG)
    matplotlibLogger.setLevel(logging.WARNING)
    rootLogger.addHandler(handler)

    if   verbosity <= 0:
        handler.setLevel(logging.WARNING)
    elif verbosity == 1:
        handler.setLevel(logging.INFO   )
    else: # 2 <= verbosity:
        handler.setLevel(logging.DEBUG  )

cdef public api int parse_args(
    options_t* opts,
) except -1 :

    parser = getParser()
    args   = parser.parse_args()

    output_path     = args.output.encode("utf-8")
    len_output_path = len(output_path)

    opts.verbose         = args.verbose
    opts.resolution[:]   = args.resolution[:]
    opts.extent[:]       = args.extent[:]

    if opts.output_path != NULL:
        raise RuntimeError(
            f"opts->output_path != NULL"
        )

    opts.output_path_len = len_output_path
    opts.output_path = <unsigned char*> PyMem_Malloc(
        sizeof(unsigned char*) * len_output_path )

    for i in range(len_output_path):
        opts.output_path[i] = output_path[i]

    set_verbosity(args.verbose)

cdef public api int finalize_options_t(
    options_t* opts,
) except -1:

    PyMem_Free(opts.output_path)
    opts.output_path = NULL
