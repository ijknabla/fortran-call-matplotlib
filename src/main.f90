
program main

    use python3
    use logger, only : set_logger_level => set_level
    use options
    use mandelbrot_mod
    use plotter

    implicit none

    integer(c_int),allocatable :: convergence(:,:)

    type(options_t) :: opts

    call py_initialize
    call init_options
    call init_plotter

    call parse_args(opts)
    call set_logger_level(opts%verbose)
    call mandelbrot( &
        nx=opts%resolution(1), ny=opts%resolution(2), &
        top=opts%top         , bottom=opts%bottom   , &
        convergence = convergence &
        )
    call draw(opts%top, opts%bottom, convergence)

    call py_finalize

end program main
