# Android Native Configuration Guide for In-App OTA Update

This guide documents the native Android settings configured to support the private custom Over-The-Air (OTA) in-app update mechanism in **CranePro Manager**, completely bypassing the Google Play Store.

---

## 1. Required Permissions

To download the APK and initiate the installation, the following permissions are configured in [AndroidManifest.xml](file:///d:/flutter_Projects/extend_crane_services/android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

### Explanation:
* **`android.permission.INTERNET`**: Required to fetch the version metadata from Firestore and download the APK payload from the host server.
* **`android.permission.REQUEST_INSTALL_PACKAGES`**: Required starting with Android 8.0 (API level 26). Without this, the system will block the application from launching the package installer sheet.

---

## 2. Secure File Sharing via FileProvider

Starting with Android 7.0 (API level 24), Android enforces the `FileUriExposedException` when sharing a `file://` URI outside of the app's package boundary. To launch the system installer activity with our downloaded APK, we must share the file using a `content://` URI wrapper via the standard Android `FileProvider`.

### Step 2.1: Add Provider in `AndroidManifest.xml`
The `<provider>` entry is declared inside the `<application>` tag of `AndroidManifest.xml`:

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

* **`android:authorities`**: Dynamically uses `${applicationId}.fileprovider` to ensure uniqueness per build type/flavor (e.g., debug vs release).
* **`android:grantUriPermissions`**: Allows temporary read permissions to be assigned to the system PackageInstaller when executing the install intent.
* **`android:resource`**: Points to `@xml/file_paths` which details the physical storage locations permitted for sharing.

### Step 2.2: Define Storage Paths in `file_paths.xml`
The file paths configuration is located at [file_paths.xml](file:///d:/flutter_Projects/extend_crane_services/android/app/src/main/res/xml/file_paths.xml):

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="." />
    <cache-path name="cache_files" path="." />
    <files-path name="files" path="." />
</paths>
```

* **`<cache-path>`**: Permits sharing files from the internal cache directory (which corresponds to `getTemporaryDirectory()` in Flutter's `path_provider`). The APK is stored here and successfully passed to the installer.
* **`<files-path>`** and **`<external-path>`**: Configure other standard locations for flexibility if the download destination is changed to external/permanent folders in the future.
