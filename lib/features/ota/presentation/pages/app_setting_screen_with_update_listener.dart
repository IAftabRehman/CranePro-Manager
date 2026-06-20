import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extend_crane_services/shared/global_widgets/premium_background.dart';
import '../controllers/update_notifier.dart';
import '../widgets/update_dialog_widget.dart';

class AppSettingScreenWithUpdateListener extends ConsumerWidget {
  const AppSettingScreenWithUpdateListener({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(updateProvider.select((s) => s.isLoading));
    final errorMessage = ref.watch(updateProvider.select((s) => s.errorMessage));

    // Listen to changes in the OTA update state to show dialog
    ref.listen(updateProvider, (previous, next) {
      if (next.hasUpdate && !(previous?.hasUpdate ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: !next.isForceUpdate,
          builder: (context) => const UpdateDialogWidget(),
        );
      }
    });

    return PremiumScaffold(
      appBar: AppBar(
        title: const Text(
          'App Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                color: const Color(0x0DFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: const ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: Colors.amberAccent),
                  title: Text(
                    'Version Info',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Check for new updates or check current version details.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading
                  ? null
                  : () {
                      ref.read(updateProvider.notifier).checkForUpdates();
                    },
                icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
                label: Text(
                  isLoading ? 'CHECKING...' : 'CHECK FOR UPDATES',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
