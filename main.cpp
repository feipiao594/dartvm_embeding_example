#include <cstdint>
#include <iostream>
#include <dartvm_embed_lib.h>

extern "C" void SimplePrintInt(int64_t value) {
  std::cout << "[external-ffi] value from Dart: " << value << std::endl;
}

int main() {
  char* error = nullptr;
  Dart_Isolate isolate = DartVmEmbed_CreateIsolateFromProgramFile(
      "program.bin", "hello.dart", nullptr, nullptr, &error);
  if (isolate == nullptr) {
    std::cerr << "Create isolate failed: " << (error ? error : "unknown")
              << std::endl;
    free(error);
    return -1;
  }

  if (!DartVmEmbed_RunRootEntryOnIsolate(isolate, "main", &error)) {
    std::cerr << "RunRootEntry failed: " << (error ? error : "unknown")
              << std::endl;
    free(error);
    DartVmEmbed_ShutdownIsolateByHandle(isolate);
    DartVmEmbed_Cleanup(nullptr);
    return -1;
  }

  DartVmEmbed_ShutdownIsolateByHandle(isolate);

  if (!DartVmEmbed_Cleanup(&error)) {
    std::cerr << "Cleanup failed: " << (error ? error : "unknown")
              << std::endl;
    free(error);
    return -1;
  }

  return 0;
}
