import 'package:flutter/material.dart';

class BlinkingRedDot extends StatefulWidget {
  const BlinkingRedDot({Key? key}) : super(key: key);

  @override
  _BlinkingRedDotState createState() => _BlinkingRedDotState();
}

class _BlinkingRedDotState extends State<BlinkingRedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Speed of blinking
      vsync: this,
      lowerBound: 0.3, // Fades out to 30% opacity
      upperBound: 1.0, // Full opacity
    )..repeat(reverse: true); // Continuously repeats the animation
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value, // Updates opacity dynamically
          child: Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
