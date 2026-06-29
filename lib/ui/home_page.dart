import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
        centerTitle: true,
      ),
      body: SafeArea(child: const _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final image = controller.selectedImage;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showPickerSheet(context),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                child: image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 100,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to pick image',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )
                    : Image.file(image, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Analyze'),
            onPressed: image == null ? null : () => controller.goToResult(context),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.crop),
            label: const Text('Crop & Analyze'),
            onPressed: image == null ? null : () => controller.cropAndAnalyze(context),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.videocam),
            label: const Text('Camera Feed'),
            onPressed: () => controller.goToCamera(context),
          ),
        ],
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    final controller = context.read<HomeController>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                controller.pickFromCamera(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
