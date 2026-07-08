import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';
import 'package:orsocook/services/webdocuments/webdocuments_service.dart';

class WebDocumentsList extends StatefulWidget {
  const WebDocumentsList({super.key});

  @override
  State<WebDocumentsList> createState() => _WebDocumentsListState();
}

class _WebDocumentsListState extends State<WebDocumentsList> {
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
    await launchUrl(uri, webOnlyWindowName: '_blank');
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
        title: const Text('WebDocuments'),
        centerTitle: true,
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
                  ? const Center(
                      child: Text(
                        'Nessun documento',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
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
                              'Nome file: ${doc['fileName'] ?? ''}',
                              style: const TextStyle(
                                  color: Colors.amber, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descrizione: ${doc['description'] ?? ''}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Ente: ${doc['ente'] ?? ''} - ${_formatDate(doc['documentDate'] ?? '')}',
                                  style: const TextStyle(color: Colors.white54),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
