//go:build wasm

package main

import (
	"syscall/js"
)

// PromiseFunc 定义需要被Promise化的函数类型
type PromiseFunc func(args []js.Value) interface{}

// ToPromise 将Go函数封装为返回Promise的JS函数
func ToPromise(fn PromiseFunc) js.Func {
	return js.FuncOf(func(this js.Value, args []js.Value) interface{} {
		// 创建Promise对象
		promise := js.Global().Get("Promise")

		// 返回一个新的Promise
		return promise.New(js.FuncOf(func(this js.Value, promiseArgs []js.Value) interface{} {
			resolve := promiseArgs[0]
			reject := promiseArgs[1]

			go func() {
				defer func() {
					if r := recover(); r != nil {
						// 捕获panic并reject
						reject.Invoke(js.ValueOf(r.(error).Error()))
					}
				}()

				// 执行实际函数
				result := fn(args)
				resolve.Invoke(js.ValueOf(result))
			}()

			return nil
		}))
	})
}

func registerCallbacks() {
	// 通用Call函数
	js.Global().Set("go_call", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
		method := args[0].String()
		paramJSON := args[1].String()
		return Call(method, paramJSON)
	}))

	// 通用Call函数
	js.Global().Set("go_call_async", ToPromise(func(args []js.Value) interface{} {
		method := args[0].String()
		paramJSON := args[1].String()
		return Call(method, paramJSON)
	}))
}

func main() {
	registerCallbacks()
	// 通知JS运行时WASM已准备就绪
	js.Global().Set("goWasmReady", js.ValueOf(true))
	// 保持程序运行
	select {}
}
