import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/update_notifier.dart';
import 'update_dialog_widget.dart';

class OtaUpdateGate extends ConsumerStatefulWidget {
  final Widget child;

  const OtaUpdateGate({super.key, required this.child});

  @override
  ConsumerState<OtaUpdateGate> createState() => _OtaUpdateGateState();
}

class _OtaUpdateGateState extends ConsumerState<OtaUpdateGate> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(updateProvider.notifier).checkForUpdates();
    });
  }

  void _showUpdateDialog(BuildContext context, bool isForceUpdate) {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (dialogCtx) {
        return const UpdateDialogWidget();
      },
    ).then((_) {
      _dialogShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the OTA update state
    ref.listen<UpdateState>(updateProvider, (previous, next) {
      if (next.hasUpdate && !(previous?.hasUpdate ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUpdateDialog(context, next.isForceUpdate);
        });
      }
    });

    return widget.child;
  }
}
