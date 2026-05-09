#include "app_runtime.h"

#include <cstdint>

namespace {

bool AlwaysFileModified(const char* url, int64_t since) {
  (void)url;
  (void)since;
  return true;
}

}  // namespace

Dart_Isolate CreateApplicationIsolate(char** error) {
  Dart_Isolate isolate = DartVmEmbed_CreateIsolateFromSource(
      DARTVM_APP_SOURCE_PATH, DARTVM_APP_SCRIPT_URI, "main.dart", nullptr,
      nullptr, error);
  if (isolate == nullptr) {
    return nullptr;
  }
  if (!DartVmEmbed_SetFileModifiedCallback(&AlwaysFileModified, error)) {
    DartVmEmbed_ShutdownIsolateByHandle(isolate);
    return nullptr;
  }
  return isolate;
}
