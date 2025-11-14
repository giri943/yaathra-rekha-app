import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

Future<void> downloadPDF(Uint8List pdfBytes, String filename) async {
  final blob = html.Blob([pdfBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
