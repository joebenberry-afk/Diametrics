// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('Starting food database clean up...');

  final foodFile = File('FoodData_Central_sr_legacy_food_csv_2018-04/food.csv');
  final nutrientFile = File(
    'FoodData_Central_sr_legacy_food_csv_2018-04/food_nutrient.csv',
  );
  final outputFile = File('../assets/database/cleaned_food_database.csv');

  // Ensure the assets/database directory exists
  final dir = Directory('../assets/database');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // 1. Read food.csv into memory
  // Format: "fdc_id","data_type","description",...
  print('Reading food names...');
  final foodMap = <String, String>{};
  final foodLines = await foodFile.readAsLines();

  for (int i = 1; i < foodLines.length; i++) {
    final line = foodLines[i];
    if (line.isEmpty) continue;

    // Simple basic CSV parsing (assuming no commas inside quotes for FDC_ID)
    final parts = line.split('","');
    if (parts.length > 2) {
      final fdcId = parts[0].replaceAll('"', ''); // Remove leading quote
      final description = parts[2].replaceAll(
        '"',
        '',
      ); // Remove internal quotes if any
      foodMap[fdcId] = description;
    }
  }
  print('Loaded ${foodMap.length} foods.');

  // 2. Read nutrients and match with foods
  // Format: "id","fdc_id","nutrient_id","amount",...
  // We want nutrient_id == "1005" (Carbohydrates, by difference)
  print('Extracting carbohydrate data...');
  final sink = outputFile.openWrite();
  sink.writeln('name,carbs_per_100g'); // Header

  final nutrientLines = await nutrientFile.readAsLines();
  int matchCount = 0;

  for (int i = 1; i < nutrientLines.length; i++) {
    final line = nutrientLines[i];
    if (line.isEmpty) continue;

    final parts = line.split('","');
    if (parts.length > 3) {
      final fdcId = parts[1].replaceAll('"', '');
      final nutrientId = parts[2].replaceAll('"', '');
      final amountStr = parts[3].replaceAll('"', '');

      if (nutrientId == '1005') {
        final description = foodMap[fdcId];
        if (description != null) {
          // Wrap description in quotes to handle intrinsic commas
          sink.writeln('"$description",$amountStr');
          matchCount++;
        }
      }
    }
  }

  // 3. Add Custom Trinidadian Foods
  print('Adding custom Trinidadian foods...');
  final customFoods = {
    'Sada Roti (1 medium)':
        '45.0', // Approx value per piece, entering as "per 100g" format for consistency or standard size
    'Paratha / Buss Up Shut Roti (1 medium)': '60.0',
    'Dhalpuri Roti (1 medium)': '55.0',
    'Doubles (1 pair)': '38.0',
    'Aloo Pie (1 piece)': '40.0',
    'Bake and Shark (1 sandwich)': '65.0',
    'Pelau (1 cup)': '45.0',
    'Callaloo (1 cup)': '12.0',
    'Macaroni Pie (1 slice)': '35.0',
    'Pholourie (5 pieces)': '30.0',
  };

  for (final entry in customFoods.entries) {
    sink.writeln('"${entry.key}",${entry.value}');
    matchCount++;
  }

  await sink.close();
  print(
    'Successfully created cleaned_food_database.csv in assets/database/ with $matchCount items!',
  );
}
