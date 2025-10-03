import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/usage_provider.dart';
import 'src/screens/home_screen.dart';


void main() {
  runApp(const ScreenTimeProApp());
}


class ScreenTimeProApp extends StatelessWidget {
  const ScreenTimeProApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ScreenTimePro',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0F1724),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}