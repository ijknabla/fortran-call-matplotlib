
module plotter

    use iso_c_binding

    implicit none

    interface

        subroutine pyinit_plotter() &
            bind(C, name="PyInit_plotter")
        end subroutine pyinit_plotter

    end interface

contains

    subroutine init_plotter()
        call pyinit_plotter
    end subroutine init_plotter

end module plotter
