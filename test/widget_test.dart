import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpsupabase/main.dart';

void main() {
  testWidgets('explains how to configure Supabase', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
    expect(find.textContaining('SUPABASE_PUBLISHABLE_KEY'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });
}
