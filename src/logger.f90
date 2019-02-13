
module logger

    use iso_fortran_env, only : error_unit

    implicit none

    private

    integer           :: verbosity = 0

    integer,parameter :: default_verbosity = 0
    integer,parameter :: info_verbosity    = 1
    integer,parameter :: debug_verbosity   = 2

    public :: set_level
    public :: debug, info

contains

    subroutine set_level(verbose)
        integer,intent(in) :: verbose
        verbosity = verbose
    end subroutine set_level

    subroutine debug(message)
        character(*),intent(in) :: message
        if(verbosity >= debug_verbosity) then
            write(error_unit, '(A)') message
        end if
    end subroutine debug

    subroutine info(message)
        character(*),intent(in) :: message
        if(verbosity >= info_verbosity) then
            write(error_unit, '(A)') message
        end if
    end subroutine info
        
end module logger
