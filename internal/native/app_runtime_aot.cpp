#include "app_runtime.h"

Dart_Isolate CreateApplicationIsolate(char** error) {
  return DartVmEmbed_CreateIsolateFromAotSnapshotFile(
      DARTVM_APP_PROGRAM_PATH, DARTVM_APP_SCRIPT_URI, "main", nullptr, nullptr,
      error);
}
