
program main

    use python3
    use logger, only : set_logger_level => set_level
    use options
    use mandelbrot_mod
    use plotter

    implicit none

    interface
        integer(c_int) function append_inittab() &
            bind(C, name="appendInittab")
            import c_int
        end function append_inittab

        integer(c_int) function import_modules() &
            bind(C, name="import_modules")
            import c_int
        end function import_modules
    end interface

    integer(c_int),allocatable :: convergence(:,:)

    type(options_t) :: opts

    if( append_inittab() /= 0 ) call check_python_error
    call py_initialize
    call set_argv
    if( import_modules() /= 0 ) call check_python_error

    call parse_args(opts)
    call set_logger_level(opts%verbose)
    call mandelbrot( &
        nx=opts%resolution(1), ny=opts%resolution(2), &
        top=opts%top         , bottom=opts%bottom   , &
        convergence = convergence &
        )
    call draw( &
        opts%output_path, &
        opts%top, opts%bottom, convergence &
        )

    call py_finalize

end program main
