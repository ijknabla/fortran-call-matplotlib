
module options

    use iso_c_binding
    use python3

    use options_api, only : &
        c_options_t, &
        append_options_pyinittab, import_options_pymodule

    implicit none

    private

    public :: options_t

    public :: &
        append_options_pyinittab, import_options_pymodule, &
        set_argv, parse_args

    type options_t
        integer(c_int)                  :: verbose
        integer(c_int)                  :: resolution(2)
        real(c_double)                  :: extent(4)
        character(:,c_char),allocatable :: output_path
    end type options_t

    type auto_c_options_t
        type(c_options_t) :: contents
    contains
        procedure :: parse_args => &
            auto_c_options_method_parse_args
        final     :: auto_c_options_method_finalize
    end type auto_c_options_t

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

    subroutine set_argv(ierr)

        use options_api, only : &
            set_argv_from_callbacks

        integer,intent(out) :: ierr

        ierr = 0

        ierr = set_argv_from_callbacks( &
            c_funloc(argc_getter   ), &
            c_funloc(arg_len_getter), &
            c_funloc(arg_getter    )  &
            )
        if( ierr /= 0 ) return

    end subroutine set_argv

    subroutine auto_c_options_method_parse_args(opts, ierr)

        use options_api, only : &
            parse_args

        class(auto_c_options_t),intent(inout) :: opts
        integer,intent(out)                   :: ierr

        ierr = 0

        ierr = parse_args(opts%contents)

        if ( ierr /= 0 ) return

    end subroutine auto_c_options_method_parse_args

    subroutine auto_c_options_method_finalize(self)

        use options_api, only : &
            finalize_options_t

        integer ierr

        type(auto_c_options_t),intent(inout) :: self

        ierr = finalize_options_t(self%contents)

        if (ierr /= 0) then
            call pyerr_print
            stop 1
        end if

    end subroutine auto_c_options_method_finalize

    subroutine parse_args(f_opts, ierr)
        type(options_t),intent(out) :: f_opts
        integer,intent(out)         :: ierr

        type(auto_c_options_t)      :: auto_c_opts

        ierr = 0

        call auto_c_opts%parse_args( ierr )
        if ( ierr /= 0 ) return

        call assign(f_opts, auto_c_opts%contents)

    contains

        subroutine assign(f_opts, c_opts)
            type(  options_t),intent(out) :: f_opts
            type(c_options_t),intent(in)  :: c_opts
            character(c_opts%output_path_len,c_char),pointer :: output_path

            f_opts%verbose       = c_opts%verbose
            f_opts%resolution(:) = c_opts%resolution(:)
            f_opts%extent(:)     = c_opts%extent(:)

            call c_f_pointer(c_opts%output_path, output_path)
            f_opts%output_path = output_path

        end subroutine assign

    end subroutine parse_args

end module options
