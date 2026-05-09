#include "app_runtime.h"

#include <limits.h>
#include <string.h>
#include <unistd.h>

#include <string>

namespace {

std::string ResolveProgramArtifactPath() {
  char exe_path[PATH_MAX];
  const ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
  if (len <= 0) {
    return DARTVM_APP_PROGRAM_PATH;
  }
  exe_path[len] = '\0';

  char* slash = strrchr(exe_path, '/');
  if (slash == nullptr) {
    return DARTVM_APP_PROGRAM_PATH;
  }
  *(slash + 1) = '\0';

  std::string path(exe_path);
  path += DARTVM_APP_PROGRAM_PATH;
  return path;
}

}  // namespace

Dart_Isolate CreateApplicationIsolate(char** error) {
  const std::string program_path = ResolveProgramArtifactPath();
  return DartVmEmbed_CreateIsolateFromAotSnapshotFile(
      program_path.c_str(), DARTVM_APP_SOURCE_PATH, "main", nullptr, nullptr,
      error);
}
