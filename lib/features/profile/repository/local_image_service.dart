import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Saves profile pictures to the app's local documents directory.
///
/// IMPORTANT: each save uses a NEW, uniquely-timestamped filename rather
/// than overwriting a fixed path (e.g. "$userId.jpg"). This is what fixes
/// the "photo doesn't update until app restart" bug — Flutter's FileImage
/// caches decoded image bytes by file PATH. Reusing the same path meant
/// Flutter kept showing its cached (stale) copy even after the file's
/// content changed on disk. A new path every time guarantees a cache miss,
/// so the new image always displays immediately.
///
/// Old profile pictures for the same user are deleted after a successful
/// save, so we don't silently accumulate old image files forever.
class LocalImageService {
  Future<String> saveProfilePicture(String userId, File pickedImage) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_pictures');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    // Unique path — this is the key fix for the caching bug.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFile = File('${profileDir.path}/$userId-$timestamp.jpg');
    await pickedImage.copy(newFile.path);

    // Clean up this user's previous profile picture files so storage
    // doesn't grow unbounded. Errors here are non-fatal — worst case,
    // one old file lingers, which doesn't affect correctness.
    try {
      final oldFiles = profileDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('/$userId-') && f.path != newFile.path);
      for (final old in oldFiles) {
        await old.delete();
      }
    } catch (_) {
      // Non-fatal cleanup failure — safe to ignore.
    }

    return newFile.path;
  }
}