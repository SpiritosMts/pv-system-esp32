class PVCurrentData {
  final double current;
  final double humidity;
  final double light;
  final double power;
  final double temperature;
  final int timestamp;
  final double voltage;

  PVCurrentData({
    required this.current,
    required this.humidity,
    required this.light,
    required this.power,
    required this.temperature,
    required this.timestamp,
    required this.voltage,
  });

  factory PVCurrentData.fromJson(Map<String, dynamic> json) {
    return PVCurrentData(
      current: (json['current'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      light: (json['light'] ?? 0).toDouble(),
      power: (json['power'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
      voltage: (json['voltage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'humidity': humidity,
      'light': light,
      'power': power,
      'temperature': temperature,
      'timestamp': timestamp,
      'voltage': voltage,
    };
  }

  DateTime get dateTime {
    // Unix timestamp is in seconds, convert to milliseconds
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
}

class PVHistoryData {
  final String id;
  final double current;
  final double humidity;
  final double light;
  final double power;
  final double temperature;
  final int timestamp;
  final double voltage;

  PVHistoryData({
    required this.id,
    required this.current,
    required this.humidity,
    required this.light,
    required this.power,
    required this.temperature,
    required this.timestamp,
    required this.voltage,
  });

  factory PVHistoryData.fromJson(String id, Map<String, dynamic> json) {
    return PVHistoryData(
      id: id,
      current: (json['current'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      light: (json['light'] ?? 0).toDouble(),
      power: (json['power'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
      voltage: (json['voltage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'humidity': humidity,
      'light': light,
      'power': power,
      'temperature': temperature,
      'timestamp': timestamp,
      'voltage': voltage,
    };
  }

  DateTime get dateTime {
    // The ID is now a Unix timestamp (seconds since Jan 1, 1970)
    final idAsInt = int.tryParse(id);
    if (idAsInt != null && idAsInt > 1000000000) {
      // ID is a Unix timestamp, use it
      return DateTime.fromMillisecondsSinceEpoch(idAsInt * 1000);
    } else {
      // Fallback: use the timestamp field
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
  }
}

class PVSystemData {
  final PVCurrentData? currentValue;
  final List<PVHistoryData> history;
  final int? lastConnected;

  PVSystemData({
    this.currentValue,
    required this.history,
    this.lastConnected,
  });

  factory PVSystemData.fromJson(Map<String, dynamic> json) {
    List<PVHistoryData> historyList = [];
    
    if (json['history'] != null) {
      final historyRaw = json['history'];
      Map<String, dynamic> historyMap;
      
      // Handle Firebase's dynamic typing for history
      if (historyRaw is Map<Object?, Object?>) {
        historyMap = Map<String, dynamic>.from(historyRaw);
      } else if (historyRaw is Map<String, dynamic>) {
        historyMap = historyRaw;
      } else {
        historyMap = {};
      }
      
      historyList = historyMap.entries
          .map((entry) {
            final entryValue = entry.value;
            Map<String, dynamic> entryData;
            
            // Handle Firebase's dynamic typing for each history entry
            if (entryValue is Map<Object?, Object?>) {
              entryData = Map<String, dynamic>.from(entryValue);
            } else if (entryValue is Map<String, dynamic>) {
              entryData = entryValue;
            } else {
              return null;
            }
            
            return PVHistoryData.fromJson(entry.key, entryData);
          })
          .where((item) => item != null)
          .cast<PVHistoryData>()
          .toList();
      
      // Sort by timestamp descending (newest first)
      historyList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    PVCurrentData? currentValue;
    if (json['currentValue'] != null) {
      final currentRaw = json['currentValue'];
      Map<String, dynamic> currentData;
      
      // Handle Firebase's dynamic typing for currentValue
      if (currentRaw is Map<Object?, Object?>) {
        currentData = Map<String, dynamic>.from(currentRaw);
      } else if (currentRaw is Map<String, dynamic>) {
        currentData = currentRaw;
      } else {
        currentData = {};
      }
      
      currentValue = PVCurrentData.fromJson(currentData);
    }

    // Get lastConnected timestamp
    int? lastConnected;
    if (json['lastConnected'] != null) {
      lastConnected = json['lastConnected'] is int 
          ? json['lastConnected'] 
          : int.tryParse(json['lastConnected'].toString());
    }

    return PVSystemData(
      currentValue: currentValue,
      history: historyList,
      lastConnected: lastConnected,
    );
  }
  
  DateTime? get lastConnectedTime {
    if (lastConnected == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastConnected! * 1000);
  }
}
