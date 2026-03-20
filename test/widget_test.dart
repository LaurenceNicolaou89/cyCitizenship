import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cy_citizenship/shared/widgets/app_button.dart';
import 'package:cy_citizenship/shared/widgets/app_card.dart';
import 'package:cy_citizenship/shared/widgets/app_chip.dart';
import 'package:cy_citizenship/shared/widgets/answer_option.dart';
import 'package:cy_citizenship/shared/widgets/stat_card.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Test Button'),
          ),
        ),
      );
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Loading', isLoading: true),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Tap Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(pressed, true);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Icon', icon: Icons.check),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(child: Text('Card Content')),
          ),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('is tappable when onTap provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tap Card'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Card'));
      expect(tapped, true);
    });
  });

  group('AppChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppChip(label: 'Geography'),
          ),
        ),
      );
      expect(find.text('Geography'), findsOneWidget);
    });

    testWidgets('selected state changes appearance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppChip(label: 'Selected', selected: true),
          ),
        ),
      );
      expect(find.text('Selected'), findsOneWidget);
    });
  });

  group('AnswerOption', () {
    testWidgets('renders label and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnswerOption(label: 'A', text: 'Nicosia'),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Nicosia'), findsOneWidget);
    });

    testWidgets('shows check icon when correct', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnswerOption(
              label: 'A',
              text: 'Correct',
              state: AnswerState.correct,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows cancel icon when wrong', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnswerOption(
              label: 'B',
              text: 'Wrong',
              state: AnswerState.wrong,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  group('StatCard', () {
    testWidgets('renders value and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              icon: Icons.local_fire_department,
              value: '12',
              label: 'Day Streak',
            ),
          ),
        ),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });
  });
}
