import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/pv_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_indicator.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PV System Monitor'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            authProvider.signOut();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<PVDataProvider>(
        builder: (context, pvProvider, child) {
          if (pvProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (pvProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pvProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      pvProvider.clearError();
                      pvProvider.startListening();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currentData = pvProvider.currentData;
          final isOnline = currentData != null;

          return RefreshIndicator(
            onRefresh: () async {
              pvProvider.startListening();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          StatusIndicator(
                            isOnline: isOnline,
                            lastUpdate: pvProvider.systemData?.lastConnectedTime ?? currentData?.dateTime,
                          ),
                          if (pvProvider.systemData?.lastConnectedTime != null || currentData?.timestamp != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Last updated: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(
                                pvProvider.systemData?.lastConnectedTime ?? currentData!.dateTime,
                              )}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.3, delay: 100.ms, duration: 600.ms)
                      .fadeIn(delay: 100.ms, duration: 600.ms),

                  const SizedBox(height: 20),

                  // Current Values Grid
                  Text(
                    'Current Values',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .slideX(begin: -0.3, delay: 200.ms, duration: 600.ms)
                      .fadeIn(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      MetricCard(
                        title: 'Current',
                        value: currentData?.current.toStringAsFixed(1) ?? '--',
                        unit: 'A',
                        icon: Icons.flash_on,
                        color: Colors.amber,
                      )
                          .animate()
                          .scale(delay: 300.ms, duration: 600.ms)
                          .fadeIn(delay: 300.ms, duration: 600.ms),

                      MetricCard(
                        title: 'Voltage',
                        value: currentData?.voltage.toStringAsFixed(1) ?? '--',
                        unit: 'V',
                        icon: Icons.electrical_services,
                        color: Colors.blue,
                      )
                          .animate()
                          .scale(delay: 350.ms, duration: 600.ms)
                          .fadeIn(delay: 350.ms, duration: 600.ms),

                      MetricCard(
                        title: 'Power',
                        value: currentData?.power.toStringAsFixed(1) ?? '--',
                        unit: 'W',
                        icon: Icons.power,
                        color: Colors.green,
                      )
                          .animate()
                          .scale(delay: 400.ms, duration: 600.ms)
                          .fadeIn(delay: 400.ms, duration: 600.ms),

                      MetricCard(
                        title: 'Temperature',
                        value: currentData?.temperature.toStringAsFixed(1) ?? '--',
                        unit: '°C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                      )
                          .animate()
                          .scale(delay: 450.ms, duration: 600.ms)
                          .fadeIn(delay: 450.ms, duration: 600.ms),

                      MetricCard(
                        title: 'Humidity',
                        value: currentData?.humidity.toStringAsFixed(1) ?? '--',
                        unit: '%',
                        icon: Icons.water_drop,
                        color: Colors.cyan,
                      )
                          .animate()
                          .scale(delay: 500.ms, duration: 600.ms)
                          .fadeIn(delay: 500.ms, duration: 600.ms),

                      MetricCard(
                        title: 'Light',
                        value: currentData?.light.toStringAsFixed(0) ?? '--',
                        unit: 'lux',
                        icon: Icons.wb_sunny,
                        color: Colors.yellow[700]!,
                      )
                          .animate()
                          .scale(delay: 550.ms, duration: 600.ms)
                          .fadeIn(delay: 550.ms, duration: 600.ms),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats
                  if (pvProvider.historyData.isNotEmpty) ...[
                    Text(
                      'Today\'s Summary',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .slideX(begin: -0.3, delay: 600.ms, duration: 600.ms)
                        .fadeIn(delay: 600.ms, duration: 600.ms),

                    const SizedBox(height: 16),

                    _buildSummaryCard(context, pvProvider),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, PVDataProvider pvProvider) {
    final todayData = pvProvider.getHistoryForTimeRange(const Duration(days: 1));
    
    if (todayData.isEmpty) {
      return const SizedBox.shrink();
    }

    final avgPower = todayData.map((e) => e.power).reduce((a, b) => a + b) / todayData.length;
    final maxPower = todayData.map((e) => e.power).reduce((a, b) => a > b ? a : b);
    final avgTemp = todayData.map((e) => e.temperature).reduce((a, b) => a + b) / todayData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Avg Power',
                  '${avgPower.toStringAsFixed(1)} W',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Peak Power',
                  '${maxPower.toStringAsFixed(1)} W',
                  Icons.flash_on,
                  Colors.amber,
                ),
                _buildSummaryItem(
                  context,
                  'Avg Temp',
                  '${avgTemp.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, delay: 650.ms, duration: 600.ms)
        .fadeIn(delay: 650.ms, duration: 600.ms);
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
