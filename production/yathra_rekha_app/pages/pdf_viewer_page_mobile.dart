import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFViewerPage({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        title: Text(
          'ബില്ലിംഗ് റിപ്പോർട്ട്',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}
