
from matplotlib import pyplot as plt

import ctypes
import numpy as np

c_int_p = ctypes.POINTER(ctypes.c_int)

cdef public int draw(
    double top[2], double bottom[2],
    int fshape[2], int fconvergence[]
) except -1:

    cdef int[2] cshape = (fshape[1], fshape[0])

    ctop    = complex(top   [0], top   [1])
    cbottom = complex(bottom[0], bottom[1])
    
    ctypes_ptr = c_int_p.from_address(<long> fconvergence)

    convergence = np.ctypeslib.as_array(ctypes_ptr, cshape)

    plt.imshow(
        convergence,
        origin='lower',
        extent=(
            cbottom.real, ctop.real,
            cbottom.imag, ctop.imag,
        )
    )
    plt.colorbar()
    plt.show()

    return 0
