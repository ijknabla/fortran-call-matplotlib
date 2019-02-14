
from matplotlib import pyplot as plt
from matplotlib import cm     as colormaps

import ctypes
import numpy as np

from logging import getLogger, DEBUG

logger = getLogger(__name__)

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

    image_shape = *convergence.shape, 3
    image = np.ones(image_shape, dtype=np.float)

    # 収束した部分は黒(0,0,0)とする。
    image[convergence <  0] = 0.

    diverged_mask = (convergence >= 0)
    diverged      = convergence[diverged_mask]

    minIteration  = diverged.min()
    maxIteration  = diverged.max()

    def normalize(iteration):
        return (maxIteration - iteration) / (maxIteration - minIteration)
    
    # 発散した部分はcolormapに応じて色をつける。
    colormap = colormaps.gnuplot2
    image[diverged_mask,:3] = (
        colormap(normalize(diverged))[:,:3]
    )


    logger.debug(f"image size {image.shape[:-1]}")
    logger.info("show image")
    
    plt.imshow(
        image,
        origin='lower',
        extent=(
            cbottom.real, ctop.real,
            cbottom.imag, ctop.imag,
        )
    )
    plt.show()

    return 0
