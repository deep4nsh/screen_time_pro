import 'package:flutter/material.dart';
import 'daily_screen.dart';
import 'weekly_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Week'), Tab(text: 'Day')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [WeeklyScreen(), DailyScreen()],
      ),
    );
  }
}