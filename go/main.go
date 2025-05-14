package main

import (
	"time"
)

// 全局计数器变量
var counter int = 0

// Increase 每次调用将全局计数器加一并返回
func Increase() int {
	counter++
	return counter
}

func Sum(a int, b int) int {
	return a + b
}

func SumLongRunning(a int, b int) int {
	time.Sleep(200 * time.Millisecond)
	return a + b
}
