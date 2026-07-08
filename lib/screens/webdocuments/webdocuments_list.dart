import 'package:flutter/material.dart';
import 'package:orsocook/services/webdocuments/webdocuments_service.dart';

class WebDocumentsList extends StatefulWidget {
  const WebDocumentsList({super.key});

  @override
  State<WebDocumentsList> createState() => _WebDocumentsListState();
}

class _WebDocumentsListState extends State<WebDocumentsList> {
  final WebDocumentsService _service = WebDocumentsService();
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.white.withAlpha(15),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          dataTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          columns: const [
                            DataColumn(label: Text('Descrizione')),
                            DataColumn(label: Text('Data')),
                            DataColumn(label: Text('Ente')),
                          ],
                          rows: _documents.map((doc) {
                            return DataRow(
                              onSelectChanged: (_) {
                                // TODO: apri documento
                              },
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      doc['description'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                    _formatDate(doc['documentDate'] ?? ''))),
                                DataCell(Text(doc['ente'] ?? '')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
    );
  }
}
