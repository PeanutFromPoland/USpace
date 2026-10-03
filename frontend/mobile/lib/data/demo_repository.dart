import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models.dart';

abstract class DemoStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SecureDemoStore implements DemoStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _key = 'uspace.demo.v1';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class DemoSnapshot {
  const DemoSnapshot({this.profile = const DemoProfile()});
  final DemoProfile profile;
  String encode() =>
      jsonEncode({'schemaVersion': 1, 'profile': profile.toJson()});
  factory DemoSnapshot.decode(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported schema');
    }
    return DemoSnapshot(
      profile: DemoProfile.fromJson(
        Map<String, dynamic>.from(json['profile'] as Map),
      ),
    );
  }
}

class DemoRepository {
  DemoRepository(this.store);
  final DemoStore store;
  Future<DemoSnapshot> load() async {
    final value = await store.read();
    return value == null ? const DemoSnapshot() : DemoSnapshot.decode(value);
  }

  Future<void> save(DemoSnapshot state) => store.write(state.encode());
  Future<void> clear() => store.clear();
}
