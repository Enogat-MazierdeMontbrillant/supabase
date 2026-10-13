import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

/// Affiche un fichier PDF et permet de le partager (WhatsApp, mail...).
class PDFScreen extends StatefulWidget {
  final String path;
  const PDFScreen({super.key, required this.path});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  PDFViewController? _controller;
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Logger logger = Logger();

  Future<void> _sharePdf() async {
    final file = File(widget.path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le fichier PDF est introuvable.')),
        );
      }
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: [XFile(widget.path)], text: 'SCAN PDF'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (total) {
              if (!mounted) return;
              setState(() {
                pages = total ?? 0;
                isReady = true;
              });
            },
            onError: (error) {
              if (mounted) setState(() => errorMessage = error.toString());
              logger.e(error.toString());
            },
            onPageError: (page, error) {
              if (mounted) {
                setState(() => errorMessage = '$page: ${error.toString()}');
              }
              logger.e('$page: ${error.toString()}');
            },
            onViewCreated: (controller) => _controller = controller,
            onPageChanged: (page, total) {
              if (mounted) setState(() => currentPage = page ?? 0);
            },
          ),
          if (errorMessage.isNotEmpty)
            Center(child: Text(errorMessage))
          else if (!isReady)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: _controller == null || pages == 0
          ? null
          : FloatingActionButton.extended(
              label: Text('Page ${currentPage + 1}/$pages'),
              onPressed: () => _controller!.setPage(pages ~/ 2),
            ),
    );
  }
}
