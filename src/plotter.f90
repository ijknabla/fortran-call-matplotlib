
module plotter

    use iso_c_binding

    implicit none

    interface

        subroutine pyinit_plotter() &
            bind(C, name="PyInit_plotter")
        end subroutine pyinit_plotter

        subroutine draw_cython(shape, convergence) &
            bind(C, name="draw")
            import c_int
            integer(c_int),intent(in) :: shape(2)
            integer(c_int),intent(in) :: convergence(:,:)
        end subroutine draw_cython

    end interface

contains

    subroutine init_plotter()
        call pyinit_plotter
    end subroutine init_plotter

    subroutine draw(convergence)
        integer(c_int),intent(in) :: convergence(:,:)
        call draw_cython(shape(convergence), convergence)
    end subroutine draw

end module plotter
