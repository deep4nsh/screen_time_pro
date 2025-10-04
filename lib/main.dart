import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/usage_provider.dart';
import 'src/screens/daily_screen.dart';
import 'src/screens/weekly_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UsageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 0;

  final tabs = const [
    DailyScreen(),
    WeeklyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Screen Time Pro')),
        body: tabs[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Daily'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Weekly'),
          ],
        ),
      ),
    );
  }
}
