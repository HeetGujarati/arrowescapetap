// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_escape/data/level_binary_codec.dart';
import 'package:arrow_escape/data/models/level.dart';

void main() {
  test('Build levels.bin from cached progress', () {
    print('');
    print('=====================================================');
    print(' Arrow Escape — Build levels.bin');
    print('=====================================================');
    print('');

    const totalLevels = 500;
    const outputFile = 'assets/levels.bin';

    // 1. Load base levels from level_chunks (all 500 levels)
    final rawLevels = <int, LevelModel>{};
    for (int chunk = 1; chunk <= 5; chunk++) {
      final chunkFile = 'assets/level_chunks/chunk_$chunk.json';
      final chunkF = File(chunkFile);
      if (chunkF.existsSync()) {
        try {
          final data = jsonDecode(chunkF.readAsStringSync()) as Map<String, dynamic>;
          for (final entry in data.entries) {
            final lvl = LevelModel.fromJson(entry.value as Map<String, dynamic>);
            rawLevels[lvl.levelNumber] = lvl;
          }
        } catch (e) {
          print('WARNING: Failed to parse $chunkFile: $e');
        }
      }
    }

    // Overlay verified progress chunks where status is 'pass'
    for (int chunk = 1; chunk <= 5; chunk++) {
      final progressFile = 'assets/verify_progress_chunk_$chunk.json';
      final progressF = File(progressFile);
      if (progressF.existsSync()) {
        try {
          final data = jsonDecode(progressF.readAsStringSync()) as Map<String, dynamic>;
          for (final entry in data.entries) {
            final val = entry.value as Map<String, dynamic>;
            if (val['status'] == 'pass' && val['level'] != null) {
              final lvl = LevelModel.fromJson(val['level'] as Map<String, dynamic>);
              rawLevels[lvl.levelNumber] = lvl;
            }
          }
        } catch (e) {
          print('WARNING: Failed to parse $progressFile: $e');
        }
      }
    }

    // 2. Check all 500 levels are loaded
    final missing = <int>[];
    for (int lvl = 1; lvl <= totalLevels; lvl++) {
      if (!rawLevels.containsKey(lvl)) {
        missing.add(lvl);
      }
    }

    if (missing.isNotEmpty) {
      print('Cannot build levels.bin — missing levels: ${missing.take(20).join(", ")}');
      fail('Missing ${missing.length} levels.');
    }

    // 3. Collect and sort all 500 levels
    print('Reading $totalLevels levels...');
    final levels = <LevelModel>[];
    final sw = Stopwatch()..start();

    for (int lvl = 1; lvl <= totalLevels; lvl++) {
      levels.add(rawLevels[lvl]!);
      if (lvl % 100 == 0) {
        print('  Loaded $lvl / $totalLevels levels');
      }
    }

    sw.stop();
    print('Loaded in ${sw.elapsedMilliseconds}ms');
    print('');

    // 4. Sort (should already be in order, but be safe).
    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));

    // 5. Encode to binary.
    print('Encoding to binary...');
    final encodeSw = Stopwatch()..start();
    final bytes = encodeLevels(levels);
    encodeSw.stop();

    // 6. Write.
    Directory('assets').createSync(recursive: true);
    File(outputFile).writeAsBytesSync(bytes);

    final kb = (bytes.length / 1024).toStringAsFixed(1);
    print('Written: $outputFile ($kb KB, ${bytes.length} bytes)');
    print('Encoding: ${encodeSw.elapsedMilliseconds}ms');
    print('');
    print('Done! assets/levels.bin is ready for the app.');
    print('');
  });
}
