import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color.fromARGB(255, 74, 226, 74);
  static const Color primaryBrown = Color.fromARGB(255, 158, 104, 4);
  static const Color accentTeal = Color.fromARGB(255, 217, 228, 61);
  static const Color dark = Color(0xFF1E1E2F);
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E2F);
  static const Color textSecondary = Color(0xFF6B7280);

  static const List<Color> classColors = [
    Color.fromARGB(255, 26, 122, 2), //American Bullfrog
    Color.fromARGB(255, 27, 163, 204), //Poison Dart Frog
    Color.fromARGB(255, 156, 147, 139), //Desert Rain Frog
    Color.fromARGB(255, 63, 245, 26), //Glass Frog
    Color.fromARGB(230, 22, 112, 4), //Green Tree Frog
    Color.fromARGB(255, 214, 48, 18), //Red-eyed Tree frog
    Color.fromARGB(255, 226, 230, 16), //Golden Poison Frog
    Color.fromARGB(174, 9, 150, 4), //Northern Leopard Frog
    Color.fromARGB(204, 134, 98, 19), // Wood frog
    Color.fromARGB(92, 223, 124, 11), //Surinam Horned Frog
  ];

  static const List<String> classNames = [
    'American Bullfrog',
    'Poison Dart Frog',
    'Desert Rain Frog',
    'Glass Frog',
    'Green Tree Frog',
    'Red-eyed Tree Frog',
    'Golden Poison Frog',
    'Northern Leopard Frog',
    'Wood Frog',
    'Surinam Horned Frog',
  ];

  static const List<String> classAssetNames = [
    'american_bullfrog.jpg',
    'poison_dart_frog.jpg',
    'desert_rain_frog.jpg',
    'glass_frog.jpg',
    'green_tree_frog.jpg',
    'red_eyed_tree_frog.jpg',
    'golden_poison_frog.jpg',
    'northern_leopard_frog.jpg',
    'wood_frog.jpg',
    'surinam_horned_frog.jpg',
  ];

  // Short, user-friendly descriptions for each class (aligned by index with `classNames`).
  static const List<String> classDescriptions = [
    'A large wetland frog commonly found near ponds and marshes.',
    'A small, brightly colored frog known for its potent skin toxins.',
    'A tiny desert-dwelling frog adapted to arid environments.',
    'A small translucent frog often found on leaves in rainforests.',
    'A tree-dwelling frog with adhesive pads for climbing.',
    'A distinctive frog with bright red eyes and vivid coloring.',
    'An extremely toxic frog with striking warning colors.',
    'A spotted frog native to northern regions and wetlands.',
    'A hardy frog commonly found in woodland ponds.',
    'A uniquely shaped frog from South American wetlands.',
  ];

  // Longer/detailed descriptions for the detail page (aligned by index)
  static const List<String> classDetails = [
    'The American Bullfrog is a large frog native to North America. It prefers permanent bodies of water and is known for its powerful jump and deep calls. Bullfrogs are opportunistic predators that feed on insects, small fish, and even other frogs.',
    'Poison Dart Frogs are small, brightly colored frogs of Central and South America. Their skin contains toxins used by indigenous peoples on blow darts; species vary greatly in toxicity.',
    'The Desert Rain Frog is a small, stout frog adapted to arid regions. It burrows into sand and has a rounded body to conserve moisture.',
    'Glass Frogs are known for their translucent skin on the underside, which can reveal internal organs. They are typically arboreal and found in rainforests.',
    'Green Tree Frogs are excellent climbers with adhesive pads on their toes, commonly found in trees and shrubs near water.',
    'Red-eyed Tree Frogs are recognized by their vivid red eyes and bright coloration; they are nocturnal and use their colors to startle predators.',
    'Golden Poison Frogs are among the most toxic animals on Earth; their bright coloration warns predators of their toxicity.',
    'Northern Leopard Frogs have distinctive spots and are commonly found near wetlands and grasslands in northern regions.',
    'Wood Frogs are adaptable amphibians that can be found in forests and are known for their freeze tolerance during winter.',
    'Surinam Horned Frogs have a unique flattened body and horn-like projections above the eyes; they are ambush predators in South American wetlands.',
  ];

  // Fun facts for each class (aligned by index)
  static const List<String> classFunFacts = [
    'Bullfrogs can eat small birds and mammals occasionally — they have a big appetite!',
    'Some poison dart frog species get their toxins from the ants and insects they eat.',
    'The Desert Rain Frog makes a high-pitched squeaking noise when disturbed.',
    'Glass frogs sometimes have green bones that add to their translucent appearance.',
    'Green Tree Frogs use toe pads with microscopic hairs to stick to surfaces.',
    'Red-eyed Tree Frogs use their bright eyes to startle predators (deimatic display).',
    'A tiny Golden Poison Frog carries enough poison to kill several humans in theory.',
    'Leopard frog tadpoles often form massive schools in ponds.',
    'Wood Frogs can survive being partially frozen during winter.',
    'Surinam Horned Frogs swallow prey whole and can consume surprisingly large meals.',
  ];

  static const List<String> classScientificNames = [
    'Lithobates catesbeianus',
    'Dendrobatidae',
    'Breviceps macrops',
    'Centrolenidae',
    'Litoria caerulea',
    'Agalychnis callidryas',
    'Phyllobates aurotaenia',
    'Lithobates pipiens',
    'Rana sylvatica',
    'Pipa pipa',
  ];
}
