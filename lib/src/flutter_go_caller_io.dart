import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:isolate_manager/isolate_manager.dart';

import 'flutter_go_caller_bindings_generated.dart';

// 创建共享的isolate管理器
final _sharedIsolateManager = IsolateManager.createShared();

/// 通用调用接口，根据方法名和JSON参数字符串调用对应的Go函数
///
/// 该方法会同步调用Go函数，可能会阻塞主线程，
/// 对于可能耗时较长的操作，建议使用goCallAsync
///
/// 参数:
///   - method: 要调用的方法名
///   - paramJSON: 包含参数的JSON字符串
///
/// 返回: 包含执行结果的JSON字符串
String goCall(String method, String paramJSON) {
  // 1. 将 Dart 字符串转换为 C 字符串
  final Pointer<Utf8> methodPtr = method.toNativeUtf8();
  final Pointer<Utf8> paramPtr = paramJSON.toNativeUtf8();

  Pointer<Char> resultPtr = nullptr;

  try {
    // 2. 调用 Go 函数
    resultPtr = _bindings.go_call(
      methodPtr.cast<Char>(),
      paramPtr.cast<Char>(),
    );

    if (resultPtr == nullptr) {
      throw Exception("Go function returned a null pointer!");
    }

    // 3. 将返回的 C 字符串转换回 Dart 字符串
    return resultPtr.cast<Utf8>().toDartString();
  } finally {
    // 4. 释放输入参数的内存
    calloc.free(methodPtr);
    calloc.free(paramPtr);

    // 5. 释放 Go 函数返回的字符串的内存
    if (resultPtr != nullptr) {
      _bindings.go_free_string(resultPtr);
    }
  }
}

/// 通用调用接口的异步实现，使用isolate避免阻塞主线程
///
/// 该方法通过isolate在后台线程中调用Go函数，避免阻塞主线程
/// 适用于可能耗时较长的操作，如网络请求、文件操作等
///
/// 参数:
///   - method: 要调用的方法名
///   - paramJSON: 包含参数的JSON字符串
///
/// 返回: Future<String>，包含执行结果的JSON字符串
Future<String> goCallAsync(String method, String paramJSON) async {
  return _sharedIsolateManager.compute(_goCallWorker, [method, paramJSON]);
}

/// go_call的worker函数，在独立isolate中执行
@isolateManagerSharedWorker
String _goCallWorker(List<String> params) {
  final method = params[0];
  final paramJSON = params[1];
  return goCall(method, paramJSON);
}

const String _libName = 'flutter_go_caller';

/// The dynamic library in which the symbols for [FlutterGoCallerBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FlutterGoCallerBindings _bindings = FlutterGoCallerBindings(_dylib);

// 应用结束时停止isolate管理器
Future<void> disposeIsolates() async {
  await _sharedIsolateManager.stop();
}
