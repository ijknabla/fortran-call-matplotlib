
module mandelbrot_mod

    use logger
    use iso_c_binding

    implicit none

    integer,parameter :: mdb_complex_kind = 4

contains

    subroutine mandelbrot(nx, ny, top, bottom, convergence)
        integer,intent(in) :: nx
        integer,intent(in) :: ny
        real(c_double)     :: top(2)
        real(c_double)     :: bottom(2)

        integer(c_int),allocatable,intent(out) :: convergence(:,:)

        complex(kind=mdb_complex_kind) :: c(nx,ny)
        real(kind=mdb_complex_kind)    :: real_part(nx)
        real(kind=mdb_complex_kind)    :: imag_part(ny)

        integer i, j

        call info("begin mandelbrot calculation")

        allocate( convergence(nx, ny) )

        !$omp parallel
        real_part(:) = (/ (i * top(1) + (nx-1-i) * bottom(1), i=0,nx-1) /) / (nx-1)
        imag_part(:) = (/ (j * top(2) + (ny-1-j) * bottom(2), j=0,ny-1) /) / (ny-1)

        !$omp workshare
        forall (i=1:nx, j=1:ny) &
            c(i, j) = cmplx(real_part(i),imag_part(j), kind=mdb_complex_kind)
        !$omp end workshare

        !$omp workshare
        convergence(:,:) = iteration(c(:,:))
        !$omp end workshare

        !$omp end parallel

        call info("end   mandelbrot calculation")

    contains

        elemental pure integer(c_int) function iteration(c)
            complex(kind=mdb_complex_kind),intent(in) :: c
            complex(kind=mdb_complex_kind)            :: z
            z = (0.d0, 0.d0)
            do iteration = 1, 128
                z = z * z + c
                if (abs(z) > 2) return
            end do
            iteration = -1
        end function iteration

    end subroutine mandelbrot

end module mandelbrot_mod
