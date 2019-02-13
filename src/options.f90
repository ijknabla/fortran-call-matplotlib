
module options

    use iso_c_binding
    use python3

    implicit none

    type,bind(C) :: options_t
        integer(c_int) :: verbose
        integer(c_int) :: resolution(2)
        real(c_double) :: top(2)
        real(c_double) :: bottom(2)
    end type options_t

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

        integer(c_int) function parse_args_cython(opts) &
            bind(C, name="parse_args")
            import c_int, options_t
            type(options_t),intent(out) :: opts
        end function parse_args_cython

    end interface

contains

    subroutine init_options()

        type(command_argument_t) :: cmd

        cmd = command_argument_t()

        call pysys_setargvex( size(cmd%wchar_argv), cmd%wchar_argv, 0 )

        call pyinit_options

        call check_python_error

    end subroutine init_options

    subroutine parse_args(opts)
        type(options_t),intent(out) :: opts
        if ( parse_args_cython(opts) /= 0 ) then
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
