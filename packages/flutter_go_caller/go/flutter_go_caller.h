
// 通用调用接口，根据方法名和JSON参数字符串调用对应函数
// 参数:
// - method: 要调用的方法名
// - paramJSON: 包含参数的JSON字符串
// 返回值: 包含执行结果的JSON字符串
// 注意: 调用方需要负责释放返回的字符串内存，使用go_free_string函数
char* go_call(const char* method, const char* paramJSON);

// 非常重要：您必须提供一个函数来释放 sum_string 返回的内存
void go_free_string(char* str);
