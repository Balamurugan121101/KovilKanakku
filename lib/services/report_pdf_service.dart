import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/settings_model.dart';
import '../providers/report_provider.dart';

class ReportPdfService {
  static Future<Uint8List> generateReport({
    required ReportData report,
    required ReportFilter filter,
    required SettingsModel settings,
    String? eventName,
  }) async {
    final pdf =
    pw.Document();

    // ------------------------------------------------------------
    // Noto Sans Tamil Regular
    // ------------------------------------------------------------

    final fontData =
    await rootBundle.load(
      'assets/fonts/NotoSansTamil-Regular.ttf',
    );

    final tamilFont =
    pw.Font.ttf(fontData);

    final currencyFormat =
    NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );

    final dateFormat =
    DateFormat('dd MMM yyyy');

    final dateTimeFormat =
    DateFormat(
      'dd MMM yyyy, hh:mm a',
    );

    // ------------------------------------------------------------
    // Generate report title
    // ------------------------------------------------------------

    final periodTitle =
    _periodTitle(filter);

    pdf.addPage(
      pw.MultiPage(
        pageFormat:
        PdfPageFormat.a4,

        margin:
        const pw.EdgeInsets.fromLTRB(
          28,
          30,
          28,
          30,
        ),

        theme:
        pw.ThemeData.withFont(
          base: tamilFont,
        ),

        header: (context) {
          return _header(
            settings: settings,
            filter: filter,
            eventName: eventName,
            periodTitle: periodTitle,
            font: tamilFont,
          );
        },

        footer: (context) {
          return _footer(
            context: context,
            font: tamilFont,
          );
        },

        build: (context) {
          return [
            pw.SizedBox(
              height: 18,
            ),

            // ====================================================
            // SUMMARY
            // ====================================================

            _sectionTitle(
              'Summary',
              tamilFont,
            ),

            pw.SizedBox(
              height: 8,
            ),

            _summaryTable(
              report,
              currencyFormat,
              tamilFont,
            ),

            pw.SizedBox(
              height: 20,
            ),

            // ====================================================
            // DONATIONS
            // ====================================================

            _sectionTitle(
              'Donations',
              tamilFont,
            ),

            pw.SizedBox(
              height: 8,
            ),

            if (report.donations.isEmpty)
              _emptyMessage(
                'No donations found',
                tamilFont,
              )
            else
              _donationsTable(
                report.donations,
                currencyFormat,
                dateFormat,
                tamilFont,
              ),

            pw.SizedBox(
              height: 24,
            ),

            // ====================================================
            // EXPENSES
            // ====================================================

            _sectionTitle(
              'Expenses',
              tamilFont,
            ),

            pw.SizedBox(
              height: 8,
            ),

            if (report.expenses.isEmpty)
              _emptyMessage(
                'No expenses found',
                tamilFont,
              )
            else
              _expensesTable(
                report.expenses,
                currencyFormat,
                dateFormat,
                tamilFont,
              ),

            pw.SizedBox(
              height: 24,
            ),

            // ====================================================
            // FINAL BALANCE
            // ====================================================

            _balanceBox(
              report,
              currencyFormat,
              tamilFont,
            ),

            pw.SizedBox(
              height: 10,
            ),

            pw.Align(
              alignment:
              pw.Alignment.centerRight,
              child: pw.Text(
                'Generated on '
                    '${dateTimeFormat.format(DateTime.now())}',
                style: pw.TextStyle(
                  font: tamilFont,
                  fontSize: 8,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // =============================================================
  // HEADER
  // =============================================================

  static pw.Widget _header({
    required SettingsModel settings,
    required ReportFilter filter,
    required String? eventName,
    required String periodTitle,
    required pw.Font font,
  }) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            settings.templeName,
            textAlign:
            pw.TextAlign.center,
            style: pw.TextStyle(
              font: font,
              fontSize: 19,
            ),
          ),
        ),

        if (settings.address
            .trim()
            .isNotEmpty)
          pw.Padding(
            padding:
            const pw.EdgeInsets.only(
              top: 3,
            ),
            child: pw.Center(
              child: pw.Text(
                settings.address,
                textAlign:
                pw.TextAlign.center,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
            ),
          ),

        if (settings.phone
            .trim()
            .isNotEmpty)
          pw.Padding(
            padding:
            const pw.EdgeInsets.only(
              top: 2,
            ),
            child: pw.Center(
              child: pw.Text(
                settings.phone,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
            ),
          ),

        pw.SizedBox(
          height: 8,
        ),

        pw.Center(
          child: pw.Text(
            'Financial Report',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
            ),
          ),
        ),

        pw.SizedBox(
          height: 3,
        ),

        pw.Center(
          child: pw.Text(
            periodTitle,
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
            ),
          ),
        ),

        if (eventName != null &&
            eventName.trim().isNotEmpty)
          pw.Padding(
            padding:
            const pw.EdgeInsets.only(
              top: 2,
            ),
            child: pw.Center(
              child: pw.Text(
                'Event: $eventName',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                ),
              ),
            ),
          ),

        pw.SizedBox(
          height: 8,
        ),

        pw.Divider(
          thickness: 0.8,
        ),
      ],
    );
  }

  // =============================================================
  // FOOTER
  // =============================================================

  static pw.Widget _footer({
    required pw.Context context,
    required pw.Font font,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: 10,
      ),
      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Kovil Kanakku',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION TITLE
  // =============================================================

  static pw.Widget _sectionTitle(
      String title,
      pw.Font font,
      ) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: 13,
      ),
    );
  }

  // =============================================================
  // SUMMARY TABLE
  // =============================================================

  static pw.Widget _summaryTable(
      ReportData report,
      NumberFormat currencyFormat,
      pw.Font font,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },

      children: [
        _tableRow(
          'Total Donations',
          currencyFormat.format(
            report.totalDonations,
          ),
          font,
        ),

        _tableRow(
          'Total Expenses',
          currencyFormat.format(
            report.totalExpenses,
          ),
          font,
        ),

        _tableRow(
          'Balance',
          currencyFormat.format(
            report.balance,
          ),
          font,
        ),

        _tableRow(
          'Donation Transactions',
          report.donationCount
              .toString(),
          font,
        ),

        _tableRow(
          'Expense Transactions',
          report.expenseCount
              .toString(),
          font,
        ),
      ],
    );
  }

  // =============================================================
  // DONATION TABLE
  // =============================================================

  static pw.Widget _donationsTable(
      List donations,
      NumberFormat currencyFormat,
      DateFormat dateFormat,
      pw.Font font,
      ) {
    return pw.TableHelper.fromTextArray(
      headers: [
        'Date',
        'Donor',
        'Purpose',
        'Amount',
      ],

      data: donations.map(
            (donation) {
          return [
            dateFormat.format(
              donation.donatedAt,
            ),

            donation.donorName,

            donation.purpose
                ?.trim()
                .isNotEmpty ==
                true
                ? donation.purpose!
                : 'General',

            currencyFormat.format(
              donation.amount,
            ),
          ];
        },
      ).toList(),

      headerStyle:
      pw.TextStyle(
        font: font,
        fontSize: 8,
      ),

      cellStyle:
      pw.TextStyle(
        font: font,
        fontSize: 8,
      ),

      headerDecoration:
      const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),

      border:
      pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.4,
      ),

      cellPadding:
      const pw.EdgeInsets.all(
        5,
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.4),
      },

      cellAlignments: {
        3: pw.Alignment.centerRight,
      },
    );
  }

  // =============================================================
  // EXPENSE TABLE
  // =============================================================

  static pw.Widget _expensesTable(
      List expenses,
      NumberFormat currencyFormat,
      DateFormat dateFormat,
      pw.Font font,
      ) {
    return pw.TableHelper.fromTextArray(
      headers: [
        'Date',
        'Description',
        'Category',
        'Amount',
      ],

      data: expenses.map(
            (expense) {
          return [
            dateFormat.format(
              expense.date,
            ),

            expense.description,

            expense.category,

            currencyFormat.format(
              expense.amount,
            ),
          ];
        },
      ).toList(),

      headerStyle:
      pw.TextStyle(
        font: font,
        fontSize: 8,
      ),

      cellStyle:
      pw.TextStyle(
        font: font,
        fontSize: 8,
      ),

      headerDecoration:
      const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),

      border:
      pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.4,
      ),

      cellPadding:
      const pw.EdgeInsets.all(
        5,
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.6),
        3: const pw.FlexColumnWidth(1.4),
      },

      cellAlignments: {
        3: pw.Alignment.centerRight,
      },
    );
  }

  // =============================================================
  // BALANCE
  // =============================================================

  static pw.Widget _balanceBox(
      ReportData report,
      NumberFormat currencyFormat,
      pw.Font font,
      ) {
    return pw.Container(
      padding:
      const pw.EdgeInsets.all(
        12,
      ),

      decoration:
      pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey500,
          width: 0.8,
        ),
      ),

      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment
            .spaceBetween,

        children: [
          pw.Text(
            'Final Balance',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),

          pw.Text(
            currencyFormat.format(
              report.balance,
            ),
            style: pw.TextStyle(
              font: font,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EMPTY MESSAGE
  // =============================================================

  static pw.Widget _emptyMessage(
      String message,
      pw.Font font,
      ) {
    return pw.Container(
      width: double.infinity,

      padding:
      const pw.EdgeInsets.all(
        12,
      ),

      decoration:
      pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
      ),

      child: pw.Text(
        message,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
        ),
      ),
    );
  }

  // =============================================================
  // TABLE ROW
  // =============================================================

  static pw.TableRow _tableRow(
      String label,
      String value,
      pw.Font font,
      ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding:
          const pw.EdgeInsets.all(
            7,
          ),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
            ),
          ),
        ),

        pw.Padding(
          padding:
          const pw.EdgeInsets.all(
            7,
          ),
          child: pw.Align(
            alignment:
            pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // PERIOD TITLE
  // =============================================================

  static String _periodTitle(
      ReportFilter filter,
      ) {
    switch (filter.period) {
      case ReportPeriod.today:
        return 'Today';

      case ReportPeriod.thisWeek:
        return 'This Week';

      case ReportPeriod.thisMonth:
        return 'This Month';

      case ReportPeriod.thisYear:
        return 'This Year';

      case ReportPeriod.custom:
        if (filter.customStart !=
            null &&
            filter.customEnd != null) {
          final format =
          DateFormat(
            'dd MMM yyyy',
          );

          return '${format.format(filter.customStart!)}'
              ' - '
              '${format.format(filter.customEnd!)}';
        }

        return 'Custom Period';
    }
  }
}