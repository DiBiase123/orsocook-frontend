import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/utils/logger.dart';

class EditImageSection extends StatefulWidget {
  final Uint8List? imageBytes;
  final XFile? selectedImageXFile;
  final String imageUrl;
  final Function(XFile?) onImageSelected;
  final Function() onImageRemoved;

  const EditImageSection({
    super.key,
    required this.imageBytes,
    required this.selectedImageXFile,
    required this.imageUrl,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  State<EditImageSection> createState() => _EditImageSectionState();
}

class _EditImageSectionState extends State<EditImageSection> {
  final ImagePicker _picker = ImagePicker();

  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return imageUrl.startsWith('/')
        ? '${Config.apiBaseUrl}$imageUrl'
        : '${Config.apiBaseUrl}/$imageUrl';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image != null) {
        widget.onImageSelected(image);
        AppLogger.debug('🖼️ Immagine selezionata: ${image.path}');
      }
    } catch (e) {
      AppLogger.error('Errore selezione immagine', e);
    }
  }

  Widget _buildImageWidget() {
    if (widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorIcon(),
      );
    }
    if (widget.selectedImageXFile != null) {
      return Image.file(
        File(widget.selectedImageXFile!.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorIcon(),
      );
    }
    if (widget.imageUrl.isNotEmpty) {
      return Image.network(
        _getFullImageUrl(widget.imageUrl),
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          return progress == null
              ? child
              : Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
        },
        errorBuilder: (_, __, ___) => _buildErrorIcon(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorIcon() {
    return const Center(
      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
    );
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceTile(Icons.photo_library, 'Scegli dalla Galleria',
                ImageSource.gallery),
            _buildSourceTile(
                Icons.camera_alt, 'Scatta una Foto', ImageSource.camera),
            _buildSourceTile(Icons.close, 'Annulla', null, isCancel: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTile(IconData icon, String label, ImageSource? source,
      {bool isCancel = false}) {
    return ListTile(
      leading: Icon(icon, color: isCancel ? Colors.red : null),
      title: Text(label,
          style: isCancel ? const TextStyle(color: Colors.red) : null),
      onTap: () {
        Navigator.pop(context);
        if (source != null) _pickImage(source);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.selectedImageXFile != null || widget.imageUrl.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Immagine della Ricetta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Modifica la foto della tua ricetta (opzionale)',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            hasImage ? _buildImagePreview() : _buildAddImageButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cambia Foto'),
              onPressed: _showImageSourceSelector,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Rimuovi', style: TextStyle(color: Colors.red)),
              onPressed: widget.onImageRemoved,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceSelector,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text('Aggiungi Foto',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Tocca per selezionare dalla galleria o scattare una foto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
