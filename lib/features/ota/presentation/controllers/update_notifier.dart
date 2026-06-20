import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../data/repositories/firebase_update_service.dart';

class UpdateState {
  final bool isLoading;
  final bool hasUpdate;
  final bool isForceUpdate;
  final String? downloadUrl;
  final String? errorMessage;
  final bool isDownloading;
  final double downloadProgress;
  final String? downloadedFilePath;

  UpdateState({
    this.isLoading = false,
    this.hasUpdate = false,
    this.isForceUpdate = false,
    this.downloadUrl,
    this.errorMessage,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.downloadedFilePath,
  });

  UpdateState copyWith({
    bool? isLoading,
    bool? hasUpdate,
    bool? isForceUpdate,
    String? downloadUrl,
    String? errorMessage,
    bool? isDownloading,
    double? downloadProgress,
    String? downloadedFilePath,
  }) {
    return UpdateState(
      isLoading: isLoading ?? this.isLoading,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      isForceUpdate: isForceUpdate ?? this.isForceUpdate,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
    );
  }
}

final firebaseUpdateServiceProvider = Provider((ref) => FirebaseUpdateService());

class UpdateNotifier extends Notifier<UpdateState> {
  late final FirebaseUpdateService _service;
  final CancelToken _cancelToken = CancelToken();

  @override
  UpdateState build() {
    _service = ref.watch(firebaseUpdateServiceProvider);
    return UpdateState();
  }

  Future<void> checkForUpdates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final remoteInfo = await _service.fetchVersionInfo();
      if (remoteInfo == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;

      final hasUpdate = _isNewerVersion(localVersion, remoteInfo.latestVersion);

      state = state.copyWith(
        isLoading: false,
        hasUpdate: hasUpdate,
        isForceUpdate: remoteInfo.forceUpdate,
        downloadUrl: remoteInfo.apkDownloadUrl,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete update check: $e',
      );
    }
  }

  Future<void> startDownloadAndInstall() async {
    final downloadUrl = state.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      state = state.copyWith(errorMessage: 'Download URL is empty.');
      return;
    }

    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      errorMessage: null,
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/app-release-update.apk";

      // Delete existing download file if any to prevent collision
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();
      await dio.download(
        downloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            state = state.copyWith(
              downloadProgress: received / total,
            );
          }
        },
      );

      state = state.copyWith(
        isDownloading: false,
        downloadedFilePath: filePath,
      );

      // Trigger automatic install prompt
      await installApk(filePath);
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: 'Download or install failed: $e',
      );
    }
  }

  Future<void> installApk(String filePath) async {
    try {
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to trigger installation: $e',
      );
    }
  }

  bool _isNewerVersion(String localVersion, String remoteVersion) {
    final localParts = localVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteParts = remoteVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = localParts.length > remoteParts.length ? localParts.length : remoteParts.length;

    for (int i = 0; i < maxLen; i++) {
      final localVal = i < localParts.length ? localParts[i] : 0;
      final remoteVal = i < remoteParts.length ? remoteParts[i] : 0;

      if (remoteVal > localVal) return true;
      if (localVal > remoteVal) return false;
    }
    return false;
  }
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(UpdateNotifier.new);
