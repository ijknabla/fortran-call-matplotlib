
cdef public api:
    ctypedef int (*ArgCount_GetterFunc ) (int*)
    ctypedef int (*ArgLength_GetterFunc) (int , int*)
    ctypedef int (*Argument_GetterFunc ) (int , int , char*)

    struct options_t:
        int             verbose
        int             resolution[2]
        double          extent[4]
        int             output_path_len
        unsigned char*  output_path
