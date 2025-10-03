import 'package:flutter/material.dart';
import 'usage_stats_helper.dart';

class UsageScreen extends StatefulWidget {
  @override
  _UsageScreenState createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  List<Map<String, dynamic>> apps = [];

  Future<void> loadUsage() async {
    final data = await UsageStatsHelper.getUsageStats();
    setState(() {
      apps = data;
    });
  }

  @override
  void initState() {
    super.initState();
    UsageStatsHelper.requestUsagePermission(); // asks for access
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("App Usage")),
      body: apps.isEmpty
          ? Center(
        child: ElevatedButton(
          onPressed: loadUsage,
          child: Text("Load Usage Data"),
        ),
      )
          : ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return ListTile(
            title: Text(app["packageName"]),
            subtitle: Text(
              "Time in foreground: ${Duration(milliseconds: app["totalTimeInForeground"]).inMinutes} min",
            ),
          );
        },
      ),
    );
  }
}
