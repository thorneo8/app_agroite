import 'package:flutter_test/flutter_test.dart';
import 'package:app_riego/main.dart';

void main() {
  testWidgets('La pantalla principal muestra el título y el botón de registro', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verifica que el título está presente
    expect(find.text('Gestión de Cultivos'), findsOneWidget);

    // Verifica que el botón "Registrar Empresa" está presente
    expect(find.text('Registrar Empresa'), findsOneWidget);
  });
}