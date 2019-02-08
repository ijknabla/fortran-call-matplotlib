
from matplotlib import pyplot as plt

import ctypes
import numpy as np

c_int_p = ctypes.POINTER(ctypes.c_int)

cdef public int draw(int fshape[2], int fconvergence[]) except -1:

    cdef int[2] cshape = (fshape[1], fshape[0])

    ctypes_ptr = c_int_p.from_address(<long> fconvergence)

    convergence = np.ctypeslib.as_array(ctypes_ptr, cshape)

    plt.imshow(convergence[::-1,:])
    plt.colorbar()
    plt.show()

    return 0
