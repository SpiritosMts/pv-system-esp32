import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionData {
  final String id;
  final double predictedPowerW;
  final double predictedVdcV;
  final double relativeHumidityZm;
  final double shortwaveRadiation;
  final double temperatureZm;
  final DateTime time;
  final double windSpeedZ12m;

  PredictionData({
    required this.id,
    required this.predictedPowerW,
    required this.predictedVdcV,
    required this.relativeHumidityZm,
    required this.shortwaveRadiation,
    required this.temperatureZm,
    required this.time,
    required this.windSpeedZ12m,
  });

  factory PredictionData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PredictionData(
      id: doc.id,
      predictedPowerW: (data['Predicted_Power_W'] ?? 0).toDouble(),
      predictedVdcV: (data['Predicted_Vdc_V'] ?? 0).toDouble(),
      relativeHumidityZm: (data['relative_humidity_2m'] ?? 0).toDouble(),
      shortwaveRadiation: (data['shortwave_radiation'] ?? 0).toDouble(),
      temperatureZm: (data['temperature_2m'] ?? 0).toDouble(),
      time: (data['time'] as Timestamp).toDate(),
      windSpeedZ12m: (data['wind_speed_12m'] ?? 0).toDouble(),
    );
  }

  // Getters for easier access
  double get power => predictedPowerW;
  double get voltage => predictedVdcV;
  double get humidity => relativeHumidityZm;
  double get temperature => temperatureZm;
  double get radiation => shortwaveRadiation;
  double get windSpeed => windSpeedZ12m;
}
