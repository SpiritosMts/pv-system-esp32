class PVCurrentData {
  final double humidity;
  final double light;  // Irradiance (G_Wm2)
  final double power;
  final double temperature;
  final int timestamp;
  final double voltage;
  final double energy;  // E_Wh

  PVCurrentData({
    required this.humidity,
    required this.light,
    required this.power,
    required this.temperature,
    required this.timestamp,
    required this.voltage,
    required this.energy,
  });

  factory PVCurrentData.fromJson(Map<String, dynamic> json) {
    // Support both old and new field names
    return PVCurrentData(
      humidity: (json['Hum_%'] ?? json['humidity'] ?? 0).toDouble(),
      light: (json['G_Wm2'] ?? json['light'] ?? 0).toDouble(),
      power: (json['Pmp_kW'] ?? json['power'] ?? 0).toDouble(),
      temperature: (json['Ta_C'] ?? json['temperature'] ?? 0).toDouble(),
      timestamp: json['ts'] ?? json['timestamp'] ?? 0,
      voltage: (json['Vmp_V'] ?? json['voltage'] ?? 0).toDouble(),
      energy: (json['E_Wh'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Hum_%': humidity,
      'G_Wm2': light,
      'Pmp_kW': power,
      'Ta_C': temperature,
      'ts': timestamp,
      'Vmp_V': voltage,
      'E_Wh': energy,
    };
  }

  DateTime get dateTime {
    // New format uses milliseconds (ts), old used seconds (timestamp)
    // Check if timestamp is in milliseconds (> year 2100 in seconds)
    if (timestamp > 4102444800) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
  }
}

class PVHistoryData {
  final String id;
  final double humidity;
  final double light;  // Irradiance (G_Wm2)
  final double power;
  final double temperature;
  final int timestamp;
  final double voltage;
  final double energy;  // E_Wh

  PVHistoryData({
    required this.id,
    required this.humidity,
    required this.light,
    required this.power,
    required this.temperature,
    required this.timestamp,
    required this.voltage,
    required this.energy,
  });

  factory PVHistoryData.fromJson(String id, Map<String, dynamic> json) {
    // Support both old and new field names
    return PVHistoryData(
      id: id,
      humidity: (json['Hum_%'] ?? json['humidity'] ?? 0).toDouble(),
      light: (json['G_Wm2'] ?? json['light'] ?? 0).toDouble(),
      power: (json['Pmp_kW'] ?? json['power'] ?? 0).toDouble(),
      temperature: (json['Ta_C'] ?? json['temperature'] ?? 0).toDouble(),
      timestamp: json['ts'] ?? json['timestamp'] ?? 0,
      voltage: (json['Vmp_V'] ?? json['voltage'] ?? 0).toDouble(),
      energy: (json['E_Wh'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Hum_%': humidity,
      'G_Wm2': light,
      'Pmp_kW': power,
      'Ta_C': temperature,
      'ts': timestamp,
      'Vmp_V': voltage,
      'E_Wh': energy,
    };
  }

  DateTime get dateTime {
    // The ID is a Unix timestamp
    final idAsInt = int.tryParse(id);
    if (idAsInt != null && idAsInt > 1000000000) {
      // Check if ID is in milliseconds (> year 2100 in seconds)
      if (idAsInt > 4102444800) {
        return DateTime.fromMillisecondsSinceEpoch(idAsInt);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(idAsInt * 1000);
      }
    } else {
      // Fallback: use the timestamp field
      if (timestamp > 4102444800) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
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
    
    // Support both old and new field names: 'history' and 'historique'
    final historyRaw = json['historique'] ?? json['history'];
    if (historyRaw != null) {
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
    // Support both old and new field names: 'currentValue' and 'valeur_actuelle'
    final currentRaw = json['valeur_actuelle'] ?? json['currentValue'];
    if (currentRaw != null) {
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
