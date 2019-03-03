
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

    interface command_argument_t
        module procedure :: command_argument_initialize
    end interface command_argument_t

    type command_argument_t
        integer(c_int)          :: argc = -1
        type(c_ptr),allocatable :: argv(:), wchar_argv(:)
    contains
        final :: command_argument_finalize
    end type command_argument_t

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

        type(command_argument_t) :: cmd

        cmd = command_argument_t()

        call pysys_setargv( size(cmd%wchar_argv), cmd%wchar_argv)

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

    type(command_argument_t) function command_argument_initialize() result(self)

        integer(c_int)    :: iarg
        integer(c_size_t) :: wchar_arg_size
        character(:),allocatable,target :: arg

        interface
            type(c_ptr) function strcpy(s1, s2) bind(C)
                import c_ptr
                type(c_ptr),value :: s1, s2
            end function strcpy
        end interface

        self%argc = command_argument_count()
        allocate(self%argv      (0:self%argc))
        allocate(self%wchar_argv(0:self%argc))

        do iarg = 0,self%argc
            ! get null-terminated argument :: character(:) [Fortran]
            arg = get_nullterminated_arg(iarg)
            ! copy into argv               :: char*        [C]
            self%argv(iarg) = pymem_rawmalloc(int(len(arg), c_size_t))
            self%argv(iarg) = strcpy(self%argv(iarg), c_loc(arg))
            ! convert wchar_t              :: wchar_t*     [C]
            self%wchar_argv(iarg) = py_decodelocale(self%argv(iarg), wchar_arg_size)
        end do

    contains

        function get_nullterminated_arg(iarg) result(arg)
            integer(c_int),intent(in) :: iarg
            character(:),allocatable  :: arg
            integer arg_length

            call get_command_argument(iarg, length=arg_length)
            allocate(character(arg_length) :: arg)
            call get_command_argument(iarg, value=arg        )
            arg = arg // C_NULL_CHAR

        end function get_nullterminated_arg

    end function command_argument_initialize

    subroutine command_argument_finalize(cmd)
        type(command_argument_t),intent(inout) :: cmd
        integer(c_int) :: i
        type(c_ptr),pointer :: ptr

        call clear_c_ptr_arr( cmd%argv       )
        call clear_c_ptr_arr( cmd%wchar_argv )

    contains

        subroutine clear_c_ptr_arr(p_arr)
            integer i
            type(c_ptr),allocatable,intent(inout) :: p_arr(:)
            if ( allocated(p_arr) ) then
                do i = lbound(p_arr,1), ubound(p_arr,1)
                    call clear_c_ptr(p_arr(i))
                end do
            end if
        end subroutine clear_c_ptr_arr

        subroutine clear_c_ptr(p)
            type(c_ptr),intent(inout) :: p
            if ( c_associated(p) ) then
                call pymem_rawfree(p)
                p = C_NULL_PTR
            end if
        end subroutine clear_c_ptr

    end subroutine command_argument_finalize

end module options
