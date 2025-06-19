import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/welcome_provider.dart';
import 'utils/app_colors.dart';
import 'widgets/welcome_background.dart';
import 'widgets/welcome_content.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startWelcomeSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  void _startWelcomeSequence() async {
    // Start fade animation
    _fadeController.forward();

    // Delay for slide animation
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();

    // Delay for scale animation
    await Future.delayed(const Duration(milliseconds: 600));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WelcomeProvider(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGradientStart,
                AppColors.primaryGradientEnd,
              ],
            ),
          ),
          child: Stack(
            children: [
              WelcomeBackground(
                fadeController: _fadeController,
              ),
              SafeArea(
                child: WelcomeContent(
                  fadeController: _fadeController,
                  slideController: _slideController,
                  scaleController: _scaleController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}