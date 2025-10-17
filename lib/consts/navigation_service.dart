import 'package:flutter/material.dart';

// این کلید سراسری را برای دسترسی به Navigator (و Context آن) تعریف می‌کنیم.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// تابعی برای دسترسی آسان به Context سراسری
BuildContext? get globalContext => navigatorKey.currentContext;