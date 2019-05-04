
#include "python_module.h"

#include "pylogger_api.h"

extern int append_pylogger_pyinittab() {
  CHECK_ERROR(PyImport_AppendInittab("pylogger", PyInit_pylogger));
  return 0;
}

extern int import_pylogger_pymodule() {
  CHECK_ERROR(import_pylogger());
  return 0;
}
