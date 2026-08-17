import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ReceiptPreviewPage extends StatelessWidget {
  const ReceiptPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.receiptNumber,
  });

  final Uint8List pdfBytes;
  final String receiptNumber;

  Future<void> _share() async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'receipt_$receiptNumber.pdf',
    );
  }

  Future<void> _print() async {
    await Printing.layoutPdf(
      onLayout: (format) async {
        return pdfBytes;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
      ),

      body: Column(
        children: [
          // ==========================================
          // PDF PREVIEW
          // ==========================================

          Expanded(
            child: PdfPreview(
              build: (format) async {
                return pdfBytes;
              },

              // Hide PdfPreview's default actions.
              actions: const [],

              // Keep preview fixed.
              canChangePageFormat: false,
              canChangeOrientation: false,

              // We provide our own buttons below.
              allowPrinting: false,
              allowSharing: false,

              pdfFileName:
              'receipt_$receiptNumber.pdf',
            ),
          ),

          // ==========================================
          // BOTTOM ACTIONS
          // ==========================================

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),

              child: Row(
                children: [
                  // ----------------------------------
                  // SHARE
                  // ----------------------------------

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,

                      icon: const Icon(
                        Icons.share,
                      ),

                      label: const Text(
                        'Share',
                      ),

                      style:
                      OutlinedButton.styleFrom(
                        minimumSize:
                        const Size(
                          0,
                          50,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  // ----------------------------------
                  // PRINT
                  // ----------------------------------

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _print,

                      icon: const Icon(
                        Icons.print,
                      ),

                      label: const Text(
                        'Print',
                      ),

                      style:
                      ElevatedButton.styleFrom(
                        minimumSize:
                        const Size(
                          0,
                          50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}