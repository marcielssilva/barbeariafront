import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Adicione esta linha
import 'pages/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbearia App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,

      // Suporte a localização — essencial para o DatePicker
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
