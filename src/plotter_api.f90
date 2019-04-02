
module plotter_api

    use iso_c_binding

    implicit none

    private

    public :: &
        append_plotter_pyinittab, import_plotter_pymodule

    interface

        integer(c_int) function append_plotter_pyinittab() bind(C)
            import c_int
        end function append_plotter_pyinittab

        integer(c_int) function import_plotter_pymodule() bind(C)
            import c_int
        end function import_plotter_pymodule

    end interface

end module plotter_api
