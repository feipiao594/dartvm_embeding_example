set(_DARTVM_APP_SUPPORT_DIR "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_DARTVM_APP_TEMPLATE_DIR "${_DARTVM_APP_SUPPORT_DIR}/../.." ABSOLUTE)

function(_dartvm_app_require_file path label)
  if(NOT EXISTS "${path}")
    message(FATAL_ERROR "Missing ${label}: ${path}")
  endif()
endfunction()

macro(_dartvm_app_prepare_sdk_paths)
  set(DARTSDK_BUILD_DIR "ReleaseX64")
  set(APP_EMBED_SDK_DIR "${APP_EMBED_INSTALL_DIR}/share/dartvm_embed_lib/sdk/${DARTSDK_BUILD_DIR}")
  set(DARTSDK_DART_BIN "${APP_EMBED_SDK_DIR}/bin/dart")
  set(DARTSDK_GEN_SNAPSHOT_BIN "${APP_EMBED_SDK_DIR}/gen_snapshot")
  set(DARTSDK_DARTAOTRUNTIME_BIN "${APP_EMBED_SDK_DIR}/bin/dartaotruntime")
  set(DARTSDK_GEN_KERNEL_SNAPSHOT "${APP_EMBED_SDK_DIR}/bin/snapshots/gen_kernel_aot.dart.snapshot")
  set(DARTSDK_VM_PLATFORM_DILL "${APP_EMBED_SDK_DIR}/lib/_internal/vm_platform_strong.dill")
endmacro()

function(_dartvm_app_get_install_libdir out_var)
  if(EXISTS "${APP_EMBED_INSTALL_DIR}/lib")
    set(${out_var} "${APP_EMBED_INSTALL_DIR}/lib" PARENT_SCOPE)
    return()
  endif()
  if(EXISTS "${APP_EMBED_INSTALL_DIR}/lib64")
    set(${out_var} "${APP_EMBED_INSTALL_DIR}/lib64" PARENT_SCOPE)
    return()
  endif()
  message(FATAL_ERROR "Missing installed library directory under ${APP_EMBED_INSTALL_DIR}")
endfunction()

function(_dartvm_app_get_embedder_flavor out_var)
  if(APP_RUNTIME_FLAVOR STREQUAL "aot")
    set(${out_var} "aot" PARENT_SCOPE)
  elseif(APP_RUNTIME_FLAVOR STREQUAL "jit" OR APP_RUNTIME_FLAVOR STREQUAL "jit_source")
    set(${out_var} "jit" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "APP_RUNTIME_FLAVOR must be jit|jit_source|aot")
  endif()
endfunction()

function(_dartvm_app_define_installed_embedder flavor)
  set(_target "dartvm_embed_lib_${flavor}")
  if(TARGET "${_target}")
    return()
  endif()

  find_package(Threads REQUIRED)
  _dartvm_app_get_install_libdir(_install_libdir)

  set(_install_lib "${_install_libdir}/libdartvm_embed_lib_${flavor}.a")
  set(_runtime_dir "${APP_EMBED_INSTALL_DIR}/share/dartvm_embed_lib/runtime/${DARTSDK_BUILD_DIR}")
  if(flavor STREQUAL "aot")
    set(_runtime_lib "${_runtime_dir}/libdart_embedder_runtime_aot_precompiled_static.a")
    set(_extra_obj "")
  else()
    set(_runtime_lib "${_runtime_dir}/libdart_embedder_runtime_jit_static.a")
    set(_extra_obj "${_runtime_dir}/dart_set.dartdev_isolate.o")
  endif()
  set(_clang_libcxx "${_runtime_dir}/libc++.a")
  set(_clang_libunwind "${_runtime_dir}/libunwind.a")

  _dartvm_app_require_file("${_install_lib}" "${_target}")
  _dartvm_app_require_file("${_runtime_lib}" "${flavor} runtime archive")
  _dartvm_app_require_file("${_clang_libcxx}" "libc++.a")
  _dartvm_app_require_file("${_clang_libunwind}" "libunwind.a")
  if(_extra_obj)
    _dartvm_app_require_file("${_extra_obj}" "${flavor} extra object")
  endif()
  _dartvm_app_require_file("${APP_EMBED_INSTALL_DIR}/include/dartvm_embed_lib.h" "installed public header")

  add_library("${_target}" INTERFACE IMPORTED)
  target_include_directories("${_target}" INTERFACE
    "${APP_EMBED_INSTALL_DIR}/include"
  )
  target_link_libraries("${_target}" INTERFACE
    "${_install_lib}"
    Threads::Threads
    ${CMAKE_DL_LIBS}
    "-Wl,--whole-archive"
    "${_runtime_lib}"
    "-Wl,--no-whole-archive"
    "${_clang_libcxx}"
    "${_clang_libunwind}"
  )
  if(_extra_obj)
    target_link_libraries("${_target}" INTERFACE "${_extra_obj}")
  endif()
endfunction()

macro(dartvm_app_prepare_embedder)
  _dartvm_app_prepare_sdk_paths()
  _dartvm_app_define_installed_embedder(jit)
  _dartvm_app_define_installed_embedder(aot)
endmacro()

function(dartvm_app_validate_configuration)
  if(NOT APP_RUNTIME_FLAVOR STREQUAL "jit" AND
     NOT APP_RUNTIME_FLAVOR STREQUAL "jit_source" AND
     NOT APP_RUNTIME_FLAVOR STREQUAL "aot")
    message(FATAL_ERROR "APP_RUNTIME_FLAVOR must be jit|jit_source|aot")
  endif()

  _dartvm_app_require_file("${DARTSDK_DART_BIN}" "dart binary")

  _dartvm_app_get_embedder_flavor(_embedder_flavor)
  set(_app_embed_target "dartvm_embed_lib_${_embedder_flavor}")
  if(NOT TARGET "${_app_embed_target}")
    message(FATAL_ERROR "Missing library target: ${_app_embed_target}")
  endif()

  if(APP_RUNTIME_FLAVOR STREQUAL "aot")
    _dartvm_app_require_file("${DARTSDK_GEN_SNAPSHOT_BIN}" "gen_snapshot")
    _dartvm_app_require_file("${DARTSDK_DARTAOTRUNTIME_BIN}" "dartaotruntime")
    _dartvm_app_require_file("${DARTSDK_GEN_KERNEL_SNAPSHOT}" "gen_kernel snapshot")
    _dartvm_app_require_file("${DARTSDK_VM_PLATFORM_DILL}" "vm_platform_strong.dill")
  endif()
endfunction()

function(dartvm_app_get_runtime_sources out_var)
  if(APP_RUNTIME_FLAVOR STREQUAL "aot")
    set(${out_var}
      "${_DARTVM_APP_TEMPLATE_DIR}/internal/native/app_runtime_aot.cpp"
      PARENT_SCOPE
    )
  elseif(APP_RUNTIME_FLAVOR STREQUAL "jit_source")
    set(${out_var}
      "${_DARTVM_APP_TEMPLATE_DIR}/internal/native/app_runtime_jit_source.cpp"
      PARENT_SCOPE
    )
  else()
    set(${out_var}
      "${_DARTVM_APP_TEMPLATE_DIR}/internal/native/app_runtime_jit_kernel.cpp"
      PARENT_SCOPE
    )
  endif()
endfunction()

function(dartvm_app_get_program_artifact_path out_var)
  set(${out_var}
    "${CMAKE_CURRENT_BINARY_DIR}/program.bin"
    PARENT_SCOPE
  )
endfunction()

function(dartvm_app_add_program_artifact_target target_name)
  dartvm_app_validate_configuration()
  if(NOT IS_ABSOLUTE "${APP_PROGRAM_ARTIFACT}")
    message(FATAL_ERROR "APP_PROGRAM_ARTIFACT must be an absolute path")
  endif()

  set(_app_program "${APP_PROGRAM_ARTIFACT}")
  get_filename_component(_app_program_dir "${_app_program}" DIRECTORY)
  set(_app_package_config "${APP_DART_PUBSPEC_DIR}/.dart_tool/package_config.json")
  set(_app_pubspec_yaml "${APP_DART_PUBSPEC_DIR}/pubspec.yaml")
  set(_app_pubspec_lock "${APP_DART_PUBSPEC_DIR}/pubspec.lock")
  set(_app_dart_entry "${APP_DART_ENTRY_FILE}")

  add_custom_command(
    OUTPUT "${_app_package_config}" "${_app_pubspec_lock}"
    COMMAND "${DARTSDK_DART_BIN}" pub get
    WORKING_DIRECTORY "${APP_DART_PUBSPEC_DIR}"
    DEPENDS "${_app_pubspec_yaml}"
    COMMENT "Running dart pub get for app"
    VERBATIM
  )

  if(APP_RUNTIME_FLAVOR STREQUAL "jit_source")
    add_custom_target("${target_name}" DEPENDS
      "${_app_package_config}" "${_app_pubspec_lock}"
    )
    return()
  endif()

  if(APP_RUNTIME_FLAVOR STREQUAL "aot")
    set(_app_aot_kernel "${CMAKE_CURRENT_BINARY_DIR}/app_kernel_aot.dill")
    add_custom_command(
      OUTPUT "${_app_aot_kernel}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${_app_program_dir}"
      COMMAND "${DARTSDK_DARTAOTRUNTIME_BIN}" "${DARTSDK_GEN_KERNEL_SNAPSHOT}"
              --platform "${DARTSDK_VM_PLATFORM_DILL}"
              --aot
              --tfa
              "${_app_dart_entry}"
              -o "${_app_aot_kernel}"
      WORKING_DIRECTORY "${APP_DART_PUBSPEC_DIR}"
      DEPENDS "${_app_dart_entry}" "${_app_package_config}"
      COMMENT "Compiling app Dart code to AOT kernel"
      VERBATIM
    )

    add_custom_command(
      OUTPUT "${_app_program}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${_app_program_dir}"
      COMMAND "${DARTSDK_GEN_SNAPSHOT_BIN}"
              --snapshot_kind=app-aot-elf
              --elf=${_app_program}
              "${_app_aot_kernel}"
      WORKING_DIRECTORY "${APP_DART_PUBSPEC_DIR}"
      DEPENDS "${_app_aot_kernel}"
      COMMENT "Generating app AOT snapshot"
      VERBATIM
    )
  else()
    add_custom_command(
      OUTPUT "${_app_program}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${_app_program_dir}"
      COMMAND "${DARTSDK_DART_BIN}" compile kernel
              "${_app_dart_entry}"
              -o "${_app_program}"
      WORKING_DIRECTORY "${APP_DART_PUBSPEC_DIR}"
      DEPENDS "${_app_dart_entry}" "${_app_package_config}"
      COMMENT "Generating app kernel program"
      VERBATIM
    )
  endif()

  add_custom_target("${target_name}" DEPENDS "${_app_program}")
endfunction()

function(dartvm_app_configure_target target_name)
  dartvm_app_validate_configuration()

  if(NOT TARGET "${target_name}")
    message(FATAL_ERROR "dartvm_app_configure_target: target not found: ${target_name}")
  endif()

  _dartvm_app_get_embedder_flavor(_embedder_flavor)
  set(_app_embed_target "dartvm_embed_lib_${_embedder_flavor}")
  target_link_libraries("${target_name}" PRIVATE "${_app_embed_target}")
  target_include_directories("${target_name}" PRIVATE
    "${_DARTVM_APP_TEMPLATE_DIR}/internal/native"
  )
  set(_app_program_path_define "${APP_PROGRAM_ARTIFACT}")
  if(APP_RUNTIME_FLAVOR STREQUAL "aot")
    set(_app_program_path_define "program.bin")
  endif()
  target_compile_definitions("${target_name}" PRIVATE
    DARTVM_APP_PROGRAM_PATH="${_app_program_path_define}"
    DARTVM_APP_SOURCE_PATH="${APP_DART_ENTRY_FILE}"
    DARTVM_APP_SCRIPT_URI="${APP_DART_SCRIPT_URI}"
  )

  if(UNIX AND NOT APPLE)
    target_link_options("${target_name}" PRIVATE "-Wl,--export-dynamic")
  endif()

  if(NOT APP_RUNTIME_FLAVOR STREQUAL "jit_source")
    add_custom_command(TARGET "${target_name}" POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
              "${APP_PROGRAM_ARTIFACT}"
              "$<TARGET_FILE_DIR:${target_name}>/program.bin"
      COMMENT "Copying Dart program artifact next to ${target_name}"
    )
  endif()

  if(EXISTS "${DARTSDK_VM_PLATFORM_DILL}")
    add_custom_command(TARGET "${target_name}" POST_BUILD
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
              "${DARTSDK_VM_PLATFORM_DILL}"
              "$<TARGET_FILE_DIR:${target_name}>/vm_platform_strong.dill"
    )
  endif()
endfunction()
