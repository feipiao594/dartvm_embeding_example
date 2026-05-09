# dartvm_embeding_example

This folder is the in-tree template project.

What you edit:

- `lib/main.dart`: Dart application code
- `src/main.cpp`: native host / FFI surface

What the template hides in `internal/`:

- JIT vs AOT artifact generation
- choosing the matching `dartvm_embed_lib_*` target
- choosing source-vs-kernel JIT startup from the flavor itself
- wiring the host to the generated Dart artifact with explicit absolute paths

Configure `CMakeLists.txt` from the repository root:

```cmake
set(APP_EMBED_INSTALL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../lib_install")
```

set `APP_EMBED_INSTALL_DIR` as your `dartvm_embeding_lib` release product path and run