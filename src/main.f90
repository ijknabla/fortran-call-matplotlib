
program main

    use python3
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
    call mandelbrot( &
        nx=opts%resolution(1), ny=opts%resolution(2), &
        top=opts%top         , bottom=opts%bottom   , &
        convergence = convergence &
        )
    call draw(convergence)

    call py_finalize

end program main
