import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/update_notifier.dart';

class UpdateDialogWidget extends ConsumerWidget {
  const UpdateDialogWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    final isForceUpdate = state.isForceUpdate;
    final isDownloading = state.isDownloading;
    final progress = state.downloadProgress;
    final percent = (progress * 100).toStringAsFixed(0);

    return PopScope(
      canPop: !isForceUpdate && !isDownloading,
      child: AlertDialog(
        backgroundColor: const Color(0xFF0F1A2E), // Premium deep navy
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.amberAccent, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.system_update_rounded,
              color: Colors.amberAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isForceUpdate ? 'CRITICAL UPDATE' : 'UPDATE AVAILABLE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isForceUpdate
                  ? 'A critical update is required to continue using CranePro Manager. Please install the latest version.'
                  : 'A new version of CranePro Manager is available. Install it now to access the latest features and bug fixes.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (isDownloading) ...[
              const Text(
                'Downloading update...',
                style: TextStyle(color: Colors.amberAccent, fontSize: 13),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else if (state.errorMessage != null) ...[
              Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
              const SizedBox(height: 8),
            ] else ...[
              const Text(
                'The installation package will download and prompt automatic installation on your device.',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          if (!isForceUpdate && !isDownloading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'REMIND LATER',
                style: TextStyle(
                  color: Colors.white30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (!isDownloading)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 4,
              ),
              onPressed: () {
                ref.read(updateProvider.notifier).startDownloadAndInstall();
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text(
                'UPDATE NOW',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
