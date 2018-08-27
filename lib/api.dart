import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Api {
  final HttpClient _httpClient = HttpClient();
  final String _url = 'flutter.udacity.com';
  final apiCategory = {
    'name': 'Currency',
    'route': 'currency',
  };

  Future<List> getUnits(String category) async {
    final jsonResponse = await _getJson(Uri.https(_url, '/$category'));
    if (jsonResponse == null || jsonResponse['units'] == null) {
      print('Error retrieving units.');
      return null;
    }

    return jsonResponse['units'];
  }

  Future convert(
      String category, String amount, String fromUnit, String toUnit) async {
    final jsonResponse = await _getJson(Uri.https(_url, '/$category/convert',
        {'amount': amount, 'from': fromUnit, 'to': toUnit}));

    if (jsonResponse == null || jsonResponse['status'] == null) {
      print('Error retrieving conversion');
      return null;
    } else if (jsonResponse['status'] == 'error') {
      print(jsonResponse['messafe']);
      return null;
    }

    return jsonResponse['conversion'].toDouble();
  }

  Future _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) return null;
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}