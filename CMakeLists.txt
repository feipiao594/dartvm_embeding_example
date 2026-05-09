cmake_minimum_required(VERSION 3.21)

project(DARTVM_EMBED_APP_TEMPLATE)

set(APP_RUNTIME_FLAVOR "jit_source")
set(APP_EMBED_INSTALL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../lib_install")

include("${CMAKE_CURRENT_SOURCE_DIR}/internal/cmake/DartAppSupport.cmake")
dartvm_app_prepare_embedder()

set(APP_DART_ENTRY_FILE "${CMAKE_CURRENT_SOURCE_DIR}/lib/main.dart")
set(APP_DART_SCRIPT_URI "${APP_DART_ENTRY_FILE}")
set(APP_DART_PUBSPEC_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

dartvm_app_validate_configuration()
dartvm_app_get_runtime_sources(APP_RUNTIME_SOURCES)
dartvm_app_get_program_artifact_path(APP_PROGRAM_ARTIFACT)
dartvm_app_add_program_artifact_target(app_program)

add_executable(app src/main.cpp ${APP_RUNTIME_SOURCES})
add_dependencies(app app_program)
dartvm_app_configure_target(app)
