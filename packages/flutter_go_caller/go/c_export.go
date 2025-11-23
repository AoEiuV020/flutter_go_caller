//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"unsafe"
)

//export go_call
func go_call(method *C.char, paramJSON *C.char) *C.char {
	result := Call(C.GoString(method), C.GoString(paramJSON))
	return C.CString(result)
}

//export go_free_string
func go_free_string(str *C.char) {
	// 使用 C.free 释放由 C.CString 分配的内存
	C.free(unsafe.Pointer(str))
}

func main() {
}
