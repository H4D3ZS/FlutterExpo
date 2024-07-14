import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _dartCode;

  Future<void> fetchAppCode() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/app-code'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _dartCode = data['code'];
      });
    } else {
      throw Exception('Failed to load app code');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppCode();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dynamic Flutter App'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchAppCode,
            ),
          ],
        ),
        body: Center(
          child: _dartCode != null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_dartCode!),
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
