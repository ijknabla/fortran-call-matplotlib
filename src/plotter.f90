
module plotter

    use iso_c_binding
    use python3

    implicit none

    interface

        subroutine pyinit_plotter() &
            bind(C, name="PyInit_plotter")
        end subroutine pyinit_plotter

        integer(c_int) function draw_cython( &
            output_path, top, bottom, shape, convergence) &
            bind(C, name="draw")
            import c_ptr, c_double, c_int
            type(c_ptr)   ,value      :: output_path
            real(c_double),intent(in) :: top(2), bottom(2)
            integer(c_int),intent(in) :: shape(2)
            integer(c_int),intent(in) :: convergence(:,:)
        end function draw_cython

    end interface

contains

    subroutine init_plotter()
        call pyinit_plotter
        call check_python_error
    end subroutine init_plotter

    subroutine draw(output_path, top, bottom, convergence)
        character(*,c_char),intent(in) :: output_path
        real(c_double),intent(in)      :: top(2), bottom(2)
        integer(c_int),intent(in)      :: convergence(:,:)

        call impl(output_path // C_NULL_CHAR )

    contains

        subroutine impl(null_terminated)
            character(*,c_char),target,intent(in) :: null_terminated
            integer returncode
            returncode = draw_cython( &
                c_loc(null_terminated), &
                top, bottom, shape(convergence), convergence)
            if( returncode /= 0) then
                call check_python_error
            end if
        end subroutine impl

    end subroutine draw

end module plotter
