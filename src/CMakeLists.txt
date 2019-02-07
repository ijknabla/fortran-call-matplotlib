
# compile .pyx to .c using cython
function(pyx2c pyx_source c_source)
  set(args ${ARGV} "" "")
  list(GET args 2 c_header)

  add_custom_command(
    OUTPUT ${c_source} ${c_header}
    COMMAND ${PYTHON_EXECUTABLE} -m cython -3
    ${pyx_source} -o ${c_source}
    DEPENDS ${pyx_source}
    )
endfunction()



set(OPTIONS_PYX ${CMAKE_CURRENT_SOURCE_DIR}/options.pyx)
set(OPTIONS_C   ${CMAKE_CURRENT_BINARY_DIR}/options.c  )
set(OPTIONS_H   ${CMAKE_CURRENT_BINARY_DIR}/options.h  )
pyx2c(
  ${OPTIONS_PYX}
  ${OPTIONS_C}
  )

set(PLOTTER_PYX ${CMAKE_CURRENT_SOURCE_DIR}/plotter.pyx)
set(PLOTTER_C   ${CMAKE_CURRENT_BINARY_DIR}/plotter.c  )
set(PLOTTER_H   ${CMAKE_CURRENT_BINARY_DIR}/plotter.h  )
pyx2c(
  ${PLOTTER_PYX}
  ${PLOTTER_C}
  )

add_executable(mandelbrot
  mandelbrot.f90
  python3.f90
  ${OPTIONS_C}
  options.f90
  ${PLOTTER_C}
  plotter.f90
  )

target_include_directories(mandelbrot
  PRIVATE
  ${PYTHON_INCLUDE_DIR})

target_link_libraries(mandelbrot
  ${PYTHON_LIBRARY})