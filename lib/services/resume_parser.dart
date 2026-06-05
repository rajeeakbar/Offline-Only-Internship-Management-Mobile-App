import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ResumeParser {
  static Future<Map<String, String>> parseResume(String filePath) async {
    try {
      final File file = File(filePath);
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();

      return _extractInfo(text);
    } catch (e) {
      return {};
    }
  }

  static Map<String, String> _extractInfo(String text) {
    Map<String, String> info = {};

    // Simple logic for extracting info
    // In a real app, this would use more complex regex or NLP

    // Name: Usually the first line
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      info['name'] = lines[0].trim();
    }

    // Email: Regex for email
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      info['email'] = emailMatch.group(0)!;
    }

    // Skills & Education: Basic keyword search
    if (text.toLowerCase().contains('skills')) {
      final startIndex = text.toLowerCase().indexOf('skills');
      final endIndex = text.indexOf('\n', startIndex + 20); // Get some context
      info['skills'] = text.substring(startIndex, endIndex != -1 ? endIndex : text.length).replaceAll('\n', ', ').trim();
    }

    if (text.toLowerCase().contains('education')) {
      final startIndex = text.toLowerCase().indexOf('education');
      final endIndex = text.indexOf('\n', startIndex + 50);
      info['education'] = text.substring(startIndex, endIndex != -1 ? endIndex : text.length).replaceAll('\n', ' ').trim();
    }

    return info;
  }
}
