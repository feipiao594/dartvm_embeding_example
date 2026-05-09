# App Starter

This folder is the in-tree starter project.

What you edit:

- `lib/main.dart`: Dart application code
- `src/main.cpp`: native host / FFI surface

What the starter hides in `internal/`:

- JIT vs AOT artifact generation
- choosing the matching `dartvm_embed_lib_*` target
- choosing source-vs-kernel JIT startup from the flavor itself
- wiring the host to the generated Dart artifact with explicit absolute paths

Configure from the repository root:

```bash
cmake --install build --prefix lib_install
cmake -S example -B example/build -G Ninja \
  -DAPP_RUNTIME_FLAVOR=jit \
cmake --build example/build
cd example/build
./app
```

For JIT hot reload:

```bash
cmake --install build --prefix lib_install
cmake -S example -B example/build -G Ninja \
  -DAPP_RUNTIME_FLAVOR=jit_source
cmake --build example/build
cd example/build
./app
```

For AOT:

```bash
cmake --install build --prefix lib_install
cmake -S example -B example/build -G Ninja \
  -DAPP_RUNTIME_FLAVOR=aot
cmake --build example/build
cd example/build
./app
```
