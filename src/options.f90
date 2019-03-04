
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

    type,bind(C) :: c_options_t
        integer(c_int) :: verbose         = 0
        integer(c_int) :: resolution(2)   = (/  0,  0 /)
        real(c_double) :: top(2)          = (/ .0, .0 /)
        real(c_double) :: bottom(2)       = (/ .0, .0 /)
        integer(c_int) :: output_path_len = 0
        type(c_ptr)    :: output_path     = C_NULL_PTR
    end type c_options_t

    type auto_c_options_t
        type(c_options_t) :: contents
    contains
        procedure :: parse_args => &
            auto_c_options_method_parse_args
        final     :: auto_c_options_method_finalize
    end type auto_c_options_t

    interface

        subroutine pyinit_options() &
            bind(C, name="PyInit_options")
        end subroutine pyinit_options

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

    subroutine auto_c_options_method_parse_args(opts)
        class(auto_c_options_t),intent(inout) :: opts
        interface
            integer(c_int) function parse_args(opts) &
                bind(C)
                import c_int, c_options_t
                type(c_options_t),intent(inout) :: opts
            end function parse_args
        end interface

        if ( parse_args(opts%contents) /= 0 ) then
            call check_python_error
        end if
        
    end subroutine auto_c_options_method_parse_args
    
    subroutine auto_c_options_method_finalize(self)
        type(auto_c_options_t),intent(inout) :: self

        interface
            integer(c_int) function finalize_options_t(opts) &
                bind(C)
                import c_int, c_options_t
                type(c_options_t),intent(inout) :: opts
            end function finalize_options_t
        end interface

        if (finalize_options_t(self%contents) /= 0) then
            call check_python_error
        end if

    end subroutine auto_c_options_method_finalize

    subroutine parse_args(f_opts)
        type(options_t),intent(out) :: f_opts
        type(auto_c_options_t)      :: auto_c_opts

        call auto_c_opts%parse_args
        call assign(f_opts, auto_c_opts%contents)

    contains

        subroutine assign(f_opts, c_opts)
            type(  options_t),intent(out) :: f_opts
            type(c_options_t),intent(in)  :: c_opts
            character(c_opts%output_path_len,c_char),pointer :: output_path

            f_opts%verbose    = c_opts%verbose
            f_opts%resolution = c_opts%resolution
            f_opts%top        = c_opts%top
            f_opts%bottom     = c_opts%bottom

            call c_f_pointer(c_opts%output_path, output_path)
            f_opts%output_path = output_path

        end subroutine assign

    end subroutine parse_args

end module options
