
module mandelbrot_mod

    use iso_c_binding
    use pylogger

    implicit none

    integer,parameter :: mdb_complex_kind = 4
    integer,parameter :: max_iteration    = 252

contains

    subroutine mandelbrot(nx, ny, extent, convergence)
        integer,intent(in) :: nx
        integer,intent(in) :: ny
        real(c_double),intent(in) :: extent(4)

        integer(c_int),allocatable,intent(out) :: convergence(:,:)

        complex(kind=mdb_complex_kind) :: c(nx,ny)
        real(kind=mdb_complex_kind)    :: real_part(nx)
        real(kind=mdb_complex_kind)    :: imag_part(ny)

        real(c_double) :: re_min, re_max, im_min, im_max

        integer i, j

        re_min = extent(1)
        re_max = extent(2)
        im_min = extent(3)
        im_max = extent(4)

        call info( &
            "mandelbrot",                  &
            "begin mandelbrot calculation" &
            )

        allocate( convergence(nx, ny) )

        !$omp parallel
        real_part(:) = (/ (i * re_max + (nx-1-i) * re_min, i=0,nx-1) /) / (nx-1)
        imag_part(:) = (/ (j * im_max + (ny-1-j) * im_min, j=0,ny-1) /) / (ny-1)

        !$omp workshare
        forall (i=1:nx, j=1:ny) &
            c(i, j) = cmplx(real_part(i),imag_part(j), kind=mdb_complex_kind)
        !$omp end workshare

        !$omp workshare
        convergence(:,:) = iteration(c(:,:))
        !$omp end workshare

        !$omp end parallel

        call info( &
            "mandelbrot",                  &
            "end   mandelbrot calculation" &
            )

    contains

        elemental pure integer(c_int) function iteration(c)
            complex(kind=mdb_complex_kind),intent(in) :: c
            complex(kind=mdb_complex_kind)            :: z
            z = (0.d0, 0.d0)
            do iteration = 1, max_iteration
                z = z * z + c
                if (abs(z) > 2) return
            end do
            iteration = -1
        end function iteration

    end subroutine mandelbrot

end module mandelbrot_mod
