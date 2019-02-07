
module python3

    use iso_c_binding

    interface

        subroutine py_initialize() &
            bind(C, name="Py_Initialize")
        end subroutine py_initialize

        subroutine py_finalize() &
            bind(C, name="Py_Finalize")
        end subroutine py_finalize

    end interface

end module python3
