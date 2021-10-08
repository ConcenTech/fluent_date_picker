import 'package:fluent_date_picker/fluent_date_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fluent Datepicker'),
        ),
        body: const TestPage(),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FluentDatePicker(
        selected: _selectedDate,
        onChanged: (value) => setState(() {
          _selectedDate = value;
        }),
      ),
    );
  }
}
