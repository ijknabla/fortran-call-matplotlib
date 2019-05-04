
module pylogger

    use iso_c_binding

    use pylogger_api, only : &
        append_pylogger_pyinittab, &
        import_pylogger_pymodule

    implicit none

    private

    public :: &
        append_pylogger_pyinittab, &
        import_pylogger_pymodule , &
        debug, info

    integer,parameter :: &
        NOTSET_LV   = 00, &
        DEBUG_LV    = 10, &
        INFO_LV     = 20, &
        WARNING_LV  = 30, &
        ERROR_LV    = 40, &
        CRITICAL_LV = 50

contains

    subroutine debug(module_name, message)
        character(*),intent(in) :: module_name
        character(*),intent(in) :: message
        call log(module_name, DEBUG_LV, message)
    end subroutine debug

    subroutine info(module_name, message)
        character(*),intent(in) :: module_name
        character(*),intent(in) :: message
        call log(module_name, INFO_LV, message)
    end subroutine info

    subroutine log(module_name, level, message)
        use pylogger_api, only : pylogger_log
        character(*),intent(in) :: module_name
        integer     ,intent(in) :: level
        character(*),intent(in) :: message

        integer ierr

        ierr = pylogger_log( &
            fchar2cptr(trim(module_name)//C_NULL_CHAR), &
            level                                     , &
            fchar2cptr(trim(message    )//C_NULL_CHAR)  &
            )
    end subroutine log

    type(c_ptr) function fchar2cptr(fchar) result(cptr)
        character(*,c_char),intent(in),target :: fchar
        cptr = c_loc(fchar)
    end function fchar2cptr

end module pylogger
