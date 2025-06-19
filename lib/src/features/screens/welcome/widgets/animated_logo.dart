// lib/widgets/welcome/animated_logo.dart
import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController scaleController;

  const AnimatedLogo({
    Key? key,
    required this.scaleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: scaleController,
        curve: Curves.elasticOut,
      )),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle with pulse effect
            AnimatedBuilder(
              animation: scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (scaleController.value * 0.1),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            // Main icon
            Icon(
              Icons.store,
              size: 50,
              color: Colors.white,
            ),
            // Shopping cart overlay
            Positioned(
              top: 25,
              right: 25,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}