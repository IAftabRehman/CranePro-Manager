import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_controller.dart';

final activityLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getCombinedActivityStream();
});
