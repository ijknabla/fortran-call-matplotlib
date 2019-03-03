
cdef public api:
    ctypedef int (*ArgCount_GetterFunc ) (int*)
    ctypedef int (*ArgLength_GetterFunc) (int , int*)
    ctypedef int (*Argument_GetterFunc ) (int , int , char*)
