import 'package:flutter/material.dart';
import 'package:inkspire/inkspire_app.dart';
import 'package:provider/provider.dart';
import 'package:inkspire/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const InkSpireApp(),
    ),
  );
}



