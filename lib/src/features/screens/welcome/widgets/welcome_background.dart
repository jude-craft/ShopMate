// lib/widgets/welcome/welcome_background.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WelcomeBackground extends StatelessWidget {
  final AnimationController fadeController;

  const WelcomeBackground({
    Key? key,
    required this.fadeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Animated floating circles
        ...List.generate(6, (index) {
          return AnimatedBuilder(
            animation: fadeController,
            builder: (context, child) {
              final animationOffset = fadeController.value * 2 * math.pi;
              final radius = 100 + (index * 20);
              final speed = 0.5 + (index * 0.2);

              return Positioned(
                left: size.width * 0.1 +
                    math.cos(animationOffset * speed + index) * 30,
                top: size.height * 0.2 +
                    (index * size.height * 0.15) +
                    math.sin(animationOffset * speed + index) * 20,
                child: Opacity(
                  opacity: 0.1 + (fadeController.value * 0.1),
                  child: Container(
                    width: radius.toDouble(),
                    height: radius.toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Geometric shapes
        Positioned(
          top: size.height * 0.1,
          right: size.width * 0.1,
          child: FadeTransition(
            opacity: fadeController,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: size.height * 0.3,
          left: size.width * 0.05,
          child: FadeTransition(
            opacity: fadeController,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        // Gradient overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}