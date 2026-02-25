# external_consumer_demo

This folder simulates a third-party project consuming `dartvm_embed_lib` as a CMake package. Serve as an example for use this package

## about dart

you can use this command to use dart tools compile by `dartvm_embed_lib` library

> note: before this, you need configure cmake first for download library

```bash
export PATH="$PWD/build/_deps/dartvm_sdk-src/share/dartvm_embed_lib/dart-sdk/out/ReleaseX64/dart-sdk/bin:$PATH"
```