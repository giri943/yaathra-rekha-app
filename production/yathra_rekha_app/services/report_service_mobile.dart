import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadPDF(Uint8List pdfBytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(pdfBytes);
  await OpenFile.open(file.path);
}
