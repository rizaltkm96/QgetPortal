import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qget_portal/theme/app_theme.dart';

void main() {
  testWidgets('MaterialApp with app theme builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(body: Text('Qget test')),
        ),
      ),
    );
    expect(find.text('Qget test'), findsOneWidget);
  });
}
