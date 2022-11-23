import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_request_bloc/flutter_request_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../models/index.dart';
import '../services/index.dart';

/// Handles retrieve and transformation of [Launch] from the API, both past & future ones.
class LaunchesRepository
    extends BaseRepository<LaunchesService, List<List<Launch>>> {
  Database db;
  LaunchesRepository(LaunchesService service, Database this.db)
      : super(service);

  @override
  Future<List<List<Launch>>> fetchData() {
    return fetchingData({});
  }

  Future<List<List<Launch>>> fetchingData(data) async {
    var store = StoreRef<String, String>.main();
    var launchesDB = await store.record('launches').get(db);
    var expired = await store.record('expire_launches').get(db);
    if (expired != null) {
      final stored = DateTime.fromMillisecondsSinceEpoch(int.parse(expired));
      if (stored.isBefore(DateTime.now())) {
        launchesDB = null;
      }
    }
    List storedLaunches;
    if (launchesDB != null) {
      storedLaunches = jsonDecode(launchesDB);
    } else {
      final response = await service.getLaunches();
      storedLaunches = response.data['docs'];
      await store.record('launches').put(db, jsonEncode(storedLaunches));
      await store.record('expire_launches').put(db, DateTime.now().add(Duration(seconds: 120)).millisecondsSinceEpoch.toString());
    }

    final launches = [
      for (final item in storedLaunches) Launch.fromJson(item)
    ]..sort();

    return [
      launches.where((l) => l.upcoming).toList(),
      launches.where((l) => !l.upcoming).toList().reversed.toList()
    ];
  }
}
