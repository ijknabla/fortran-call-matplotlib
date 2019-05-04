
module plotter

    use iso_c_binding
    use python3

    use plotter_api, only : &
        append_plotter_pyinittab, import_plotter_pymodule

    implicit none

contains

    subroutine draw(output_path, extent, convergence, ierr)

        use plotter_api, only : draw_cyimpl => draw

        character(*,c_char),intent(in) :: output_path
        real(c_double),intent(in)      :: extent(4)
        integer(c_int),intent(in)      :: convergence(:,:)

        integer,intent(out)            :: ierr

        ierr = 0
        call impl(output_path // C_NULL_CHAR, ierr)
        if( ierr /= 0 ) return

    contains

        subroutine impl(null_terminated, ierr)
            character(*,c_char),target,intent(in) :: null_terminated
            integer,intent(out)                   :: ierr

            ierr = 0
            ierr = draw_cyimpl( &
                c_loc(null_terminated), &
                extent, shape(convergence), convergence)
            if( ierr /= 0 ) return

        end subroutine impl

    end subroutine draw

end module plotter
