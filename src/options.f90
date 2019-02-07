
module options

    use iso_c_binding

    implicit none

    interface

        subroutine pyinit_options() &
            bind(C, name="PyInit_options")
        end subroutine pyinit_options

    end interface

contains

    subroutine init_options()
        call pyinit_options
    end subroutine init_options

end module options
