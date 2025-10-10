import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/prediction_provider.dart';
import '../../models/prediction_data.dart';

class AIPredictionTab extends StatefulWidget {
  const AIPredictionTab({super.key});

  @override
  State<AIPredictionTab> createState() => _AIPredictionTabState();
}

class _AIPredictionTabState extends State<AIPredictionTab> {
  String _selectedMetric = 'power';
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final Map<String, String> _metrics = {
    'power': 'Power (W)',
    'voltage': 'Voltage (V)',
    'temperature': 'Temperature (°C)',
    'humidity': 'Humidity (%)',
    'radiation': 'Solar Radiation',
    'windSpeed': 'Wind Speed (m/s)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Predictions'),
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, predictionProvider, child) {
          if (predictionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (predictionProvider.errorMessage != null) {
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
                    'Error loading predictions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      predictionProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          if (predictionProvider.predictions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No predictions available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trigger a prediction to see AI forecasts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trigger Button
                _buildTriggerButton(predictionProvider).animate().slideY(begin: -0.3, delay: 100.ms, duration: 600.ms).fadeIn(delay: 100.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Metric Selection
                _buildMetricSelector().animate().slideY(begin: 0.3, delay: 200.ms, duration: 600.ms).fadeIn(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Chart
                _buildChart(predictionProvider.predictions).animate().slideY(begin: 0.3, delay: 300.ms, duration: 600.ms).fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Statistics
                _buildStatistics(predictionProvider.predictions).animate().slideY(begin: 0.3, delay: 400.ms, duration: 600.ms).fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 20),

                // Predictions List
                _buildPredictionsList(predictionProvider.predictions).animate().slideY(begin: 0.3, delay: 500.ms, duration: 600.ms).fadeIn(delay: 500.ms, duration: 600.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTriggerButton(PredictionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Control',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isTriggering
                    ? null
                    : () async {
                        try {
                          await provider.triggerPrediction();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prediction triggered successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to trigger: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                icon: provider.isTriggering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  provider.isTriggering ? 'Triggering...' : 'Trigger Prediction',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Metric',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<PredictionData> data) {
    if (data.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Text('No prediction data available'),
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      double value;

      switch (_selectedMetric) {
        case 'power':
          value = item.power;
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
        case 'radiation':
          value = item.radiation;
          break;
        case 'windSpeed':
          value = item.windSpeed;
          break;
        default:
          value = 0;
      }

      return FlSpot(index.toDouble(), value);
    }).toList();

    // Calculate appropriate intervals
    double horizontalInterval = 1;
    if (spots.isNotEmpty) {
      final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      final range = maxY - minY;

      if (range > 3000) {
        horizontalInterval = range / 5;
      } else if (range > 1000) {
        horizontalInterval = range / 4;
      } else {
        horizontalInterval = range / 3;
      }

      horizontalInterval = horizontalInterval < 1 ? 1 : horizontalInterval;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predicted ${_metrics[_selectedMetric]!}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: horizontalInterval,
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
                            final item = data[value.toInt()];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat('HH:mm').format(item.time),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
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
                              color: Colors.white.withOpacity(0.7),
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
                          Colors.purple,
                          Colors.purple.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.purple.withOpacity(0.0),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(List<PredictionData> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    double getValue(PredictionData item) {
      switch (_selectedMetric) {
        case 'power':
          return item.power;
        case 'voltage':
          return item.voltage;
        case 'temperature':
          return item.temperature;
        case 'humidity':
          return item.humidity;
        case 'radiation':
          return item.radiation;
        case 'windSpeed':
          return item.windSpeed;
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
              'Prediction Statistics',
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
    String formattedValue;
    if (double.parse(value).abs() >= 1000) {
      formattedValue = '${(double.parse(value) / 1000).toStringAsFixed(1)}k';
    } else {
      formattedValue = double.parse(value).toStringAsFixed(1);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            formattedValue,
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

  Widget _buildPredictionsList(List<PredictionData> data) {
    final totalPages = (data.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, data.length);
    final paginatedData = data.sublist(startIndex, endIndex);

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
                  'Upcoming Predictions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Total: ${data.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...paginatedData.map((item) => _buildPredictionItem(item)).toList(),
            if (totalPages > 1) ...[
              const SizedBox(height: 16),
              _buildPaginationControls(totalPages),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          '$_currentPage / $totalPages',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPredictionItem(PredictionData data) {
    return GestureDetector(
      onTap: () {
        _showDetailedPredictionDialog(context, data);
      },
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(data.time),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Power: ${data.power.toStringAsFixed(1)}W • '
                      'Voltage: ${data.voltage.toStringAsFixed(1)}V • '
                      'Temp: ${data.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedPredictionDialog(BuildContext context, PredictionData data) {
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
                    'Prediction Details',
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
                DateFormat('MMM dd, yyyy HH:mm').format(data.time),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
              ),
              const SizedBox(height: 20),

              // Detailed metrics in a grid
              LayoutBuilder(
                builder: (context, constraints) {
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
                        'Radiation',
                        '${data.radiation.toStringAsFixed(0)}',
                        Icons.wb_sunny,
                        Colors.amber,
                        itemWidth,
                      ),
                      _buildDetailCard(
                        context,
                        'Wind Speed',
                        '${data.windSpeed.toStringAsFixed(1)} m/s',
                        Icons.air,
                        Colors.blueGrey,
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
              const SizedBox(height: 10),
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
    // Extract numeric part and unit from value string
    String formattedValue = value;
    try {
      final parts = value.split(' ');
      if (parts.isNotEmpty) {
        final numericValue = double.parse(parts[0]);
        final unit = parts.length > 1 ? ' ${parts.sublist(1).join(' ')}' : '';

        if (numericValue.abs() >= 1000) {
          formattedValue = '${(numericValue / 1000).toStringAsFixed(1)}k$unit';
        } else {
          formattedValue = '${numericValue.toStringAsFixed(1)}$unit';
        }
      }
    } catch (e) {
      // If parsing fails, use original value
      formattedValue = value;
    }

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
            formattedValue,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
