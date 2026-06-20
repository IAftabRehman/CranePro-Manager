class VersionInfoModel {
  final String latestVersion;
  final bool forceUpdate;
  final String apkDownloadUrl;

  VersionInfoModel({
    required this.latestVersion,
    required this.forceUpdate,
    required this.apkDownloadUrl,
  });

  factory VersionInfoModel.fromMap(Map<String, dynamic> map) {
    return VersionInfoModel(
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
