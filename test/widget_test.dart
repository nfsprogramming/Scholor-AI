import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_tutor/theme.dart';

void main() {
  group('AppTheme Color Tokens Tests', () {
    test('Color palette tokens match specification', () {
      expect(AppTheme.primary, equals(const Color(0xFF4A40E0)));
      expect(AppTheme.surface, equals(const Color(0xFFFAF4FF)));
      expect(AppTheme.background, equals(const Color(0xFFFAF4FF)));
      expect(AppTheme.secondary, equals(const Color(0xFF702AE1)));
      expect(AppTheme.onPrimary, equals(const Color(0xFFF4F1FF)));
      expect(AppTheme.onSurface, equals(const Color(0xFF32294F)));
      expect(AppTheme.surfaceContainer, equals(const Color(0xFFEDE4FF)));
      expect(AppTheme.error, equals(const Color(0xFFB41340)));
    });

    testWidgets('Educational card renders successfully in widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: Card(
                color: AppTheme.surfaceContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Scholor AI Offline Tutor',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Local textbook search and AI assistance',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scholor AI Offline Tutor'), findsOneWidget);
      expect(find.text('Local textbook search and AI assistance'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
