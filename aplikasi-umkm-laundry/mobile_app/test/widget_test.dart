import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/login_screen.dart';

void main() {
  testWidgets('Render halaman Login UMKM Laundry tanpa error', (WidgetTester tester) async {
    // Membangun widget LoginScreen di dalam MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Memastikan judul halaman dan tombol masuk tampil di layar
    expect(find.text('Login UMKM Laundry'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
