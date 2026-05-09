#include "app_runtime.h"

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <vector>

namespace {

bool ReadFileBytes(const char* path, std::vector<uint8_t>* bytes) {
  if (path == nullptr || bytes == nullptr) {
    return false;
  }
  std::ifstream input(path, std::ios::binary | std::ios::ate);
  if (!input.is_open()) {
    return false;
  }
  const std::streamsize size = input.tellg();
  if (size < 0) {
    return false;
  }
  bytes->resize(static_cast<size_t>(size));
  input.seekg(0, std::ios::beg);
  return input.read(reinterpret_cast<char*>(bytes->data()), size).good();
}

void SetSimpleError(const char* message, char** error) {
  if (error == nullptr || message == nullptr) {
    return;
  }
  *error = static_cast<char*>(std::malloc(std::strlen(message) + 1));
  if (*error != nullptr) {
    std::memcpy(*error, message, std::strlen(message) + 1);
  }
}

}  // namespace

Dart_Isolate CreateApplicationIsolate(char** error) {
  std::vector<uint8_t> kernel;
  if (!ReadFileBytes(DARTVM_APP_PROGRAM_PATH, &kernel)) {
    SetSimpleError("Read app program artifact failed.", error);
    return nullptr;
  }
  return DartVmEmbed_CreateIsolateFromKernel(
      DARTVM_APP_SCRIPT_URI, "main", kernel.data(),
      static_cast<intptr_t>(kernel.size()), nullptr, nullptr, error);
}
