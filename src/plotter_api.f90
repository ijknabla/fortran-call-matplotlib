
module plotter_api

    use iso_c_binding

    implicit none

    private

    public :: &
        append_plotter_pyinittab, import_plotter_pymodule, &
        draw

    interface

        integer(c_int) function append_plotter_pyinittab() bind(C)
            import c_int
        end function append_plotter_pyinittab

        integer(c_int) function import_plotter_pymodule() bind(C)
            import c_int
        end function import_plotter_pymodule

        integer(c_int) function draw( &
            output_path, extent, shape, convergence) bind(C)
            import c_ptr, c_double, c_int
            type(c_ptr)   ,value      :: output_path
            real(c_double),intent(in) :: extent(4)
            integer(c_int),intent(in) :: shape(2)
            integer(c_int),intent(in) :: convergence(:,:)
        end function draw

    end interface

end module plotter_api
