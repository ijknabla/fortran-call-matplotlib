
import ctypes
import logging

fortran_internal_logger = logging.getLogger("fortran_internal")

def charptr2str(const char* ptr):
    raw_bytes = ctypes.c_char_p(<long> ptr)
    return raw_bytes.value.decode()

cdef public api int pylogger_log(
    const char* module_name,
    const int   level      ,
    const char* message    ,
) except -1:

    u_module_name = charptr2str(module_name)
    u_message     = charptr2str(message    )

    logger = fortran_internal_logger.getChild(u_module_name)
    logger.log(level, u_message)

    return 0
