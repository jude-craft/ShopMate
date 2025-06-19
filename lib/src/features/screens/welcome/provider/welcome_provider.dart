import 'package:flutter/material.dart';

class WelcomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isNavigating = false;

  bool get isLoading => _isLoading;
  bool get isNavigating => _isNavigating;



}