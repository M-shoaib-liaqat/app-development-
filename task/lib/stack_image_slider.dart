import 'package:flutter/material.dart';

class StackedImageSlider extends StatefulWidget {
  const StackedImageSlider({super.key});

  @override
  _StackedImageSliderState createState() => _StackedImageSliderState();
}

class _StackedImageSliderState extends State<StackedImageSlider> {
  final List<String> imagePaths = [
    'assets/image01.png',
    'assets/image02.jpeg',
    'assets/image03.jpg',
    'assets/image04.png',
  ];

  int currentIndex = 0;

  void nextImage() {
    if (currentIndex < imagePaths.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stacked Image Slider')),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 220,
          child: Stack(
            children: [
              for (int i = 0; i <= currentIndex; i++)
                Positioned(
                  left: i == currentIndex ? 0 : 40,
                  top: i * 10.0,
                  child: Opacity(
                    opacity: i == currentIndex ? 1.0 : 0.5,
                    child: Transform.scale(
                      scale: i == currentIndex ? 1.0 : 0.9,
                      child: Image.asset(
                        imagePaths[i],
                        width: 250,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20), // Left padding
          FloatingActionButton(
            onPressed: previousImage,
            child: const Icon(Icons.arrow_left),
          ),
          const Spacer(),
          FloatingActionButton(
            onPressed: nextImage,
            child: const Icon(Icons.arrow_right),
          ),
          const SizedBox(width: 20), // Right padding
        ],
      ),
    );
  }
}
