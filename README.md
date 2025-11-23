# flutter_go_caller

Golang FFI 插件项目，用于 Flutter 跨平台开发中调用 Go 函数

## 项目概述

本项目通过 Go 语言实现跨平台原生功能，编译为 android/ios/windows/linux/macos/web 全平台原生库供 Flutter 调用。提供了简洁的 API 接口，使得在 Flutter 应用中调用 Go 函数变得简单高效。

**特别说明**：本项目不是标准的 pub.dev 依赖包，而是需要直接复制到您的项目中使用。通过编写自定义 Go 代码并构建预编译库，然后使用提供的 API 接口在 Flutter 中调用。这种方式允许您充分利用 Go 语言的跨平台优势，为 Flutter 应用添加原生功能支持。

[查看模块说明](packages/flutter_go_caller/README.md)
