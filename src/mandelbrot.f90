
module mandelbrot_mod

    use iso_c_binding
    
    implicit none

contains

    subroutine mandelbrot(nx, ny, top, bottom, convergence)
        integer,intent(in) :: nx
        integer,intent(in) :: ny
        real(c_double)     :: top(2)
        real(c_double)     :: bottom(2)

        integer(c_int),allocatable,intent(out) :: convergence(:,:)

        complex(kind=8) :: c(nx,ny)
        real(kind=8)    :: real_part(nx)
        real(kind=8)    :: imag_part(ny)

        integer i, j

        real_part(:) = (/ (i * top(1) + (nx-1-i) * bottom(1), i=0,nx-1) /) / (nx-1)
        imag_part(:) = (/ (j * top(2) + (ny-1-j) * bottom(2), j=0,ny-1) /) / (ny-1)

        allocate( convergence(nx, ny) )

        forall (i=1:nx, j=1:ny) &
            c(i, j) = cmplx(real_part(i),imag_part(j), kind=8)

        convergence(:,:) = iteration(c(:,:))

    contains

        elemental pure integer(c_int) function iteration(c)
            complex(kind=8),intent(in) :: c
            complex(kind=8)            :: z
            z = (0.d0, 0.d0)
            do iteration = 1, 128
                z = z * z + c
                if (abs(z) > 2) return
            end do
            iteration = -1
        end function iteration

    end subroutine mandelbrot

end module mandelbrot_mod
