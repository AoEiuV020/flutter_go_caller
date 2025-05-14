import 'package:flutter/material.dart';
import 'package:flutter_go_caller/flutter_go_caller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'goCall Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'goCall Demo increase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter = goCall('Sum', {'a': _counter, 'b': 1})['result'];
    });
  }

  Future<void> _incrementCounterAsync() async {
    final result = await goCallAsync('SumLongRunning', {'a': _counter, 'b': 1});
    setState(() {
      _counter = result['result'];
    });
  }

  // 添加新方法调用increase函数
  void _incrementViaIncrease() {
    setState(() {
      _counter = goCall('Increase', {})['result'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _incrementCounterAsync,
            tooltip: 'Increment Async',
            child: const Icon(Icons.timer),
          ),
          const SizedBox(width: 16),
          // 添加调用increase函数的按钮
          FloatingActionButton(
            onPressed: _incrementViaIncrease,
            tooltip: 'Global Increment',
            child: const Icon(Icons.plus_one),
          ),
        ],
      ),
    );
  }
}
