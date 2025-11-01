import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/pv_data_provider.dart';
import '../../models/pv_data.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _selectedMetric = 'power';
  String _selectedTimeRange = '12h';
  int _currentPage = 0;
  final int _itemsPerPage = 10; // 10 items per page for pagination

  final Map<String, String> _metrics = {
    'power': 'Power (W)',
    'energy': 'Energy (Wh)',
    'voltage': 'Voltage (V)',
    'temperature': 'Temperature (°C)',
    'humidity': 'Humidity (%)',
    'light': 'Light (lux)',
  };

  final Map<String, Duration> _timeRanges = {
    '6h': Duration(hours: 6),
    '12h': Duration(hours: 12),
    '24h': Duration(hours: 24),
    '7d': Duration(days: 7),
  };

  // Get appropriate date format based on time range
  String _getDateFormat() {
    switch (_selectedTimeRange) {
      case '6h':
      case '12h':
        return 'HH:mm';
      case '24h':
        return 'HH:mm';
      case '7d':
        return 'MM/dd';
      default:
        return 'HH:mm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Analytics'),
      ),
      body: Consumer<PVDataProvider>(
        builder: (context, pvProvider, child) {
          if (pvProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (pvProvider.historyData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No historical data available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data will appear here once your system starts reporting',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Get 100 history values for pagination
          final allHistoryData = pvProvider.getHistory100();

          // Get filtered data for charts (based on time range)
          final filteredData = pvProvider.getHistoryForTimeRange(_timeRanges[_selectedTimeRange]!);

          // Pagination logic for history list (10 items per page)
          final bool needsPagination = allHistoryData.length > _itemsPerPage;
          final int totalPages = (allHistoryData.length / _itemsPerPage).ceil();
          final int startIndex = _currentPage * _itemsPerPage;
          final int endIndex = (startIndex + _itemsPerPage) > allHistoryData.length ? allHistoryData.length : startIndex + _itemsPerPage;
          final List<PVHistoryData> paginatedData = allHistoryData.sublist(startIndex, endIndex);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Controls
                _buildControls().animate().slideY(begin: -0.3, delay: 100.ms, duration: 600.ms).fadeIn(delay: 100.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Chart
                _buildChart(filteredData).animate().slideY(begin: 0.3, delay: 200.ms, duration: 600.ms).fadeIn(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Statistics
                _buildStatistics(filteredData).animate().slideY(begin: 0.3, delay: 300.ms, duration: 600.ms).fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Recent Data List with Pagination
                _buildRecentDataList(paginatedData, needsPagination, totalPages, allHistoryData.length)
                    .animate()
                    .slideY(begin: 0.3, delay: 400.ms, duration: 600.ms)
                    .fadeIn(delay: 400.ms, duration: 600.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      child: Container(
        width: double.infinity, // Make container fit full width
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chart Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Metric Selection
            Text(
              'Metric',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _metrics.entries.map((entry) {
                final isSelected = _selectedMetric == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMetric = entry.key;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Time Range Selection
            Text(
              'Time Range',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _timeRanges.keys.map((range) {
                final isSelected = _selectedTimeRange == range;
                return ChoiceChip(
                  label: Text(range),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimeRange = range;
                        _currentPage = 0; // Reset to first page when changing time range
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<PVHistoryData> data) {
    if (data.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Text('No data available for selected time range'),
          ),
        ),
      );
    }

    final spots = data.reversed.take(100).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      double value;

      switch (_selectedMetric) {
        case 'power':
          value = item.power;
          break;
        case 'energy':
          value = item.energy;
          break;
        case 'voltage':
          value = item.voltage;
          break;
        case 'temperature':
          value = item.temperature;
          break;
        case 'humidity':
          value = item.humidity;
          break;
        case 'light':
          value = item.light;
          break;
        default:
          value = 0;
      }

      return FlSpot(index.toDouble(), value);
    }).toList();

    // Calculate appropriate intervals for grid lines based on data range
    double horizontalInterval = 1;
    if (spots.isNotEmpty) {
      final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      final range = maxY - minY;

      // Reduce grid lines for large value ranges (power and light)
      if (range > 3000) {
        horizontalInterval = range / 5; // Show ~5 horizontal lines
      } else if (range > 1000) {
        horizontalInterval = range / 4; // Show ~4 horizontal lines
      } else {
        horizontalInterval = range / 3; // Show ~3 horizontal lines
      }

      // Ensure minimum interval of 1
      horizontalInterval = horizontalInterval < 1 ? 1 : horizontalInterval;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _metrics[_selectedMetric]!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                key: ValueKey('$_selectedMetric-$_selectedTimeRange'),
                duration: Duration.zero, // Disable animation for immediate updates
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: horizontalInterval, // Dynamic interval based on data range
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: spots.length > 10 ? spots.length / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            final item = data.reversed.toList()[value.toInt()];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat(_getDateFormat()).format(item.dateTime),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7), // White with 0.7 opacity
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: null,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          String formattedValue;
                          if (value.abs() >= 1000) {
                            formattedValue = '${(value / 1000).toStringAsFixed(1)}k';
                          } else {
                            formattedValue = value.toStringAsFixed(1);
                          }
                          return Text(
                            formattedValue,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7), // White with 0.7 opacity
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  minX: 0,
                  maxX: spots.isNotEmpty ? spots.last.x : 0,
                  minY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.9 : 0,
                  maxY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1 : 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.3),
                            Theme.of(context).primaryColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 10,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final value = touchedSpot.y;
                          return LineTooltipItem(
                            value.toStringAsFixed(2),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                      // Handle touch events if needed
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(List<PVHistoryData> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    double getValue(PVHistoryData item) {
      switch (_selectedMetric) {
        case 'power':
          return item.power;
        case 'energy':
          return item.energy;
        case 'voltage':
          return item.voltage;
        case 'temperature':
          return item.temperature;
        case 'humidity':
          return item.humidity;
        case 'light':
          return item.light;
        default:
          return 0;
      }
    }

    final values = data.map(getValue).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Average', avg.toStringAsFixed(2), Colors.blue),
                _buildStatItem('Maximum', max.toStringAsFixed(2), Colors.green),
                _buildStatItem('Minimum', min.toStringAsFixed(2), Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildRecentDataList(List<PVHistoryData> data, bool needsPagination, int totalPages, int totalCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Readings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (needsPagination)
                  Text(
                    'Total: $totalCount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.map((item) => _buildDataItem(item)).toList(),
            if (needsPagination) ...[
              const SizedBox(height: 16),
              _buildPaginationControls(totalPages),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(PVHistoryData data) {
    return GestureDetector(
      onTap: () {
        // Show detailed values when tapped
        _showDetailedDataDialog(context, data);
      },
      child: Container(
        color: Colors.transparent, // Make the entire container tappable
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm:ss').format(data.dateTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${data.power.toStringAsFixed(1)}W • '
                      'E: ${data.energy.toStringAsFixed(1)}Wh • '
                      'V: ${data.voltage.toStringAsFixed(1)}V • '
                      'T: ${data.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Removed the arrow icon
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedDataDialog(BuildContext context, PVHistoryData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reading Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date and time
              Text(
                DateFormat('MMM dd, yyyy HH:mm:ss').format(data.dateTime),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 20),

              // Detailed metrics in a grid
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate item width with proper spacing to prevent overflow
                  final spacing = 12.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2 - spacing;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      _buildDetailCard(
                        context,
                        'Power',
                        '${data.power.toStringAsFixed(1)} W',
                        Icons.flash_on,
                        Colors.green,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Energy',
                        '${data.energy.toStringAsFixed(1)} Wh',
                        Icons.electrical_services,
                        Colors.blue,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Voltage',
                        '${data.voltage.toStringAsFixed(1)} V',
                        Icons.bolt,
                        Colors.orange,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Temp',
                        '${data.temperature.toStringAsFixed(1)} °C',
                        Icons.thermostat,
                        Colors.red,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Humidity',
                        '${data.humidity.toStringAsFixed(1)} %',
                        Icons.water,
                        Colors.lightBlue,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Light',
                        '${data.light.toStringAsFixed(0)} lux',
                        Icons.wb_sunny,
                        Colors.amber,
                        itemWidth,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Close button
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 10), // Add some bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              '${_currentPage + 1} / $totalPages',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
