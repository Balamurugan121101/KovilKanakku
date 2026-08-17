import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/donation_model.dart';

class ReceiptService {
  static Future<Uint8List> generateDonationReceipt({
    required DonationModel donation,
    required String templeName,
    required String address,
    required String phone,
    String? eventName,
  }) async {
    final pdf = pw.Document();

    // Load Noto Sans Tamil Regular.
    final regularFont = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/NotoSansTamil-Regular.ttf',
      ),
    );

    // Use the same regular font for bold text.
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: regularFont,
    );

    final amountFormatter = NumberFormat.currency(
      locale: 'en_IN',
      decimalDigits: 2,
      symbol: '₹ ',
    );

    final dateFormatter = DateFormat(
      'dd-MM-yyyy',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(32),

        build: (context) {
          return pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.stretch,
            children: [
              // TEMPLE NAME
              pw.Center(
                child: pw.Text(
                  templeName,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 22,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                  textAlign:
                  pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 6),

              // ADDRESS
              pw.Center(
                child: pw.Text(
                  address,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                  ),
                  textAlign:
                  pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 4),

              // PHONE
              pw.Center(
                child: pw.Text(
                  'Phone: $phone',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.SizedBox(height: 10),

              // TITLE
              pw.Center(
                child: pw.Text(
                  'DONATION RECEIPT',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 18,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // DETAILS
              _pdfRow(
                'Receipt Number',
                donation.receiptNumber,
                regularFont,
              ),

              _pdfRow(
                'Donor Name',
                donation.donorName,
                regularFont,
              ),

              _pdfRow(
                'Phone',
                donation.phone ?? '-',
                regularFont,
              ),

              _pdfRow(
                'Amount',
                amountFormatter.format(
                  donation.amount,
                ),
                regularFont,
              ),

              _pdfRow(
                'Purpose',
                donation.purpose ??
                    'General Donation',
                regularFont,
              ),

              // EVENT
              if (eventName != null &&
                  eventName.trim().isNotEmpty)
                _pdfRow(
                  'Event',
                  eventName,
                  regularFont,
                ),

              _pdfRow(
                'Date',
                dateFormatter.format(
                  donation.donatedAt,
                ),
                regularFont,
              ),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.SizedBox(height: 20),

              // TOTAL
              pw.Container(
                padding:
                const pw.EdgeInsets.all(16),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey,
                  ),
                  borderRadius:
                  pw.BorderRadius.circular(6),
                ),

                child: pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment
                      .spaceBetween,

                  children: [
                    pw.Text(
                      'Total Donation',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 16,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text(
                      amountFormatter.format(
                        donation.amount,
                      ),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 18,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // FOOTER
              pw.Center(
                child: pw.Text(
                  'Thank you for your generous contribution.',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                  ),
                  textAlign:
                  pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ==================================================
  // PDF ROW
  // ==================================================

  static pw.Widget _pdfRow(
      String label,
      String value,
      pw.Font font,
      ) {
    return pw.Padding(
      padding:
      const pw.EdgeInsets.symmetric(
        vertical: 7,
      ),

      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,

        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              textAlign:
              pw.TextAlign.right,
              style: pw.TextStyle(
                font: font,
              ),
            ),
          ),
        ],
      ),
    );
  }
}