
module pylogger_api

    use iso_c_binding, only : c_int, c_ptr

    implicit none

    public

    interface

        integer(c_int) function append_pylogger_pyinittab() bind(C)
            import c_int
        end function append_pylogger_pyinittab

        integer(c_int) function import_pylogger_pymodule() bind(C)
            import c_int
        end function import_pylogger_pymodule

        integer(c_int) function pylogger_log( &
            module_name, level, message) bind(C)
            import c_int, c_ptr
            type(c_ptr)   ,value :: module_name, message
            integer(c_int),value :: level
        end function pylogger_log

    end interface

end module pylogger_api
