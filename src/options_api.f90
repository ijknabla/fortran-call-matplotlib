
module options_api

    use iso_c_binding

    implicit none

    private

    public :: &
        set_argv_from_callbacks, &
        parse_args, finalize_options_t

    type,public,bind(C) :: c_options_t
        integer(c_int) :: verbose         = 0_c_int
        integer(c_int) :: resolution(2)   = 0_c_int
        real(c_double) :: extent(4)       = 0_c_double
        integer(c_int) :: output_path_len = 0_c_int
        type(c_ptr)    :: output_path     = C_NULL_PTR
    end type c_options_t

    interface
        integer(c_int) function set_argv_from_callbacks( &
            argv_getter, arg_len_getter, arg_getter ) bind(C)
            import c_int, c_funptr
            type(c_funptr),value :: argv_getter
            type(c_funptr),value :: arg_len_getter
            type(c_funptr),value :: arg_getter
        end function set_argv_from_callbacks

        integer(c_int) function parse_args(opts) &
            bind(C)
            import c_int, c_options_t
            type(c_options_t),intent(inout) :: opts
        end function parse_args

        integer(c_int) function finalize_options_t(opts) &
            bind(C)
            import c_int, c_options_t
            type(c_options_t),intent(inout) :: opts
        end function finalize_options_t

    end interface

end module options_api
