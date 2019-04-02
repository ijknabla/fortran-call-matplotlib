
#include "python_module.h"

#include "options_api.h"

extern int append_options_pyinittab() {
  CHECK_ERROR(PyImport_AppendInittab("options", PyInit_options));
  return 0;
}

extern int import_options_pymodule() {
  CHECK_ERROR(import_options());
  return 0;
}
