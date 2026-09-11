import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  // Singleton pattern
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 1) : const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults(const {
        "boss_level_interval": 3,
        "god_level_interval": 5,
        "enable_admob": false,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig init error: $e');
    }
  }

  int get bossLevelInterval => _remoteConfig.getInt("boss_level_interval");
  int get godLevelInterval => _remoteConfig.getInt("god_level_interval");
  bool get enableAdMob => _remoteConfig.getBool("enable_admob");
}
