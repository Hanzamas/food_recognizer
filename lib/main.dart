import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/service/classifier_service.dart';
import 'package:submission/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load model on startup
  ClassifierService.init().catchError((_) {});
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
