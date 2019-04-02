
module plotter

    use iso_c_binding
    use python3

    use plotter_api, only : &
        append_plotter_pyinittab, import_plotter_pymodule

    implicit none

    interface

        integer(c_int) function draw_cython( &
            output_path, extent, shape, convergence) &
            bind(C, name="draw")
            import c_ptr, c_double, c_int
            type(c_ptr)   ,value      :: output_path
            real(c_double),intent(in) :: extent(4)
            integer(c_int),intent(in) :: shape(2)
            integer(c_int),intent(in) :: convergence(:,:)
        end function draw_cython

    end interface

contains

    subroutine draw(output_path, extent, convergence)
        character(*,c_char),intent(in) :: output_path
        real(c_double),intent(in)      :: extent(4)
        integer(c_int),intent(in)      :: convergence(:,:)

        call impl(output_path // C_NULL_CHAR )

    contains

        subroutine impl(null_terminated)
            character(*,c_char),target,intent(in) :: null_terminated
            integer returncode
            returncode = draw_cython( &
                c_loc(null_terminated), &
                extent, shape(convergence), convergence)
            if( returncode /= 0) then
                call check_python_error
            end if
        end subroutine impl

    end subroutine draw

end module plotter
