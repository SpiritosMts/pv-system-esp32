import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pv_data.dart';

class PVDataProvider extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  PVSystemData? _systemData;
  bool _isLoading = true;
  String? _errorMessage;

  PVSystemData? get systemData => _systemData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  PVCurrentData? get currentData => _systemData?.currentValue;
  List<PVHistoryData> get historyData => _systemData?.history ?? [];

  void startListening() {
    _listenToSystemData();
  }

  void stopListening() {
    // Note: Firebase Realtime Database doesn't have an 'off' method on DatabaseReference
    // Instead, we would need to store the StreamSubscription and cancel it
    // For now, we'll leave this empty as the listener will be cleaned up when the provider is disposed
  }

  void _listenToSystemData() {
    _database.child('system').onValue.listen(
      (DatabaseEvent event) {
        try {
          if (event.snapshot.exists) {
            final rawData = event.snapshot.value;
            Map<String, dynamic> data;
            
            // Handle Firebase's dynamic typing
            if (rawData is Map<Object?, Object?>) {
              data = Map<String, dynamic>.from(rawData);
            } else if (rawData is Map<String, dynamic>) {
              data = rawData;
            } else {
              throw Exception('Unexpected data type: ${rawData.runtimeType}');
            }
            
            _systemData = PVSystemData.fromJson(data);
            _errorMessage = null;
            
            // Debug: Print parsed data
            print('Parsed system data: ${_systemData?.history.length} history items');
            if (_systemData?.history.isNotEmpty == true) {
              print('First history item: ${_systemData?.history.first.id} - ${_systemData?.history.first.dateTime}');
            }
          } else {
            _systemData = PVSystemData(history: []);
          }
          _isLoading = false;
          notifyListeners();
        } catch (e) {
          _errorMessage = 'Error parsing data: $e';
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Database error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Get history data for a specific time range
  List<PVHistoryData> getHistoryForTimeRange(Duration timeRange) {
    if (_systemData == null) return [];
    
    // Return recent entries based on time range
    final cutoffTime = DateTime.now().subtract(timeRange);
    final filteredData = _systemData!.history
        .where((data) => data.dateTime.isAfter(cutoffTime))
        .toList();
    
    // If no data in range, return the most recent entries
    if (filteredData.isEmpty && _systemData!.history.isNotEmpty) {
      return _systemData!.history.take(20).toList();
    }
    
    return filteredData;
  }

  // Get latest N history entries
  List<PVHistoryData> getLatestHistory(int count) {
    if (_systemData == null) return [];
    
    return _systemData!.history.take(count).toList();
  }

  // Calculate average values for a time period
  Map<String, double> getAverageValues(Duration timeRange) {
    final data = getHistoryForTimeRange(timeRange);
    if (data.isEmpty) {
      return {
        'current': 0.0,
        'humidity': 0.0,
        'light': 0.0,
        'power': 0.0,
        'temperature': 0.0,
        'voltage': 0.0,
      };
    }

    return {
      'current': data.map((e) => e.current).reduce((a, b) => a + b) / data.length,
      'humidity': data.map((e) => e.humidity).reduce((a, b) => a + b) / data.length,
      'light': data.map((e) => e.light).reduce((a, b) => a + b) / data.length,
      'power': data.map((e) => e.power).reduce((a, b) => a + b) / data.length,
      'temperature': data.map((e) => e.temperature).reduce((a, b) => a + b) / data.length,
      'voltage': data.map((e) => e.voltage).reduce((a, b) => a + b) / data.length,
    };
  }

  // Get peak values for a time period
  Map<String, double> getPeakValues(Duration timeRange) {
    final data = getHistoryForTimeRange(timeRange);
    if (data.isEmpty) {
      return {
        'current': 0.0,
        'humidity': 0.0,
        'light': 0.0,
        'power': 0.0,
        'temperature': 0.0,
        'voltage': 0.0,
      };
    }

    return {
      'current': data.map((e) => e.current).reduce((a, b) => a > b ? a : b),
      'humidity': data.map((e) => e.humidity).reduce((a, b) => a > b ? a : b),
      'light': data.map((e) => e.light).reduce((a, b) => a > b ? a : b),
      'power': data.map((e) => e.power).reduce((a, b) => a > b ? a : b),
      'temperature': data.map((e) => e.temperature).reduce((a, b) => a > b ? a : b),
      'voltage': data.map((e) => e.voltage).reduce((a, b) => a > b ? a : b),
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
