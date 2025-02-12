import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  static Future<Map<dynamic, dynamic>> loadJsonSchema() async {
    String jsonString = await rootBundle.loadString('assets/castecertificateSchema.json');
    final Map<dynamic, dynamic> schema = jsonDecode(jsonString) as Map<dynamic, dynamic>;
    return schema;
  }
}
