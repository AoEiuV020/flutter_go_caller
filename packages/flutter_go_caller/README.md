# flutter_go_caller

Golang FFI 插件项目，用于 Flutter 跨平台开发中调用 Go 函数

## 项目概述

本项目通过 Go 语言实现跨平台原生功能，编译为 android/ios/windows/linux/macos/web 全平台原生库供 Flutter 调用。提供了简洁的 API 接口，使得在 Flutter 应用中调用 Go 函数变得简单高效。

**特别说明**：本项目不是标准的 pub.dev 依赖包，而是需要直接复制到您的项目中使用。通过编写自定义 Go 代码并构建预编译库，然后使用提供的 API 接口在 Flutter 中调用。这种方式允许您充分利用 Go 语言的跨平台优势，为 Flutter 应用添加原生功能支持。

## 核心功能

本项目主要封装了两个核心 API，用于在 Flutter 中调用 Go 函数：

1. **同步调用接口**：`goCall` - 适用于快速执行的操作
2. **异步调用接口**：`goCallAsync` - 适用于可能耗时较长的操作

```dart
// 同步调用示例
Map<String, dynamic> result = goCall("方法名", {"参数名": "参数值"});

// 异步调用示例
Future<Map<String, dynamic>> result = goCallAsync("方法名", {"参数名": "参数值"});
```

调用结果会自动解析为 Dart 中的 `Map<String, dynamic>` 对象，如果返回的 JSON 结果包含 error 字段，将自动抛出异常。

## 项目结构

本项目使用以下结构：

* `go/`: 包含 Go 语言源代码和编译脚本，用于构建跨平台的原生库。

* `lib/`: 包含插件的 Dart 代码实现，定义了插件的 API 并通过 `dart:ffi` 调用原生代码。

* 平台文件夹 (`android`, `ios`, `windows` 等): 包含用于构建和打包原生库的构建文件。

## 快速开始

### 测试环境

- Go 1.24.3
- Flutter 3.29.3
- Make 3.81
- 各平台构建工具（Android NDK、Xcode 等）

### 使用方法

本项目不能通过常规依赖方式添加使用，需要按照以下步骤操作：

1. 复制整个项目到您的工作目录
2. 编写自定义 Go 代码
3. 通过 `make` 命令构建预编译库到 `prebuild` 目录
4. 在您的 Flutter 应用中通过 `goCall` 和 `goCallAsync` API 调用 Go 函数

### 构建命令

进入 go 项目目录 [./go/](./go/)，执行以下命令：

```bash
# 构建所有平台，ios/mac/windows/linux 需要在各自平台下执行
make android
make ios
make windows
make linux
make macos
make web
```

## 平台集成指南

### 通用说明

- 所有构建产物位于 [./prebuild/](./prebuild/) 目录，按照平台和架构命名放置
- 所有预编译库的名字都写死为插件名字，如 `libflutter_go_caller.so`，以便统一以及复用默认的 DynamicLibrary.open 代码

### Android

修改 [./android/build.gradle](./android/build.gradle) 配置：

```gradle
android {
    sourceSets {
        main {
            jniLibs.srcDirs = ["${project.projectDir}/../prebuild/Android"]
        }
    }
}
```

### iOS/macOS

修改 [./ios/flutter_go_caller.podspec](./ios/flutter_go_caller.podspec) 和 [./macos/flutter_go_caller.podspec](./macos/flutter_go_caller.podspec)：

- 使用 `force_load` 加载静态库
- 修改后需清除 Flutter app 模块的 build 缓存

**重要**: iOS 和 macOS 的实现文件中包含自动生成的 `#include` 指令，这些需要特殊处理：

在 `ios/Classes/flutter_go_caller.c` 和 `macos/Classes/flutter_go_caller.c` 中，自动生成的包含源代码的 `#include` 指令需要被删除或注释。这是因为 FFI 插件模板会自动生成这些文件，但由于我们使用预编译库而非源代码编译，这些 include 需要移除：

```c
// 删除或注释掉如下行：
// #include "../../go/main.go"
```

### Windows/Linux

修改 [./windows/CMakeLists.txt](./windows/CMakeLists.txt) 和 [./linux/CMakeLists.txt](./linux/CMakeLists.txt)：

