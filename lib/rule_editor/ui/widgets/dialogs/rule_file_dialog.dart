import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../../core/theme/studio_theme.dart';
import '../../../services/rule_storage_service.dart';

class RuleFileDialog extends StatefulWidget {
  final RuleStorageService storageService;

  const RuleFileDialog({super.key, required this.storageService});

  static Future<String?> show(BuildContext context, RuleStorageService storageService) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => RuleFileDialog(storageService: storageService),
    );
  }

  @override
  State<RuleFileDialog> createState() => _RuleFileDialogState();
}

class _RuleFileDialogState extends State<RuleFileDialog> {
  late List<FileSystemEntity> _files;
  String? _selectedFilePath;
  String? _previewName;
  String? _previewExpression;

  @override
  void initState() {
    super.initState();
    _refreshFiles();
  }

  void _refreshFiles() {
    _files = widget.storageService.listRuleFiles();
    if (_files.isNotEmpty) {
      _selectFile(_files.first.path);
    }
  }

  void _selectFile(String path) {
    setState(() {
      _selectedFilePath = path;
      try {
        final content = File(path).readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _previewName = json['name'] as String? ?? p.basenameWithoutExtension(path);
        _previewExpression = json['expression'] as String? ?? '';
      } catch (e) {
        _previewName = p.basenameWithoutExtension(path);
        _previewExpression = 'Error previewing: $e';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: StudioTheme.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: StudioTheme.outlineVariant, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_open, size: 20, color: StudioTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Load Cellular Rule',
                        style: TextStyle(
                          fontFamily: StudioTheme.monoFont,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: StudioTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Directory: ${p.basename(widget.storageService.rulesDirectory.path)}',
                    style: const TextStyle(
                      fontFamily: StudioTheme.monoFont,
                      fontSize: 11,
                      color: StudioTheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // File List & Preview Split
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: File list
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: StudioTheme.surfaceLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3)),
                        ),
                        child: _files.isEmpty
                            ? const Center(
                                child: Text(
                                  'No .json rules found',
                                  style: TextStyle(color: StudioTheme.outline),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _files.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: StudioTheme.outlineVariant.withOpacity(0.15),
                                ),
                                itemBuilder: (context, index) {
                                  final file = _files[index];
                                  final isSelected = file.path == _selectedFilePath;
                                  final fileName = p.basename(file.path);

                                  return ListTile(
                                    dense: true,
                                    selected: isSelected,
                                    selectedTileColor: StudioTheme.primary.withOpacity(0.12),
                                    leading: Icon(
                                      Icons.description_outlined,
                                      size: 16,
                                      color: isSelected ? StudioTheme.primary : StudioTheme.outline,
                                    ),
                                    title: Text(
                                      fileName,
                                      style: TextStyle(
                                        fontFamily: StudioTheme.monoFont,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? StudioTheme.primary : StudioTheme.onSurface,
                                      ),
                                    ),
                                    onTap: () => _selectFile(file.path),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right: Preview
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: StudioTheme.surfaceLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'RULE PREVIEW',
                              style: TextStyle(
                                fontFamily: StudioTheme.monoFont,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: StudioTheme.outline,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _previewName ?? 'No file selected',
                              style: const TextStyle(
                                fontFamily: StudioTheme.monoFont,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: StudioTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Expression:',
                              style: TextStyle(
                                fontFamily: StudioTheme.bodyFont,
                                fontSize: 11,
                                color: StudioTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: StudioTheme.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.2)),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    _previewExpression ?? '',
                                    style: const TextStyle(
                                      fontFamily: StudioTheme.monoFont,
                                      fontSize: 11,
                                      height: 1.4,
                                      color: StudioTheme.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel', style: TextStyle(color: StudioTheme.outline)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudioTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Load Rule'),
                    onPressed: _selectedFilePath != null
                        ? () => Navigator.of(context).pop(_selectedFilePath)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
