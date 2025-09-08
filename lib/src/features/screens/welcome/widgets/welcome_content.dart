import 'package:flutter/material.dart';

import '../utils/app_text_styles.dart';
import 'animated_logo.dart';
import 'feature_card.dart';
import 'get_started_button.dart';

class WelcomeContent extends StatelessWidget {
  final AnimationController fadeController;
  final AnimationController slideController;
  final AnimationController scaleController;

  const WelcomeContent({
    Key? key,
    required this.fadeController,
    required this.slideController,
    required this.scaleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        // Header Section
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedLogo(
                  scaleController: scaleController,
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: fadeController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: slideController,
                      curve: Curves.easeOutBack,
                    )),
                    child: Column(
                      children: [
                        Text(
                          'ShopMate',
                          style: AppTextStyles.welcomeTitle.copyWith(
                            color: Colors.white,
                            fontSize: size.width * 0.08,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your Smart Business Companion',
                          style: AppTextStyles.welcomeSubtitle.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: size.width * 0.04,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Features Section
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: fadeController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: slideController,
                  curve: Curves.easeOutBack,
                )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.point_of_sale,
                            title: 'Sales Tracking',
                            description: 'Record every sale efficiently',
                            delay: 0,
                            controller: slideController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.trending_up,
                            title: 'Profit Analysis',
                            description: 'Track daily profits',
                            delay: 200,
                            controller: slideController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.inventory,
                            title: 'Stock Management',
                            description: 'Keep inventory updated',
                            delay: 400,
                            controller: slideController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FeatureCard(
                            icon: Icons.assessment,
                            title: 'Smart Reports',
                            description: 'Generate insights',
                            delay: 600,
                            controller: slideController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Get Started Button
        Flexible(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GetStartedButton(
                  fadeController: fadeController,
                  scaleController: scaleController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}