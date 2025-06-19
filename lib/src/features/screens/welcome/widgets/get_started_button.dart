// lib/widgets/welcome/get_started_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../navigation/main_navigation.dart';
import '../provider/welcome_provider.dart';
import '../utils/app_text_styles.dart';

class GetStartedButton extends StatefulWidget {
  final AnimationController fadeController;
  final AnimationController scaleController;

  const GetStartedButton({
    Key? key,
    required this.fadeController,
    required this.scaleController,
  }) : super(key: key);

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeProvider>(
      builder: (context, provider, _) {
        return FadeTransition(
          opacity: widget.fadeController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.scaleController,
                curve: Curves.elasticOut,
              ),
            ),
            child: AnimatedBuilder(
              animation: _pressAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pressAnimation.value,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainNavigation()),
                    ),

                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shimmer effect
                          AnimatedBuilder(
                            animation: widget.fadeController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                    begin: Alignment(
                                      -1.0 + widget.fadeController.value * 2,
                                      0,
                                    ),
                                    end: Alignment(
                                      1.0 + widget.fadeController.value * 2,
                                      0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Button content
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: AppTextStyles.button.copyWith(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
