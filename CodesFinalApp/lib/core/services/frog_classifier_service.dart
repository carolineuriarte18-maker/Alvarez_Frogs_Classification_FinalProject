import 'dart:io';

import 'package:camera/camera.dart';

/// Minimal classifier service stub used by the UI while a real
/// ML-backed implementation is not present. This provides the
/// API expected by `camera_detection_page.dart`.
class ClassificationResult {
  final List<double> scores;
  final int topIndex;
  final String topLabel;
  final double topConfidence;

  ClassificationResult({
    required this.scores,
    required this.topIndex,
    required this.topLabel,
    required this.topConfidence,
  });
}

class FrogClassifierService {
  FrogClassifierService._private();

  /// Singleton instance used throughout the app.
  static final FrogClassifierService instance = FrogClassifierService._private();

  /// Labels loaded alongside the model (empty by default).
  List<String> labels = const [];

  /// Ensure any model or assets are loaded. Stubbed to no-op.
  Future<void> ensureModelLoaded() async {
    // Add real model loading here when integrating a TFLite interpreter.
    return;
  }

  /// Synchronous classification from a camera frame. Returns `null`
  /// when no inference is available (stubbed).
  ClassificationResult? classifyCameraImage(CameraImage image) {
    // Replace with a real frame-to-inference pipeline.
    return null;
  }

  /// Asynchronous classification for captured images from disk.
  Future<ClassificationResult?> classifyImage(File image) async {
    // Replace with a real image classification invocation.
    return null;
  }

  /// Normalizes/cleans up labels for display.
  String cleanLabel(String label) => label.trim();
}
