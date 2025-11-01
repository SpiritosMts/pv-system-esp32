import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prediction_data.dart';

class PredictionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PredictionData> _predictions = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTriggering = false;

  List<PredictionData> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTriggering => _isTriggering;

  void startListening() {
    _listenToPredictions();
  }

  void _listenToPredictions() {
    _firestore
        .collection('pv_predictions_5min')
        .orderBy('time', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          _predictions = snapshot.docs
              .map((doc) => PredictionData.fromFirestore(doc))
              .toList();
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
        } catch (e) {
          _errorMessage = 'Error parsing predictions: $e';
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Firestore error: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Trigger prediction by updating the run field in prediction_trigger document
  Future<void> triggerPrediction() async {
    try {
      _isTriggering = true;
      notifyListeners();

      await _firestore
          .collection('control')
          .doc('prediction_trigger')
          .update({
        'run': true,
        'requestedAt': FieldValue.serverTimestamp(),
        'source': 'mobile_app',
      });

      print('Prediction triggered successfully');
    } catch (e) {
      print('Error triggering prediction: $e');
      _errorMessage = 'Failed to trigger prediction: $e';
      rethrow;
    } finally {
      _isTriggering = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
