import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class StatisticPdfService {
  static const _primary = PdfColor.fromInt(0xFF7EB8F7);
  static const _primaryDark = PdfColor.fromInt(0xFF3A85D4);
  static const _primaryLight = PdfColor.fromInt(0xFFE8F4FF);
  static const _accent = PdfColor.fromInt(0xFFF7A8C4);
  static const _accentDark = PdfColor.fromInt(0xFFD4608A);
  static const _accentLight = PdfColor.fromInt(0xFFFFEEF4);
  static const _surface = PdfColor.fromInt(0xFFF8FBFF);
  static const _textPrimary = PdfColor.fromInt(0xFF1E2A3A);
  static const _textSecondary = PdfColor.fromInt(0xFF5A6A7E);
  static const _textOnColor = PdfColor.fromInt(0xFFFFFFFF);
  static const _rowAlt = PdfColor.fromInt(0xFFF0F7FF);
  static const _border = PdfColor.fromInt(0xFFCCDEF0);
  static const _dateBadge = PdfColor.fromInt(0xFF5AA8F0);

  Future<pw.ImageProvider> _loadAsset(String path) async {
    final bytes = await rootBundle.load(path);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  List<DailyStudyData> _aggregateByDate(
    Map<String, List<DailyStudyData>> setStudies,
  ) {
    final totals = <String, int>{};
    for (final studies in setStudies.values) {
      for (final d in studies) {
        totals[d.date] = (totals[d.date] ?? 0) + d.wordsLearned;
      }
    }
    final sorted =
        totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .map((e) => DailyStudyData(date: e.key, wordsLearned: e.value))
        .toList();
  }

  Future<Uint8List> _renderChartToPng({
    required List<DailyStudyData> studies,
    // bonus height
    double width = 1040,
    double height = 420,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    BarChartPainter(studies: studies).paint(canvas, Size(width, height));
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> exportStatisticsPdf({
    required String userName,
    required int learnedWords,
    required double memoryRate,
    required Map<String, List<DailyStudyData>> setStudies,
  }) async {
    final imgBook = await _loadAsset('assets/component/book_watermark.png');
    final imgBrain = await _loadAsset('assets/component/brain.png');
    final imgFolder = await _loadAsset('assets/component/folder.png');
    final imgCal = await _loadAsset('assets/component/calendar.png');
    final imgStar = await _loadAsset('assets/component/star.png');
    final imgLogo = await _loadAsset('assets/component/logo.png');
    final imgChart = await _loadAsset('assets/component/pdf_chart.png');

    final aggregated = _aggregateByDate(setStudies);
    pw.MemoryImage? totalChartImage;
    if (aggregated.isNotEmpty) {
      final pngBytes = await _renderChartToPng(studies: aggregated);
      totalChartImage = pw.MemoryImage(pngBytes);
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
        ),
        header: (ctx) => _buildHeader(ctx, userName, imgLogo),
        footer: (ctx) => _buildFooter(ctx, imgStar),
        build:
            (ctx) => [
              pw.SizedBox(height: 18),
              _buildSummarySection(learnedWords, memoryRate, imgBook, imgBrain),
              pw.SizedBox(height: 22),
              if (totalChartImage != null) ...[
                _buildSectionTitle('Daily Progress', imgChart),
                pw.SizedBox(height: 10),
                _buildTotalChartBox(totalChartImage, aggregated),
                pw.SizedBox(height: 30),
              ],
              if (setStudies.isNotEmpty) ...[
                _buildSectionTitle('Study Details', imgFolder),
                pw.SizedBox(height: 10),
                ...setStudies.entries.map(
                  (e) => _buildSetBlock(e.key, e.value, imgFolder, imgCal),
                ),
              ],
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/learning_report.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  // header
  pw.Widget _buildHeader(
    pw.Context ctx,
    String userName,
    pw.ImageProvider logo,
  ) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: pw.BoxDecoration(
            color: _primary,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 36,
                    height: 36,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Learning Statistics',
                        style: pw.TextStyle(
                          color: _textOnColor,
                          fontSize: 17,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Great job, $userName!',
                        style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFFD0E8FF),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(
                  color: _dateBadge,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  _formatDate(DateTime.now()),
                  style: pw.TextStyle(
                    color: _textOnColor,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  // footer
  pw.Widget _buildFooter(pw.Context ctx, pw.ImageProvider starImg) {
    return pw.Column(
      children: [
        pw.Divider(color: _border, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 12,
                  height: 12,
                  child: pw.Image(starImg, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  'Generated by Your Learning App',
                  style: pw.TextStyle(fontSize: 8.5, color: _textSecondary),
                ),
              ],
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 8.5, color: _textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  // summary
  pw.Widget _buildSummarySection(
    int learnedWords,
    double memoryRate,
    pw.ImageProvider bookImg,
    pw.ImageProvider brainImg,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Summary', bookImg),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildStatCard(
                image: bookImg,
                label: 'Words Learned',
                value: learnedWords.toString(),
                bgColor: _primaryLight,
                valueColor: _primaryDark,
                borderColor: _primary,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildStatCard(
                image: brainImg,
                label: 'Memory Rate',
                value: '${memoryRate.toStringAsFixed(1)}%',
                bgColor: _accentLight,
                valueColor: _accentDark,
                borderColor: _accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildStatCard({
    required pw.ImageProvider image,
    required String label,
    required String value,
    required PdfColor bgColor,
    required PdfColor valueColor,
    required PdfColor borderColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 40,
            height: 40,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: valueColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 9.5, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // section title
  pw.Widget _buildSectionTitle(String title, pw.ImageProvider img) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(
          width: 20,
          height: 20,
          child: pw.Image(img, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: 7),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  // total chart box
  pw.Widget _buildTotalChartBox(
    pw.MemoryImage chartImage,
    List<DailyStudyData> aggregated,
  ) {
    final total = aggregated.fold<int>(0, (s, e) => s + e.wordsLearned);
    final maxVal = aggregated.map((e) => e.wordsLearned).reduce(math.max);
    final avgVal = (total / aggregated.length).round();

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _surface,
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: const pw.BoxDecoration(color: _accentLight),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total words learned per day',
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _accentDark,
                      ),
                    ),
                    pw.Row(
                      children: [
                        _statPill('${aggregated.length} days', _primaryDark),
                        pw.SizedBox(width: 6),
                        _statPill('Peak $maxVal', _accentDark),
                        pw.SizedBox(width: 6),
                        _statPill('Avg $avgVal', _primaryDark),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: _accent, thickness: 0.5),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Image(chartImage, fit: pw.BoxFit.fitWidth),
          ),
        ],
      ),
    );
  }

  pw.Widget _statPill(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color, width: 0.8),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // set block
  pw.Widget _buildSetBlock(
    String setTitle,
    List<DailyStudyData> studies,
    pw.ImageProvider folderImg,
    pw.ImageProvider calImg,
  ) {
    final total = studies.fold<int>(0, (s, e) => s + e.wordsLearned);

    // border, radius
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border, width: 0.8),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // set header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            // just bg color
            decoration: const pw.BoxDecoration(color: _primaryLight),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 15,
                      height: 15,
                      child: pw.Image(folderImg, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 7),
                    pw.Text(
                      setTitle,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: _primaryDark,
                      ),
                    ),
                  ],
                ),
                _wordsBadge('$total words'),
              ],
            ),
          ),
          // divider for header
          pw.Divider(color: _border, thickness: 0.5),
          // table
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: _buildTable(studies, calImg),
          ),
        ],
      ),
    );
  }

  pw.Widget _wordsBadge(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: _accent,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          color: _textOnColor,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // table
  pw.Widget _buildTable(List<DailyStudyData> studies, pw.ImageProvider calImg) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primary),
          children: [_tableHead('Date', calImg), _tableHead('Words', null)],
        ),
        ...studies.asMap().entries.map((entry) {
          final d = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: entry.key.isEven ? PdfColors.white : _rowAlt,
            ),
            children: [
              _tableCell(d.date),
              _tableCell(
                d.wordsLearned.toString(),
                align: pw.TextAlign.center,
                bold: true,
                color: _accentDark,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableHead(String text, pw.ImageProvider? img) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Row(
        children: [
          if (img != null) ...[
            pw.SizedBox(
              width: 10,
              height: 10,
              child: pw.Image(img, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 3),
          ],
          pw.Text(
            text,
            style: pw.TextStyle(
              color: _textOnColor,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          color: color ?? _textPrimary,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// bar chart painter
class BarChartPainter extends CustomPainter {
  final List<DailyStudyData> studies;

  static const _barBlue = Color(0xFF7EB8F7);
  static const _barPink = Color(0xFFF7A8C4);
  static const _gridColor = Color(0xFFCCDEF0);
  static const _bgColor = Color(0xFFF8FBFF);
  static const _textColor = Color(0xFF5A6A7E);
  static const _avgColor = Color(0xFFD4608A);
  static const _blueLabel = Color(0xFF3A85D4);

  const BarChartPainter({required this.studies});

  @override
  void paint(Canvas canvas, Size size) {
    const pL = 52.0, pR = 20.0, pT = 28.0;
    // show jan 1
    const pB = 72.0;
    final cW = size.width - pL - pR;
    final cH = size.height - pT - pB;

    final maxVal =
        studies.map((e) => e.wordsLearned).reduce(math.max).toDouble();
    final avgVal =
        studies.fold<int>(0, (s, e) => s + e.wordsLearned) / studies.length;

    canvas.drawRect(Offset.zero & size, Paint()..color = _bgColor);

    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      final y = pT + cH - cH * i / steps;
      final val = (maxVal * i / steps).round();
      canvas.drawLine(
        Offset(pL, y),
        Offset(pL + cW, y),
        Paint()
          ..color = _gridColor
          ..strokeWidth = (i == 0 ? 1.2 : 0.7),
      );
      _text(canvas, '$val', pL - 4, y - 8, 16, _textColor, TextAlign.right, 44);
    }

    final slot = cW / studies.length;
    final barW = math.min(slot * 0.55, 60.0);
    const r = Radius.circular(5);

    for (int i = 0; i < studies.length; i++) {
      final v = studies[i].wordsLearned.toDouble();
      final barH = cH * v / maxVal;
      final x = pL + i * slot + (slot - barW) / 2;
      final y = pT + cH - barH;
      final isPeak = v == maxVal;

      // shadow
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x + 2, y + 3, barW, barH),
          topLeft: r,
          topRight: r,
        ),
        Paint()..color = _barBlue.withOpacity(0.15),
      );
      // bar
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: r,
          topRight: r,
        ),
        Paint()..color = isPeak ? _barPink : _barBlue,
      );
      // value label trên bar
      _text(
        canvas,
        '${studies[i].wordsLearned}',
        x,
        y - 22,
        17,
        isPeak ? _avgColor : _blueLabel,
        TextAlign.center,
        barW,
        bold: true,
      );

      // date label in center align
      final dateStr = _shortDate(studies[i].date);
      final tp = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: TextStyle(fontSize: 12, color: _textColor),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      final labelX = x + (barW - tp.width) / 2;
      tp.paint(canvas, Offset(labelX, pT + cH + 8));
    }

    final avgY = pT + cH - cH * avgVal / maxVal;
    _dashedLine(
      canvas,
      pL,
      avgY,
      pL + cW,
      Paint()
        ..color = _avgColor
        ..strokeWidth = 1.6,
    );
    _text(
      canvas,
      'avg ${avgVal.toStringAsFixed(1)}',
      pL + cW - 90,
      avgY - 24,
      16,
      _avgColor,
      TextAlign.left,
      110,
      bold: true,
    );
  }

  void _dashedLine(Canvas canvas, double x1, double y, double x2, Paint p) {
    var x = x1;
    while (x < x2) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 8, x2), y), p);
      x += 13;
    }
  }

  void _text(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fs,
    Color color,
    TextAlign align,
    double maxW, {
    bool bold = false,
  }) {
    (TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fs,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textAlign: align,
          textDirection: ui.TextDirection.ltr,
        )..layout(maxWidth: maxW))
        .paint(canvas, Offset(x, y));
  }

  // date format
  String _shortDate(String date) {
    const mo = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    try {
      // format yyyy-MM-dd
      if (date.contains('-')) {
        final p = date.split('-');
        if (p.length == 3 && p[0].length == 4) {
          final month = int.parse(p[1]);
          final day   = int.parse(p[2]);
          if (month >= 1 && month <= 12) return '${mo[month]} $day';
        }
      }
      // format /
      if (date.contains('/')) {
        final p = date.split('/');
        if (p.length == 3) {
          if (p[2].length == 4) {
            final a = int.parse(p[0]); 
            final b = int.parse(p[1]); 
            int day, month;
            if (a > 12) {
              day = a; month = b;       // dd/mm/yyyy
            } else if (b > 12) {
              month = a; day = b;       // mm/dd/yyyy
            } else {
              day = a; month = b;       // default dd/mm/yyyy
            }
            if (month >= 1 && month <= 12) return '${mo[month]} $day';
          }
        }
      }
    } catch (_) {}
    return date;
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class DailyStudyData {
  final String date;
  final int wordsLearned;
  const DailyStudyData({required this.date, required this.wordsLearned});
}