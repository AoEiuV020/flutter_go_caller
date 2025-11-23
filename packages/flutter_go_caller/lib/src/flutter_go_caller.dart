import 'dart:convert';

import 'flutter_go_caller_io.dart'
    if (dart.library.html) 'flutter_go_caller_web.dart'
    as native;

/// 通用调用接口，根据方法名和JSON参数字符串调用对应的Go函数
///
/// 参数:
///   - method: 要调用的方法名
///   - params: 包含参数的Map对象
///
/// 返回: 解析后的结果Map对象
///
/// 异常:
///   - 如果返回的JSON结果包含error字段，将抛出异常
Map<String, dynamic> goCall(String method, Map<String, dynamic> params) {
  // 将Map转换为JSON字符串
  final paramJSON = jsonEncode(params);

  // 调用底层native实现
  final resultJSON = native.goCall(method, paramJSON);

  // 解析返回的JSON字符串
  final resultMap = jsonDecode(resultJSON) as Map<String, dynamic>;

  // 检查是否包含error字段
  if (resultMap.containsKey('error') && resultMap['error'] != null) {
    throw Exception(resultMap['error']);
  }

  return resultMap;
}

/// 异步通用调用接口，适用于可能耗时较长的操作
///
/// 参数:
///   - method: 要调用的方法名
///   - params: 包含参数的Map对象
///
/// 返回: Future<Map<String, dynamic>>，解析后的结果Map对象
///
/// 异常:
///   - 如果返回的JSON结果包含error字段，将抛出异常
Future<Map<String, dynamic>> goCallAsync(
  String method,
  Map<String, dynamic> params,
) async {
  // 将Map转换为JSON字符串
  final paramJSON = jsonEncode(params);

  // 调用底层native异步实现
  final resultJSON = await native.goCallAsync(method, paramJSON);

  // 解析返回的JSON字符串
  final resultMap = jsonDecode(resultJSON) as Map<String, dynamic>;

  // 检查是否包含error字段
  if (resultMap.containsKey('error') && resultMap['error'] != null) {
    throw Exception(resultMap['error']);
  }

  return resultMap;
}
