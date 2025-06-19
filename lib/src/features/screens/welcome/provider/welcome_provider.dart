import 'package:flutter/material.dart';
import 'package:shop_mate/src/features/navigation/main_navigation.dart';

class WelcomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isNavigating = false;

  bool get isLoading => _isLoading;
  bool get isNavigating => _isNavigating;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setNavigating(bool navigating) {
    _isNavigating = navigating;
    notifyListeners();
  }

  Future<void> navigateToHome(BuildContext context) async {
    if (_isNavigating) return;

    setNavigating(true);


    if (context.mounted) {

      Navigator.pushReplacement(
        context,
         MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    }



  }
}