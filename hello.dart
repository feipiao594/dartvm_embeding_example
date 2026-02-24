import 'dart:ffi' as ffi;

typedef NativeSimplePrintInt = ffi.Void Function(ffi.Int64);
typedef DartSimplePrintInt = void Function(int);

void main() {
  final dylib = ffi.DynamicLibrary.executable();
  final printInt = dylib.lookupFunction<NativeSimplePrintInt, DartSimplePrintInt>(
    'SimplePrintInt',
  );
  printInt(20260224);
}
