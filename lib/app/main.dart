import 'package:flutter/material.dart';
import 'package:inkspire/app/inkspire_app.dart';
import 'package:inkspire/providers/theme_provider.dart';
import 'package:inkspire/providers/chat_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const InkSpireApp(),
    ),
  );
}
