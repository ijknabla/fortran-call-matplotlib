
#include "python_module.h"

#include "plotter_api.h"

extern int append_plotter_pyinittab() {
  CHECK_ERROR(PyImport_AppendInittab("plotter", PyInit_plotter));
  return 0;
}

extern int import_plotter_pymodule() {
  CHECK_ERROR(import_plotter());
  return 0;
}
