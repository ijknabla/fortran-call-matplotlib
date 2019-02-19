
#include <Python.h>

#include "options_api.h"
#include "plotter_api.h"

#define CHECK_ERROR(code) {int retcode = code;if(retcode!=0) return retcode;}

extern int appendInittab() {
  CHECK_ERROR(PyImport_AppendInittab("options", PyInit_options));
  CHECK_ERROR(PyImport_AppendInittab("plotter", PyInit_plotter));
  return 0;
};

extern int import_modules() {
  CHECK_ERROR(import_options());
  CHECK_ERROR(import_plotter());
  return 0;
}
