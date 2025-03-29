import 'package:flutter/material.dart';
import 'package:inkspire/app/inkspire_app.dart';
import 'package:inkspire/config/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const InkSpireApp(),
    ),
  );
}



