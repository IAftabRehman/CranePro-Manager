class AppVersionModel {
  final String latestVersion;
  final bool forceUpdate;
  final String apkDownloadUrl;

  AppVersionModel({
    required this.latestVersion,
    required this.forceUpdate,
    required this.apkDownloadUrl,
  });

  factory AppVersionModel.fromMap(Map<String, dynamic> map) {
    return AppVersionModel(
      latestVersion: map['latest_version'] ?? '1.0.0',
      forceUpdate: map['force_update'] ?? false,
      apkDownloadUrl: map['apk_download_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latest_version': latestVersion,
      'force_update': forceUpdate,
      'apk_download_url': apkDownloadUrl,
    };
  }
}
