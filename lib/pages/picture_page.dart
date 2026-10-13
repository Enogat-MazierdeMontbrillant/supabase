import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_screen.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key});
  static const route = '/picture';

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  File? image; // image choisie dans la galerie
  File? photo; // photo prise avec l'appareil
  String? pathFile; // chemin du dernier PDF généré
  final Logger logger = Logger();
  bool _busy = false;

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } catch (error) {
      logger.e('Opération média impossible.', error: error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opération impossible : $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Image depuis la galerie
  Future<void> pickGalerie() async {
    await _run(() async {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) setState(() => image = File(picked.path));
    });
  }

  /// Prise de photo
  Future<void> pickPhoto() async {
    await _run(() async {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null && mounted) setState(() => photo = File(picked.path));
    });
  }

  /// Scan -> conversion en PDF
  Future<void> startScan() async {
    await _run(() async {
      final output = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final path =
          '${output.path}/pdf-${now.day}-${now.month}-${now.year}-${now.hour}-${now.minute}-${now.second}.pdf';

      final pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted || pictures.isEmpty) return;

      final pdf = pw.Document();
      for (final picture in pictures) {
        final img = pw.MemoryImage(await File(picture).readAsBytes());
        pdf.addPage(pw.Page(
          build: (pw.Context context) =>
              pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
        ));
      }

      await File(path).writeAsBytes(await pdf.save());
      if (mounted) setState(() => pathFile = path);
      logger.i('PDF créé : $path');
    });
  }

  /// Passage de données entre écrans : le chemin du PDF est envoyé à PDFScreen
  void _openPDF(BuildContext context, String? fichier) {
    if (fichier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun PDF : lancez d'abord un scan.")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFScreen(path: fichier)),
    );
  }

  Widget buildPhoto(String path) {
    return Image.file(File(path),
        fit: BoxFit.cover, alignment: Alignment.center);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos et Galerie'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : pickGalerie,
                child: const Text('Image de la galerie'),
              ),
              if (image != null) buildPhoto(image!.path),
              ElevatedButton(
                onPressed: _busy ? null : pickPhoto,
                child: const Text('Image Photo'),
              ),
              if (photo != null) buildPhoto(photo!.path),
              ElevatedButton(
                onPressed: _busy ? null : startScan,
                child: const Text('SCANNER'),
              ),
              if (_busy) const CircularProgressIndicator(),
              ElevatedButton(
                onPressed: _busy || pathFile == null
                    ? null
                    : () => _openPDF(context, pathFile),
                child: const Text('Ouvrir le PDF'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
