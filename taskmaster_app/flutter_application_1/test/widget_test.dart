// Este es un test básico de Flutter para verificar que la app se inicia
// sin errores y muestra la pantalla correcta según autenticación.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaster_app/main.dart';

void main() {
  // Configuración inicial para tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('App se inicia sin errores', (WidgetTester tester) async {
    // Mock de SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Cargar variables de entorno para test
    await dotenv.load(fileName: ".env.test");
    
    // Construir la app
    await tester.pumpWidget(const MyApp());
    
    // Esperar a que se renderice
    await tester.pumpAndSettle();
    
    // Verificar que la app se construyó sin errores
    // (No hay un contador, así que verificamos elementos generales)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Pantalla de login se muestra cuando no hay sesión', 
      (WidgetTester tester) async {
    // Mock de SharedPreferences vacío (sin sesión)
    SharedPreferences.setMockInitialValues({});
    
    await dotenv.load(fileName: ".env.test");
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    // Verificar que se muestra algo relacionado con login/registro
    expect(find.textContaining('TaskMaster'), findsAtLeast(1));
    expect(find.byType(TextFormField), findsAtLeast(1));
  });
}