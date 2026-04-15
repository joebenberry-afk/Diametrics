import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';

class ExportService {
  /// Generates and opens a PDF report for the given date range.
  static Future<void> generateAndShareReport({
    required String patientName,
    required String diabetesType,
    required String preferredUnit,
    required double targetMin,
    required double targetMax,
    required List<GlucoseLog> glucoseLogs,
    required List<MealLog> mealLogs,
    required List<MedicationLog> medicationLogs,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    // Filter logs to date range
    final rangeEndInclusive = rangeEnd.add(const Duration(days: 1));
    final glucose = glucoseLogs
        .where((g) =>
            g.timestamp.isAfter(rangeStart) &&
            g.timestamp.isBefore(rangeEndInclusive))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final meals = mealLogs
        .where((m) =>
            m.timestamp.isAfter(rangeStart) &&
            m.timestamp.isBefore(rangeEndInclusive))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final meds = medicationLogs
        .where((m) =>
            m.timestamp.isAfter(rangeStart) &&
            m.timestamp.isBefore(rangeEndInclusive))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Compute stats
    final displayFactor = preferredUnit == 'mmol/L' ? 1 / 18.0182 : 1.0;
    final decimals = preferredUnit == 'mmol/L' ? 1 : 0;
    double toMgdl(GlucoseLog g) =>
        g.unit == 'mmol/L' ? g.value * 18.0182 : g.value;
    final glucoseMgdl = glucose.map(toMgdl).toList();
    final avgGlucose = glucoseMgdl.isEmpty
        ? 0.0
        : glucoseMgdl.reduce((a, b) => a + b) / glucoseMgdl.length;
    final inRange =
        glucoseMgdl.where((v) => v >= targetMin && v <= targetMax).length;
    final belowRange = glucoseMgdl.where((v) => v < targetMin).length;
    final tirPct = glucoseMgdl.isEmpty
        ? 0.0
        : (inRange / glucoseMgdl.length) * 100;
    final belowPct = glucoseMgdl.isEmpty
        ? 0.0
        : (belowRange / glucoseMgdl.length) * 100;
    final abovePct = glucoseMgdl.isEmpty ? 0.0 : 100 - tirPct - belowPct;
    final totalCarbs = meals.fold(0.0, (sum, m) => sum + m.carbohydrates);
    final totalCalories = meals.fold(0.0, (sum, m) => sum + m.calories);
    // Estimated HbA1c (DCCT formula): (avgGlucose + 46.7) / 28.7
    final hba1c = avgGlucose > 0 ? (avgGlucose + 46.7) / 28.7 : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('DiaMetrics Report',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${dateFormat.format(rangeStart)} - ${dateFormat.format(rangeEnd)}',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
                '$patientName | $diabetesType | Target: ${(targetMin * displayFactor).toStringAsFixed(decimals)}-${(targetMax * displayFactor).toStringAsFixed(decimals)} $preferredUnit',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          // Summary stats
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfStatBox('Avg Glucose',
                  '${(avgGlucose * displayFactor).toStringAsFixed(decimals)} $preferredUnit'),
              _pdfStatBox(
                  'Time in Range', '${tirPct.toStringAsFixed(0)}%'),
              _pdfStatBox(
                  'Below Range', '${belowPct.toStringAsFixed(0)}%'),
              _pdfStatBox('Est. HbA1c', '${hba1c.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfStatBox('Readings', '${glucose.length}'),
              _pdfStatBox('Meals', '${meals.length}'),
              _pdfStatBox(
                  'Total Carbs', '${totalCarbs.toStringAsFixed(0)}g'),
              _pdfStatBox('Total Cal',
                  '${totalCalories.toStringAsFixed(0)} kcal'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfStatBox('Above Range', '${abovePct.toStringAsFixed(0)}%'),
              _pdfStatBox('Medications', '${meds.length} doses'),
              _pdfStatBox('', ''),
              _pdfStatBox('', ''),
            ],
          ),
          pw.SizedBox(height: 16),

          // Glucose log table
          if (glucose.isNotEmpty) ...[
            pw.Text('Glucose Readings',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              headers: ['Date', 'Time', 'Value', 'Context'],
              data: glucose
                  .take(50)
                  .map((g) => [
                        dateFormat.format(g.timestamp),
                        timeFormat.format(g.timestamp),
                        '${(toMgdl(g) * displayFactor).toStringAsFixed(decimals)} $preferredUnit',
                        g.context.replaceAll('_', ' '),
                      ])
                  .toList(),
            ),
            if (glucose.length > 50)
              pw.Text('... and ${glucose.length - 50} more readings',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 16),
          ],

          // Meal log table
          if (meals.isNotEmpty) ...[
            pw.Text('Meal Log',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              headers: [
                'Date',
                'Time',
                'Type',
                'Carbs',
                'Protein',
                'Fat',
                'Cal'
              ],
              data: meals
                  .take(50)
                  .map((m) => [
                        dateFormat.format(m.timestamp),
                        timeFormat.format(m.timestamp),
                        m.mealType,
                        '${m.carbohydrates.toStringAsFixed(0)}g',
                        '${m.proteins.toStringAsFixed(0)}g',
                        '${m.fats.toStringAsFixed(0)}g',
                        m.calories.toStringAsFixed(0),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 16),
          ],

          // Medication log table
          if (meds.isNotEmpty) ...[
            pw.Text('Medication Log',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              headers: ['Date', 'Time', 'Type', 'Name', 'Units'],
              data: meds
                  .take(50)
                  .map((m) => [
                        dateFormat.format(m.timestamp),
                        timeFormat.format(m.timestamp),
                        m.medicationType.replaceAll('_', ' '),
                        m.name ?? '-',
                        m.units.toStringAsFixed(1),
                      ])
                  .toList(),
            ),
          ],

          pw.SizedBox(height: 24),
          pw.Text('Generated by DiaMetrics',
              style: const pw.TextStyle(
                  fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'diametrics_report_${dateFormat.format(rangeStart)}.pdf');
  }

  static pw.Widget _pdfStatBox(String label, String value) {
    if (label.isEmpty) {
      return pw.SizedBox(width: 100);
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }
}
