
module options

    use iso_c_binding
    use python3

    implicit none

    type options_t
        integer(c_int)                  :: verbose
        integer(c_int)                  :: resolution(2)
        real(c_double)                  :: top(2)
        real(c_double)                  :: bottom(2)
        character(:,c_char),allocatable :: output_path
    end type options_t

    type,bind(C) :: numeric_options_t
        integer(c_int) :: verbose
        integer(c_int) :: resolution(2)
        real(c_double) :: top(2)
        real(c_double) :: bottom(2)
    end type numeric_options_t

    interface

        subroutine pyinit_options() &
            bind(C, name="PyInit_options")
        end subroutine pyinit_options

        integer(c_int) function get_numeric_options(opts) bind(C)
            import c_int, numeric_options_t
            type(numeric_options_t),intent(out) :: opts
        end function get_numeric_options

        integer(c_int) function get_output_path_length(output_path_length) bind(C)
            import c_int
            integer(c_int),intent(out) :: output_path_length
        end function get_output_path_length

        integer(c_int) function get_output_path( &
            output_path_length, output_path) bind(C)
            import c_int, c_ptr
            integer(c_int),value :: output_path_length
            type(c_ptr)   ,value :: output_path
        end function get_output_path

        integer(c_int) function set_argv_from_callbacks( &
            argv_getter, arg_len_getter, arg_getter ) bind(C)
            import c_int, c_funptr
            type(c_funptr),value :: argv_getter
            type(c_funptr),value :: arg_len_getter
            type(c_funptr),value :: arg_getter
        end function set_argv_from_callbacks

    end interface

contains

    integer(c_int) function argc_getter(argc) &
        result(ierr) bind(C)

        integer(c_int),intent(out) :: argc

        ierr = 0
        argc = command_argument_count()
        return

    end function argc_getter

    integer(c_int) function arg_len_getter(iarg, arg_len) result(ierr) &
        bind(C)

        integer(c_int),value       :: iarg
        integer(c_int),intent(out) :: arg_len

        call get_command_argument( &
            iarg, length=arg_len, status=ierr)
        return

    end function arg_len_getter

    integer(c_int) function arg_getter(iarg, arg_len, arg) result(ierr) &
        bind(C)

        integer(c_int),value :: iarg
        integer(c_int),value :: arg_len
        type(c_ptr)   ,value :: arg

        character(arg_len,c_char),pointer :: farg

        call c_f_pointer(arg, farg)

        call get_command_argument( &
            iarg, value=farg, status=ierr)

        return

    end function arg_getter

    subroutine set_argv()

        integer returncode

        returncode = set_argv_from_callbacks( &
            c_funloc(argc_getter   ), &
            c_funloc(arg_len_getter), &
            c_funloc(arg_getter    )  &
            )

        if (returncode /= 0) then
            call check_python_error
        end if

    end subroutine set_argv

    subroutine parse_args(opts)
        type(options_t),target,intent(out) :: opts
        type(numeric_options_t)     :: numeric_opts
        integer(c_int) :: output_path_length

        if ( get_numeric_options(numeric_opts) /= 0 ) then
            call check_python_error
        end if

        opts%verbose    = numeric_opts%verbose
        opts%resolution = numeric_opts%resolution
        opts%top        = numeric_opts%top
        opts%bottom     = numeric_opts%bottom

        if ( get_output_path_length(output_path_length) /= 0 ) then
            call check_python_error
        end if

        allocate( character(output_path_length,c_char) :: opts%output_path )

        if ( &
            get_output_path(        &
            len(opts%output_path),  &
            c_loc(opts%output_path) &
            ) /= 0) then
            call check_python_error
        end if

    end subroutine parse_args

end module options
