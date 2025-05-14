// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'go_web.dart';
import 'dart:html' as html;

JSWindow get jsWindow => html.window as JSWindow;

/// Web版本的同步go_call实现
///
/// 调用JavaScript中的go_call函数，同步返回结果
///
/// 参数:
///   - method: 要调用的方法名
///   - paramJSON: 包含参数的JSON字符串
///
/// 返回: 执行结果的JSON字符串
String goCall(String method, String paramJSON) {
  return jsWindow.go_call(method, paramJSON);
}

/// Web版本的异步go_call_async实现
///
/// 调用JavaScript中的go_call_async函数，异步返回结果
/// 适用于可能耗时较长的操作，避免阻塞主线程
///
/// 参数:
///   - method: 要调用的方法名
///   - paramJSON: 包含参数的JSON字符串
///
/// 返回: Future<String>，包含执行结果的JSON字符串
Future<String> goCallAsync(String method, String paramJSON) async {
  final result = await jsWindow.go_call_async(method, paramJSON).toDart;
  return result.toDart;
}
