
module python3

    use iso_c_binding

    interface

        subroutine py_initialize() &
            bind(C, name="Py_Initialize")
        end subroutine py_initialize

        subroutine py_finalize() &
            bind(C, name="Py_Finalize")
        end subroutine py_finalize

        subroutine pysys_setargv(argc, argv) &
            bind(C, name="PySys_SetArgv")
            import c_int, c_ptr
            integer(c_int),value   :: argc
            type(c_ptr),intent(in) :: argv(*)
        end subroutine pysys_setargv

        subroutine pysys_setargvex(argc, argv, updatepath) &
            bind(C, name="PySys_SetArgvEx")
            import c_int, c_ptr
            integer(c_int),value   :: argc
            type(c_ptr),intent(in) :: argv(*)
            integer(c_int),value   :: updatepath
        end subroutine pysys_setargvex

        type(c_ptr) function py_decodelocale(arg, size) &
            bind(C, name="Py_DecodeLocale")
            import c_ptr, c_size_t
            type(c_ptr),value             :: arg
            integer(c_size_t),intent(out) :: size
        end function py_decodelocale

        type(c_ptr) function pymem_rawmalloc(n) &
            bind(C, name="PyMem_RawMalloc")
            import c_ptr, c_size_t
            integer(c_size_t),value :: n
        end function pymem_rawmalloc

        subroutine pymem_rawfree(p) &
            bind(C, name="PyMem_RawFree")
            import c_ptr
            type(c_ptr),value :: p
        end subroutine pymem_rawfree

        type(c_ptr) function pyerr_occurred() &
            bind(C, name="PyErr_Occurred")
            import c_ptr
        end function pyerr_occurred

        subroutine pyerr_print() &
            bind(C, name="PyErr_Print")
        end subroutine pyerr_print

    end interface

contains

    subroutine check_python_error()
        type(c_ptr) :: error_pyobject
        error_pyobject = pyerr_occurred()
        if ( c_associated(error_pyobject) ) then
            call pyerr_print
            stop 1
        end if
    end subroutine check_python_error
    
end module python3
