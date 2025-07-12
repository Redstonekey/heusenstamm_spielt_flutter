import 'dart:math';

class ImageService {
  static final Random _random = Random();
  
  // Picsum - Lorem Picsum for random images
  static String getPicsumImage({
    int width = 400,
    int height = 300,
    int? seed,
    bool grayscale = false,
    bool blur = false,
  }) {
    final randomSeed = seed ?? _random.nextInt(1000);
    String url = 'https://picsum.photos/$width/$height?random=$randomSeed';
    
    if (grayscale) url += '&grayscale';
    if (blur) url += '&blur';
    
    return url;
  }}
