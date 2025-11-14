import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class PDFViewerPage extends StatefulWidget {
  final Uint8List pdfBytes;

  const PDFViewerPage({super.key, required this.pdfBytes});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _iframeId;

  @override
  void initState() {
    super.initState();
    _iframeId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    _registerIframe();
  }

  void _registerIframe() {
    final blob = web.Blob([widget.pdfBytes.toJS].toJS, web.BlobPropertyBag(type: 'application/pdf'));
    final url = web.URL.createObjectURL(blob);
    
    ui_web.platformViewRegistry.registerViewFactory(_iframeId!, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

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
      body: HtmlElementView(viewType: _iframeId!),
    );
  }
}
