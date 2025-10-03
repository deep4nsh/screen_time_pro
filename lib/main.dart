import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import 'services/usage_service.dart';
import 'models/usage_models.dart';
import 'widgets/daily_view.dart';
import 'widgets/weekly_view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScreenTimeProApp());
}


class ScreenTimeProApp extends StatelessWidget {
  const ScreenTimeProApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UsageService()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ScreenTimePro',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              scaffoldBackgroundColor: const Color(0xFFF8FAFF),
              appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
            ),
          home: const HomePage(),
        ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UsageService _usageService;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
// request initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usageService = Provider.of<UsageService>(context, listen: false);
      _usageService.initialize();
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScreenTimePro', style: TextStyle(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Daily'), Tab(text: 'Weekly')],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [DailyView(), WeeklyView()],
      ),
    );
  }
}