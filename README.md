# external_consumer_demo

This folder simulates a third-party project consuming `dartvm_embed_lib` as a CMake package.

It intentionally uses a local path package in `pubspec.yaml` so `dart pub get` works without internet.

## Install provider package

```bash
cd ../dartvm_embed_lib
cmake --preset jit
cmake --build --preset jit-build
cmake --install build/jit --prefix /tmp/dartvm_embed_install
```

## Build consumer

```bash
cd ../external_consumer_demo

# jit
cmake --preset jit
cmake --build --preset jit-build

# aot
cmake --preset aot
cmake --build --preset aot-build
```

## Run

```bash
./build/jit/external_consumer_demo

./build/aot/external_consumer_demo
```
