import 'dart:convert';

import 'package:flutter_request_bloc/flutter_request_bloc.dart';
import 'package:sembast/sembast.dart';

import '../models/index.dart';
import '../services/index.dart';

/// Handles retrieve and transformation of [Achievement] from the API.
class AchievementsRepository
    extends BaseRepository<AchievementsService, List<Achievement>> {
      Database db;
  AchievementsRepository(AchievementsService service, Database this.db) : super(service);

  @override
  Future<List<Achievement>> fetchData() async {

    var store = StoreRef<String, String>.main();
    print('Store: $store');
    var achievementsDB = await store.record('achievements').get(db);
    print('AchievementsDB: $achievementsDB');
    var expired = await store.record('expire_achievements').get(db);
    print('Expired: $expired');
    if (expired != null) {
      final stored = DateTime.fromMillisecondsSinceEpoch(int.parse(expired));
      if (stored.isBefore(DateTime.now())) {
        achievementsDB = null;
      }
    }
    List storedAchievements;
    if (achievementsDB != null) {
      storedAchievements = jsonDecode(achievementsDB);
    } else {
      final response = await service.getAchievements();
      storedAchievements = response.data;
      print('StoredAchievements: $storedAchievements');
      await store.record('achievements').put(db, jsonEncode(storedAchievements));
      await store.record('expire_achievements').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    return [for (final item in storedAchievements) Achievement.fromJson(item)];
  }
}
