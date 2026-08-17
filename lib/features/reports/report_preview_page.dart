import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ReportPreviewPage extends StatelessWidget {
  const ReportPreviewPage({
    super.key,
    required this.pdfBytes,
  });

  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Report',
        ),
      ),

      body: PdfPreview(
        build: (format) async {
          return pdfBytes;
        },

        // Preview only.
        allowPrinting: false,
        allowSharing: false,

        actions: const [],

        canChangePageFormat: false,
        canChangeOrientation: false,

        // Important for report tables.
        maxPageWidth: 900,

        pdfFileName:
        'financial_report.pdf',
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename:
                      'financial_report.pdf',
                    );
                  },
                  icon: const Icon(
                    Icons.share,
                  ),
                  label: const Text(
                    'Share',
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Printing.layoutPdf(
                      onLayout: (format) async {
                        return pdfBytes;
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.print,
                  ),
                  label: const Text(
                    'Print',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}