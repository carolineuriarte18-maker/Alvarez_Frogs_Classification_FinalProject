// ignore_for_file: unused_local_variable, unused_import

import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_theme.dart';
import 'class_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final pageCount = AppColors.classNames.length;
      final current = (_pageController.page ?? _pageController.initialPage)
          .round();
      final next = current + 1;
      final toPage = next >= pageCount ? 0 : next;
      _pageController.animateToPage(
        toPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFC8E6C9),
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 30),
          // Welcome text (centered)
          const Center(
            child: Text(
              'Welcome to FrogScan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Discover and identify frog species using your camera — fast, friendly, and research-ready.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Center(
            child: Text(
              'Featured Species',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          // Carousel / PageView of class cards
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _pageController,
              itemCount: AppColors.classNames.length,
              itemBuilder: (context, index) {
                final name = AppColors.classNames[index];
                final asset = AppColors.classAssetNames[index];
                final desc = AppColors.classDescriptions.length > index
                    ? AppColors.classDescriptions[index]
                    : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Open a detail page for this class
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClassDetailPage(classIndex: index),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: Image.asset(
                              'assets/images/$asset',
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) => Container(
                                width: double.infinity,
                                height: 140,
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
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
              },
            ),
          ),
          const SizedBox(height: 18),

          // Small help text
          const Center(
            child: Text(
              'Tap a species to view details about that frog.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
