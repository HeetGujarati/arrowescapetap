import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  // Singleton pattern
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;

  // Fallback defaults
  int _bossLevelInterval = 3;
  int _godLevelInterval = 5;
  bool _enableAdMob = true;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(hours: 1),
      ));

      await _remoteConfig!.setDefaults(const {
        "boss_level_interval": 3,
        "god_level_interval": 5,
        "enable_admob": true,
      });

      // Fetch and activate with a 3-second timeout so app launch is never delayed
      await _remoteConfig!.fetchAndActivate().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('RemoteConfig fetch timed out - using active defaults');
          return false;
        },
      );

      _bossLevelInterval = _remoteConfig!.getInt("boss_level_interval");
      _godLevelInterval = _remoteConfig!.getInt("god_level_interval");
      _enableAdMob = _remoteConfig!.getBool("enable_admob");
    } catch (e) {
      debugPrint('RemoteConfig init error: $e');
    }
  }

  int get bossLevelInterval => _bossLevelInterval;
  int get godLevelInterval => _godLevelInterval;
  bool get enableAdMob => _enableAdMob;
}
