// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_config.dart';
import '../../core/models/detection_record.dart';
import '../../core/services/detection_storage_service.dart';
import '../../core/services/frog_classifier_service.dart';
import '../detection/detection_result_page.dart';
import '../../app_theme.dart';

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({
    super.key,
    this.selectedClassIndex,
    this.selectedClassName,
  });

  final int? selectedClassIndex;
  final String? selectedClassName;

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  // Detection overlay state (shows last captured result)
  String _detectedClass = 'Ready to scan';
  double _confidence = 0;
  List<double> _scores = [];
  bool _isProcessingFrame = false;
  int _frameSkipCount = 0;
  static const int _frameSkipInterval = 3; // Process every Nth frame
  static const double _smoothingFactor = 0.3; // For exponential moving average
  List<double>? _smoothedScores;

  // For snapshot capture
  bool _isCapturing = false;

  final _classifier = FrogClassifierService.instance;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Pre-load the model
      await _classifier.ensureModelLoaded();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found');
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  // ignore: unused_element
  void _processCameraFrame(CameraImage cameraImage) {
    // Skip frames to reduce processing load
    _frameSkipCount++;
    if (_frameSkipCount < _frameSkipInterval) return;
    _frameSkipCount = 0;

    // Don't process if already processing or capturing
    if (_isProcessingFrame || _isCapturing) return;
    _isProcessingFrame = true;

    // Run inference synchronously on this frame
    final result = _classifier.classifyCameraImage(cameraImage);

    if (result != null && mounted) {
      final scores = result.scores;

      // Initialize or update smoothed scores with exponential moving average
      if (_smoothedScores == null || _smoothedScores!.length != scores.length) {
        _smoothedScores = List<double>.from(scores);
      } else {
        for (int i = 0; i < scores.length; i++) {
          _smoothedScores![i] =
              _smoothingFactor * scores[i] +
              (1 - _smoothingFactor) * _smoothedScores![i];
        }
      }

      final smoothed = _smoothedScores!;

      // Find top index from smoothed scores
      int topIndex = 0;
      double topScore = smoothed[0];
      for (int i = 1; i < smoothed.length; i++) {
        if (smoothed[i] > topScore) {
          topScore = smoothed[i];
          topIndex = i;
        }
      }

      if (topScore < AppConfig.minConfidenceToAccept) {
        setState(() {
          _detectedClass = 'Ready to scan';
          _confidence = 0;
          _scores = [];
        });
      } else {
        final labels = _classifier.labels;
        final displayLabel = topIndex < labels.length
            ? _classifier.cleanLabel(labels[topIndex])
            : 'Unknown';

        setState(() {
          _detectedClass = displayLabel;
          _confidence = topScore * 100;
          _scores = smoothed;
        });
      }
    }

    _isProcessingFrame = false;
  }

  Future<void> _captureAndNavigate() async {
    if (_isCapturing || _cameraController == null || !_isCameraInitialized) {
      return;
    }

    // If no class was preselected (user opened Detect from bottom nav), allow unconstrained detection.

    setState(() => _isCapturing = true);

    try {
      // Take picture
      final xFile = await _cameraController!.takePicture();
      final file = File(xFile.path);

      // Run inference on captured image for accurate result
      final result = await _classifier.classifyImage(file);

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to classify image')),
        );
        setState(() => _isCapturing = false);
        return;
      }

      final labels = _classifier.labels;
      for (int i = 0; i < result.scores.length; i++) {
        final label = i < labels.length
            ? _classifier.cleanLabel(labels[i])
            : 'Class $i';
        debugPrint('$i: $label -> ${result.scores[i].toStringAsFixed(3)}');
      }

      if (result.topConfidence < AppConfig.minConfidenceToAccept) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No frog detected. Please ensure the frog fills the frame and try again.',
            ),
          ),
        );
        setState(() {
          _isCapturing = false;
          _detectedClass = 'No frog detected';
          _confidence = 0;
          _scores = [];
        });
        return;
      }

      final cleanLabel = _classifier.cleanLabel(result.topLabel);

      // Save detection record
      final groundTruthClass = widget.selectedClassName ?? 'Unknown';
      final groundTruthIndex = widget.selectedClassIndex ?? -1;

      final record = DetectionRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        groundTruthClass: groundTruthClass,
        groundTruthIndex: groundTruthIndex,
        predictedClass: cleanLabel,
        predictedIndex: result.topIndex,
        confidence: result.topConfidence,
        scores: result.scores,
      );

      await DetectionStorageService.instance.saveRecord(record);
      if (!mounted) return;

      // If a class was preselected from Home, enforce matching; otherwise accept any prediction
      if (widget.selectedClassIndex != null) {
        final selectedIndex = widget.selectedClassIndex ?? -1;
        if (result.topIndex != selectedIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Detected frog does not match the selected class. Please retake with the correct frog.',
              ),
            ),
          );
          setState(() {
            _isCapturing = false;
            _detectedClass = 'No frog detected';
            _confidence = 0;
            _scores = [];
          });
          return;
        }
      } else {
        // No preselected class: accept any top prediction but ensure the predicted label exists
        final predictedNormalized = cleanLabel.toLowerCase().trim();
        final known = AppColors.classNames
            .map((s) => s.toLowerCase().trim())
            .contains(predictedNormalized);
        if (!known) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Detected species is not recognized by the app labels.',
              ),
            ),
          );
          setState(() {
            _isCapturing = false;
            _detectedClass = 'No frog detected';
            _confidence = 0;
            _scores = [];
          });
          return;
        }
      }

      // Update overlay with this result (shown when user comes back)
      setState(() {
        _detectedClass = cleanLabel;
        _confidence = result.topConfidence * 100;
        _scores = result.scores;
      });

      // Navigate to result page
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetectionResultPage(
            detectedClassName: cleanLabel,
            confidence: result.topConfidence * 100,
            scores: result.scores,
            recordId: record.id,
            imagePath: file.path,
          ),
        ),
      );

      if (mounted) {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      setState(() => _isCapturing = true);

      final imageFile = File(pickedFile.path);
      final result = await _classifier.classifyImage(imageFile);

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to classify image')),
        );
        setState(() => _isCapturing = false);
        return;
      }

      if (result.topConfidence < AppConfig.minConfidenceToAccept) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No frog detected in the image. Please try another image.',
            ),
          ),
        );
        setState(() {
          _isCapturing = false;
          _detectedClass = 'No frog detected';
          _confidence = 0;
          _scores = [];
        });
        return;
      }

      final cleanLabel = _classifier.cleanLabel(result.topLabel);

      // Save detection record
      final groundTruthClass = widget.selectedClassName ?? 'Unknown';
      final groundTruthIndex = widget.selectedClassIndex ?? -1;

      final record = DetectionRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        groundTruthClass: groundTruthClass,
        groundTruthIndex: groundTruthIndex,
        predictedClass: cleanLabel,
        predictedIndex: result.topIndex,
        confidence: result.topConfidence,
        scores: result.scores,
      );

      await DetectionStorageService.instance.saveRecord(record);
      if (!mounted) return;

      if (widget.selectedClassIndex != null) {
        final selectedIndex = widget.selectedClassIndex ?? -1;
        if (result.topIndex != selectedIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Detected frog does not match the selected class. Please try another image with the correct frog.',
              ),
            ),
          );
          setState(() {
            _isCapturing = false;
            _detectedClass = 'No frog detected';
            _confidence = 0;
            _scores = [];
          });
          return;
        }
      } else {
        final predictedNormalized = cleanLabel.toLowerCase().trim();
        final known = AppColors.classNames
            .map((s) => s.toLowerCase().trim())
            .contains(predictedNormalized);
        if (!known) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Detected species is not recognized by the app labels.',
              ),
            ),
          );
          setState(() {
            _isCapturing = false;
            _detectedClass = 'No frog detected';
            _confidence = 0;
            _scores = [];
          });
          return;
        }
      }

      // Update overlay with this result
      setState(() {
        _detectedClass = cleanLabel;
        _confidence = result.topConfidence * 100;
        _scores = result.scores;
      });

      // Navigate to result page
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetectionResultPage(
            detectedClassName: cleanLabel,
            confidence: result.topConfidence * 100,
            scores: result.scores,
            recordId: record.id,
            imagePath: imageFile.path,
          ),
        ),
      );

      if (mounted) {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Color _getConfidenceColor() {
    if (_confidence >= 70) return Colors.green;
    if (_confidence >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.selectedClassName ??
        'Class ${(widget.selectedClassIndex ?? 0) + 1}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(child: _buildCameraPreview()),

          // Detection frame overlay
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getConfidenceColor().withOpacity(0.9),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(displayName),
                const Spacer(),
                _buildDetectionOverlay(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading camera & model...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildTopBar(String displayName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Column(
            children: const [
              Text(
                'Start Scan Frogs',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Its going to be fun!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Ready to scan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Capture photo or upload from gallery',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gallery button
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Camera capture button
              GestureDetector(
                onTap: _captureAndNavigate,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getConfidenceColor(),
                        _getConfidenceColor().withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getConfidenceColor().withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 24),
              // Placeholder for symmetry (or could add flash toggle)
              const SizedBox(width: 56, height: 56),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