- 直接设置预编译库到 flutter_go_caller_bundled_libraries

### Web

对于 Web 平台，需要特别注意以下步骤：

1. 复制 `prebuild/Web` 到您的 Flutter 应用的 web/prebuild/ 目录
2. 修改您的 Flutter 应用的 `web/index.html` 文件，参考 `example/web/index.html` 添加以下配置：

```html
<!-- 添加 Go 的 wasm 执行环境支持 -->
<script src="prebuild/wasm_exec.js"></script>
<script>
  // 初始化 Go wasm 环境
  const go = new Go();
  WebAssembly.instantiateStreaming(fetch("prebuild/libflutter_go_caller.wasm"), go.importObject).then((result) => {
    go.run(result.instance);
  });
</script>
```

这样可以确保 Web 平台下 Go 函数能够正确加载和执行。

## 使用示例

### 基本调用示例

```dart
import 'package:flutter_go_caller/flutter_go_caller.dart';

// 同步调用 Go 函数
void callGoFunction() {
  try {
    final result = goCall('SayHello', {'name': 'Flutter'});
    print('Go 函数返回: ${result['message']}');
  } catch (e) {
    print('调用出错: $e');
  }
}

// 异步调用 Go 函数
Future<void> callGoFunctionAsync() async {
  try {
    final result = await goCallAsync('ProcessData', {'data': 'Some data to process'});
    print('异步处理结果: ${result['result']}');
  } catch (e) {
    print('异步调用出错: $e');
  }
}
```

## 高级用法

### 错误处理

所有 Go 函数返回的错误都会被转换为 Dart 的异常，可以使用 try-catch 捕获：

```dart
try {
  final result = goCall('SomeFunction', {'param': 'value'});
  // 处理结果
} catch (e) {
  // 处理错误
  print('错误: $e');
}
```

### 自定义 Go 函数开发

本项目已经在 `go/call.go` 中封装了 JSON 参数的解析和结果的序列化处理。开发新功能时，您只需要在 `Execute` 函数中添加新的 case 分支处理即可：

1. 在 `go/call.go` 文件中的 `Execute` 函数内添加新的 case
2. 从 params map 中获取并验证参数
3. 调用您的业务处理函数并设置结果

示例代码：

```go
// 在 go/call.go 的 Execute 函数中添加新的 case
func Execute(method string, params map[string]interface{}) map[string]interface{} {
    result := make(map[string]interface{})
    
    // 封装所有可能的异常
    defer func() {
        if r := recover(); r != nil {
            result["error"] = fmt.Sprintf("发生未捕获的异常: %v", r)
        }
    }()
    
    // 根据方法名调用不同函数
    switch method {
    // ...已有的 case...
    
    case "YourFunction":
        // 提取参数
        param1, ok1 := params["param1"]
        param2, ok2 := params["param2"]
        if !ok1 || !ok2 {
            result["error"] = "缺少必要参数 param1 或 param2"
            return result
        }
        
        // 参数类型转换与验证
        param1Str, ok := param1.(string)
        if !ok {
            result["error"] = fmt.Sprintf("参数 param1 类型错误: 期望字符串, 实际 %T", param1)
            return result
        }
        
        // 调用您的业务处理函数
        processResult := YourBusinessLogic(param1Str, param2)
        
        // 设置返回结果
        result["result"] = processResult
        // 可以添加更多返回字段
        result["extraInfo"] = "附加信息"
    
    default:
        result["error"] = fmt.Sprintf("未知方法: %s", method)
    }
    
    return result
}

// 业务逻辑函数
func YourBusinessLogic(param1 string, param2 interface{}) string {
    // 实现您的业务逻辑
    return "处理结果"
}
```

构建完成后，可以在 Flutter 中这样调用:

```dart
// 调用您的自定义函数
final result = goCall('YourFunction', {'param1': 'value1', 'param2': 'value2'});
print(result['result']); // 输出: 处理结果
print(result['extraInfo']); // 输出: 附加信息
```

**注意**：编写新的 case 后，需要重新执行 `make` 命令构建预编译库，然后重新构建 Flutter 应用才能使新函数生效。

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

