import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BackupScreen extends StatefulWidget {
  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  String? _lastBackupPath;

  Future<void> _exportToPDF() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthService>().currentUserId;
      if (userId == null) throw 'User not authenticated';

      final filePath = await DatabaseHelper.instance.exportTasksToPDF(userId);
      setState(() => _lastBackupPath = filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tasks exported to PDF successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting tasks: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Export your tasks to PDF format for backup or sharing.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportToPDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Export to PDF'),
            ),
            if (_isLoading) ...[
              SizedBox(height: 24),
              Center(child: CircularProgressIndicator()),
            ],
            if (_lastBackupPath != null) ...[
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Backup',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Location: $_lastBackupPath',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
