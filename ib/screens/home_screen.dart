import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/scroll_counter_provider.dart';
import '../services/accessibility_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AccessibilityServiceController _serviceController;

  @override
  void initState() {
    super.initState();
    _serviceController = AccessibilityServiceController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Counter'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ScrollCounterProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Service Status Card
                _buildServiceCard(context, provider),
                const SizedBox(height: 24),

                // Main Counter Display
                _buildCounterCard(provider),
                const SizedBox(height: 24),

                // Progress Bar
                _buildProgressCard(provider),
                const SizedBox(height: 24),

                // Streak Card
                _buildStreakCard(provider),
                const SizedBox(height: 24),

                // Weekly Chart
                if (provider.logs.isNotEmpty) ...[
                  _buildWeeklyChart(provider),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                _buildActionButtons(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ScrollCounterProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: provider.serviceRunning ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accessibility Service',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    provider.serviceRunning
                        ? 'Running - Counting scrolls'
                        : 'Disabled - Enable in Settings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: provider.serviceRunning,
              onChanged: (value) async {
                if (value) {
                  // Request accessibility service permission
                  _serviceController.requestAccessibilityPermission(context);
                } else {
                  provider.toggleService(false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(ScrollCounterProvider provider) {
    final isBudgetExceeded = provider.budgetExceeded;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isBudgetExceeded
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text(
              'Today\'s Scrolls',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.scrollCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'of ${provider.dailyBudget}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
            if (isBudgetExceeded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚠️ Budget Exceeded',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ScrollCounterProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '${(provider.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: provider.progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  provider.budgetExceeded ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(ScrollCounterProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Streak',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                Text(
                  '${provider.streak} days',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ScrollCounterProvider provider) {
    final recentLogs = provider.logs.length > 7
        ? provider.logs.sublist(provider.logs.length - 7)
        : provider.logs;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    recentLogs.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: recentLogs[i].scrollCount.toDouble(),
                          color: recentLogs[i].achieved
                              ? Colors.green
                              : Colors.orange,
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ScrollCounterProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Reset Today\'s Count?'),
              content: const Text('This will clear today\'s scroll count.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.resetToday();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
        child: const Text(
          'Reset Count',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
