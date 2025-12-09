import 'package:flutter/material.dart';

class NavigationHelper {
  // Navigate to a specific route
  static void goTo(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
  
  // Navigate and replace current route
  static void goToReplace(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }
  
  // Navigate to a route and push (can go back)
  static void pushTo(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
  
  // Go back
  static void goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  
  // Go back with result
  static void goBackWithResult(BuildContext context, dynamic result) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }
  
  // Clear all routes and go to new route
  static void goToAndClearStack(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: arguments,
    );
  }
  
  // Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

