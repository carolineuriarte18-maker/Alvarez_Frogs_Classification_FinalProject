import 'package:flutter/material.dart';

import '../../app_theme.dart';

class ClassDetailPage extends StatelessWidget {
  const ClassDetailPage({super.key, required this.classIndex});

  final int classIndex;

  @override
  Widget build(BuildContext context) {
    final name = AppColors.classNames[classIndex];
    final asset = AppColors.classAssetNames[classIndex];
    final detail = AppColors.classDetails.length > classIndex
        ? AppColors.classDetails[classIndex]
        : '';
    final funFact = AppColors.classFunFacts.length > classIndex
        ? AppColors.classFunFacts[classIndex]
        : '';
    final scientificName = AppColors.classScientificNames.length > classIndex
        ? AppColors.classScientificNames[classIndex]
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9),
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFFC8E6C9),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/$asset',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(detail, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              const Text(
                'Fun Fact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                funFact,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scientific Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                scientificName,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
