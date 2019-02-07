
program main

    use python3
    use options
    use plotter

    implicit none

    type(options_t) :: opts

    call py_initialize
    call init_options
    call init_plotter

    call parse_args(opts)

    call py_finalize

end program main
