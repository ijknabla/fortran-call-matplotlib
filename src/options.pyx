
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
    import sys

    sys.argv = argv_from_callbacks(
        argc_getter,
        arg_len_getter,
        arg_getter,
    )

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

cdef public struct numeric_options_t:
    int    verbose
    int    resolution[2]
    double top[2]
    double bottom[2]

_args = None
def getArgs():
    global _args

    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--resolution", metavar="N", help="output figure resolution",
                        type=PositiveInteger, nargs=2, default=[1024, 1024])

    parser.add_argument("--bottom", type=ComplexAsTuple, default=(-2.0, -1.5))
    parser.add_argument("--top"   , type=ComplexAsTuple, default=(+1.0, +1.5))

    parser.add_argument('-v', '--verbose', help='increase verbosity', action='count', default=0)

    parser.add_argument('-o', '--output', default='') # output file path

    if _args is None:
        _args = parser.parse_args()

    return _args


cdef public api int get_numeric_options(
    numeric_options_t* opts
) except -1:

    args = getArgs()
    
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

    args = getArgs()

    encoded_output_path = str(args.output).encode("utf-8")

    output_path_length[0] = len(encoded_output_path)
    
    return 0

cdef public api int get_output_path(
    int length, unsigned char* output_path
) except -1:

    args = getArgs()

    encoded_output_path = str(args.output).encode()

    assert len(encoded_output_path) == length

    for i, c in enumerate(encoded_output_path):
        output_path[i] = c
    
    return 0

cdef public api int parse_args(
    options_t* opts,
) except -1 :

    args = getArgs()

    output_path     = args.output.encode("utf-8")
    len_output_path = len(output_path)

    opts.verbose         = args.verbose
    opts.resolution[:]   = args.resolution[:]
    opts.top[:]          = args.top[:]
    opts.bottom[:]       = args.bottom[:]

    if opts.output_path != NULL:
        raise RuntimeError(
            f"opts->output_path != NULL"
        )
    
    opts.output_path_len = len_output_path
    opts.output_path = <unsigned char*> PyMem_Malloc(
        sizeof(unsigned char*) * len_output_path )

    for i in range(len_output_path):
        opts.output_path[i] = output_path[i]

cdef public api int finalize_options_t(
    options_t* opts,
) except -1:

    PyMem_Free(opts.output_path)
    opts.output_path = NULL
