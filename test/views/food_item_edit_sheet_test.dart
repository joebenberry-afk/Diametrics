import 'package:diametrics/src/domain/entities/food_item.dart';
import 'package:diametrics/views/food_scanner/food_item_edit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = FoodItem(
    name: 'Chicken Curry',
    portion: '1 bowl',
    carbsGrams: 45.0,
    proteinGrams: 28.0,
    fatGrams: 12.0,
    calories: 396.0,
    weightG: 300.0,
    source: 'USDA+N5K',
  );

  testWidgets('displays item values in text fields', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FoodItemEditSheet(item: item, onSave: (_) {}),
      ),
    ));

    expect(find.widgetWithText(TextFormField, 'Chicken Curry'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '45.0'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '28.0'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12.0'), findsOneWidget);
  });

  testWidgets('onSave callback receives updated values', (tester) async {
    FoodItem? savedItem;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FoodItemEditSheet(
          item: item,
          onSave: (updated) => savedItem = updated,
        ),
      ),
    ));

    // Edit the carbs field
    await tester.enterText(
      find.widgetWithText(TextFormField, '45.0'),
      '55.0',
    );

    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(savedItem, isNotNull);
    expect(savedItem!.carbsGrams, 55.0);
    expect(savedItem!.weightG, 300.0); // weightG preserved
    expect(savedItem!.name, 'Chicken Curry'); // unchanged fields preserved
  });
}
