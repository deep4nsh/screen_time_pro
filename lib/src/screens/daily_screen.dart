import 'package:flutter/material.dart';
import '../models/app_usage.dart';
import '../services/usage_service.dart';
import '../widgets/usage_bar_chart.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

class DailyScreen extends StatefulWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> with AutomaticKeepAliveClientMixin {
  final UsageService _service = UsageService();
  List<AppUsage> _apps = [];
  bool _loading = true;
  bool _hasPermission = false;
  StreamSubscription<List<AppUsage>>? _subscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkAndLoadData();
  }

  Future<void> _checkAndLoadData() async {
    setState(() => _loading = true);

    _hasPermission = await _service.checkPermission();

    if (_hasPermission) {
      // Cancel existing subscription if any
      await _subscription?.cancel();

      // Fetch initial data
      try {
        final initialData = await _service.fetchUsageOnce();
        setState(() {
          _apps = initialData..sort((a, b) => b.timeInForeground.compareTo(a.timeInForeground));
        });
      } catch (e) {
        print('Error fetching initial data: $e');
      }

      // Start real-time updates
      _subscription = _service.getUsageStream().listen(
            (apps) {
          if (mounted) {
            setState(() {
              _apps = apps..sort((a, b) => b.timeInForeground.compareTo(a.timeInForeground));
              _loading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _loading = false);
          }
          print('Error loading usage data: $error');
        },
      );
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Uint8List decodeIcon(String base64Str) => base64Decode(base64Str);

  String formatDuration(int millis) {
    final seconds = millis ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    return "${hours}h ${minutes % 60}m";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Usage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAndLoadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Usage Access Permission Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please grant usage access permission to view app statistics.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await _service.openSettings();
                // Wait a bit then recheck
                await Future.delayed(const Duration(seconds: 1));
                _checkAndLoadData();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      )
          : _apps.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No usage data available',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use some apps and data will appear here',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkAndLoadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          UsageBarChart(usages: _apps),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                return ListTile(
                  leading: app.iconBase64.isNotEmpty
                      ? Image.memory(
                    decodeIcon(app.iconBase64),
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.apps);
                    },
                  )
                      : const Icon(Icons.apps),
                  title: Text(app.appName),
                  subtitle: Text(formatDuration(app.timeInForeground)),
                  trailing: Text(
                    '${(app.timeInForeground / 3600000).toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}