
program main

    use python3
    use logger, only : set_logger_level => set_level
    use options
    use mandelbrot_mod
    use plotter

    implicit none

    integer :: ierr

    integer(c_int),allocatable :: convergence(:,:)

    type(options_t) :: opts

100 call append_pyinittabs( ierr )
    call check_error(ierr=ierr, line_no=100)

    call py_initialize

200 call import_pymodules( ierr )
    call check_error(ierr=ierr, line_no=200)

210 call set_argv( ierr )
    call check_error(ierr=ierr, line_no=210)

220 call parse_args(opts, ierr)
    call check_error(ierr=ierr, line_no=220)

    call set_logger_level(opts%verbose)
    call mandelbrot( &
        nx=opts%resolution(1), ny=opts%resolution(2), &
        extent = opts%extent,                         &
        convergence = convergence                     &
        )

230 call draw( &
        opts%output_path,         &
        opts%extent, convergence, &
        ierr &
        )
    call check_error(ierr=ierr, line_no=230)

    call py_finalize

contains

    subroutine append_pyinittabs(ierr)

        use options , only : append_options_pyinittab
        use plotter , only : append_plotter_pyinittab
        use pylogger, only : append_pylogger_pyinittab

        integer,intent(out) :: ierr

        ierr = 0

        ierr = append_options_pyinittab()
        if( ierr /= 0 ) return

        ierr = append_plotter_pyinittab()
        if( ierr /= 0 ) return

        ierr = append_pylogger_pyinittab()
        if( ierr /= 0 ) return

    end subroutine append_pyinittabs

    subroutine import_pymodules( ierr )

        use options , only : import_options_pymodule
        use plotter , only : import_plotter_pymodule
        use pylogger, only : import_pylogger_pymodule

        integer,intent(out) :: ierr

        ierr = 0

        ierr = import_options_pymodule()
        if( ierr /= 0 ) return

        ierr = import_plotter_pymodule()
        if( ierr /= 0 ) return

        ierr = import_pylogger_pymodule()
        if( ierr /= 0 ) return

    end subroutine import_pymodules

    subroutine check_error(ierr, line_no)

        use iso_fortran_env, only : stderr => error_unit

        integer         ,intent(in)  :: ierr
        integer,optional,intent(in)  :: line_no

        type(c_ptr) :: error_pyobject

        if (ierr == 0) return

        error_pyobject = pyerr_occurred()
        if ( c_associated(error_pyobject) ) then
            call pyerr_print
        end if

        if( present(line_no) ) then
            write( stderr , '(A, I0, A, I5)') &
                "ERROR: returncode = ", ierr, " at main.f90:", line_no
        else
            write( stderr , '(A, I0, A)') &
                "ERROR: returncode = ", ierr, " at main.f90:"
        end if

        stop 1

    end subroutine check_error

end program main
