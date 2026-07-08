import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';
import 'package:orsocook/services/webdocuments/webdocuments_service.dart';
import 'package:orsocook/screens/webdocuments/webdocuments_login.dart';
import 'package:orsocook/screens/webdocuments/webdocuments_list.dart';

class WebDocumentsDashboard extends StatefulWidget {
  const WebDocumentsDashboard({super.key});

  @override
  State<WebDocumentsDashboard> createState() => _WebDocumentsDashboardState();
}

class _WebDocumentsDashboardState extends State<WebDocumentsDashboard> {
  final WebDocumentsService _service = WebDocumentsService();
  final AuthStorage _authStorage = AuthStorage();
  List<dynamic> _documents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await _service.getDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento documenti';
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getPdfUrl(Map<String, dynamic> doc,
      {bool download = false}) async {
    final authData = await _authStorage.loadAuthData();
    final baseUrl = Config.buildUrl();
    final url =
        '$baseUrl/api/webdocuments/download/${doc['fileName']}?token=${authData?.token ?? ''}';
    return download ? '$url&download=true' : url;
  }

  Future<void> _openPdf(Map<String, dynamic> doc) async {
    final url = await _getPdfUrl(doc);
    if (!mounted) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _downloadPdf(Map<String, dynamic> doc) async {
    final url = await _getPdfUrl(doc, download: true);
    if (!mounted) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    if (!mounted) return;

    final formResult = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _DocumentFormDialog(),
    );

    if (formResult == null) return;

    try {
      await _service.createDocument(
        description: formResult['description']!,
        documentDate: formResult['documentDate']!,
        ente: formResult['ente']!,
        fileBytes: file.bytes!,
        fileName: file.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento caricato con successo')),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento: $e')),
        );
      }
    }
  }

  Future<void> _editDocument(Map<String, dynamic> doc) async {
    final formResult = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _DocumentFormDialog(
        initialDescription: doc['description'] ?? '',
        initialDate: doc['documentDate'] ?? '',
        initialEnte: doc['ente'] ?? '',
      ),
    );

    if (formResult == null) return;

    try {
      await _service.updateDocument(
        id: doc['id'],
        description: formResult['description'],
        documentDate: formResult['documentDate'],
        ente: formResult['ente'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento aggiornato')),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nella modifica')),
        );
      }
    }
  }

  Future<void> _deleteDocument(Map<String, dynamic> doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina documento'),
        content: Text('Sei sicuro di voler eliminare "${doc['description']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteDocument(doc['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento eliminato')),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nell\'eliminazione')),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Dashboard WebDocuments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WebDocumentsList()),
              );
            },
            tooltip: 'Vai alla lista',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
              );
            },
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _uploadDocument,
            tooltip: 'Carica documento',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDocuments,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : _documents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open,
                              size: 64, color: Colors.white54),
                          const SizedBox(height: 16),
                          const Text(
                            'Nessun documento',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _uploadDocument,
                            icon: const Icon(Icons.add),
                            label: const Text('Carica il primo documento'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final doc = _documents[index];
                        return Card(
                          color: Colors.white.withAlpha(15),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              doc['description'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatDate(doc['documentDate'] ?? '')} - ${doc['ente'] ?? ''}',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                Text(
                                  'File: ${doc['fileName'] ?? ''}',
                                  style: const TextStyle(
                                      color: Colors.amber, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Colors.cyanAccent),
                                  onPressed: () => _openPdf(doc),
                                  tooltip: 'Anteprima',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download,
                                      color: Colors.greenAccent),
                                  onPressed: () => _downloadPdf(doc),
                                  tooltip: 'Download',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => _editDocument(doc),
                                  tooltip: 'Modifica',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _deleteDocument(doc),
                                  tooltip: 'Elimina',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _DocumentFormDialog extends StatefulWidget {
  final String? initialDescription;
  final String? initialDate;
  final String? initialEnte;

  const _DocumentFormDialog({
    this.initialDescription,
    this.initialDate,
    this.initialEnte,
  });

  @override
  State<_DocumentFormDialog> createState() => _DocumentFormDialogState();
}

class _DocumentFormDialogState extends State<_DocumentFormDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _enteController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _dateController = TextEditingController(
      text: widget.initialDate != null && widget.initialDate!.isNotEmpty
          ? _formatDateForField(widget.initialDate!)
          : '',
    );
    _enteController = TextEditingController(text: widget.initialEnte ?? '');
  }

  String _formatDateForField(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    _enteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDescription != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifica documento' : 'Nuovo documento'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data documento (YYYY-MM-DD)',
                hintText: '2026-07-08',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _enteController,
              decoration: const InputDecoration(labelText: 'Ente'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'description': _descriptionController.text.trim(),
                'documentDate': _dateController.text.trim(),
                'ente': _enteController.text.trim(),
              });
            }
          },
          child: Text(isEditing ? 'Salva' : 'Carica'),
        ),
      ],
    );
  }
}
