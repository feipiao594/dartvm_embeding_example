import 'dart:async';
import 'dart:ffi' as ffi;

typedef NativeSimplePrintInt = ffi.Void Function(ffi.Int64);
typedef DartSimplePrintInt = void Function(int);

int _value = 20260224;

void onTick(DartSimplePrintInt printInt) {
  _value += 100;
  printInt(_value);
}

Future<void> main() async {
  final dylib = ffi.DynamicLibrary.executable();
  final printInt = dylib.lookupFunction<NativeSimplePrintInt, DartSimplePrintInt>(
    'SimplePrintInt',
  );

  _value = 20260224;
  printInt(_value);
  Timer.periodic(const Duration(seconds: 2), (_) {
    onTick(printInt);
  });

  await Completer<void>().future;
}
