
cmake_minimum_required(VERSION 3.0)

enable_language(Fortran)

find_package(PythonInterp 3 REQUIRED)
find_package(PythonLibs   3 REQUIRED)
find_package(OpenMP)

include_directories(include)

add_subdirectory(src)

