import 'dart:convert';
import 'package:citav_app/entities/localInspection.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class InspectionsListScreen extends StatefulWidget {
  @override
  _InspectionsListScreenState createState() => _InspectionsListScreenState();
}

class _InspectionsListScreenState extends State<InspectionsListScreen> {
  List<LocalInspection> localInspections = [];

  @override
  void initState() {
    super.initState();
    _loadLocalInspections();
  }

  Future<void> _loadLocalInspections() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/inspections_local.json';

      final File file = File(filePath);

      if (await file.exists()) {
        final String fileContent = await file.readAsString();
        final List<dynamic> inspectionsData = jsonDecode(fileContent);

        setState(() {
          localInspections = inspectionsData
              .map((data) => LocalInspection.fromJson(data))
              .toList();
        });

        print('Local inspections loaded from file');
      } else {
        print('No local inspections file found');
      }
    } catch (error) {
      print('Error loading local inspections: $error');
    }
  }

  Future<void> _clearLocalInspections() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/inspections_local.json';
    final File file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      setState(() {
        localInspections.clear();
      });
      print('Local inspections cleared');
    } else {
      print('No local inspections file found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspections List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearLocalInspections,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: localInspections.length,
        itemBuilder: (context, index) {
          final inspection = localInspections[index];
          final jsonString = jsonEncode(inspection.toJson());
          return ListTile(
            title: Text(
              'Inspection $index',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              jsonString,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          );
        },
      ),
    );
  }
}
