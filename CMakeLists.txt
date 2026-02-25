cmake_minimum_required(VERSION 3.21)
project(external_consumer_demo CXX)
include(FetchContent)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(FETCHCONTENT_QUIET OFF)

FetchContent_Declare(
  dartvm_sdk
  # URL "/home/feipiao/Downloads/dartvm_embed_lib-linux"
  URL "https://github.com/feipiao594/dartvm_embed_lib/releases/download/dev-v0.0.1(vibe)/dartvm_embed_lib-dev-v0.0.1.vibe.-linux-x64.tar.gz"
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

FetchContent_MakeAvailable(dartvm_sdk)

list(APPEND CMAKE_PREFIX_PATH "${dartvm_sdk_SOURCE_DIR}")
find_package(dartvm_embed_lib REQUIRED CONFIG)

set(DARTVM_EMBED_FLAVOR "jit" CACHE STRING "Runtime flavor (jit|aot)")
set_property(CACHE DARTVM_EMBED_FLAVOR PROPERTY STRINGS jit aot)
if(NOT DARTVM_EMBED_FLAVOR STREQUAL "jit" AND NOT DARTVM_EMBED_FLAVOR STREQUAL "aot")
  message(FATAL_ERROR "DARTVM_EMBED_FLAVOR must be jit|aot")
endif()

set(_embed_target "DartVmEmbed::dartvm_embed_lib_${DARTVM_EMBED_FLAVOR}")
if(NOT TARGET "${_embed_target}")
  message(FATAL_ERROR "Target not found in package: ${_embed_target}")
endif()

add_executable(external_consumer_demo main.cpp)
target_link_libraries(external_consumer_demo PRIVATE "${_embed_target}")

if(UNIX AND NOT APPLE)
  target_link_options(external_consumer_demo PRIVATE "-Wl,--export-dynamic")
endif()

if(WIN32)
  add_custom_command(TARGET external_consumer_demo POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:external_consumer_demo> $<TARGET_FILE_DIR:external_consumer_demo>
    COMMAND_EXPAND_LISTS
  )
endif()

if(MSVC)
  set_property(TARGET external_consumer_demo PROPERTY
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
endif()

dartvm_embed_add_program_target(external_program
  DART_FILE "${CMAKE_CURRENT_SOURCE_DIR}/hello.dart"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/program.bin"
  PUBSPEC_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  FLAVOR "${DARTVM_EMBED_FLAVOR}"
)
add_dependencies(external_consumer_demo external_program)
