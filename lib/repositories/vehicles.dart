import 'package:flutter_request_bloc/flutter_request_bloc.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../services/index.dart';
import 'package:sembast/sembast.dart';

/// Handles retrieve and transformation of [Vehicles] from the API.
/// This includes:
/// - Elon's Tesla Roadster car.
/// - Dragon capsules information.
/// - Rocket vehicles information.
/// - Various active ships information.
class VehiclesRepository
    extends BaseRepository<VehiclesService, List<Vehicle>> {
  Database db;
  VehiclesRepository(VehiclesService service, Database this.db)
      : super(service);

  @override
  Future<List<Vehicle>> fetchData() {
    return fetchingData({});
  }

  Future<List<Vehicle>> fetchingData(data) async {
    var store = StoreRef<String, String>.main();

    var roadsterDB = await store.record('roadster').get(db);
    var dragonDB = await store.record('dragon').get(db);
    var rocketDB = await store.record('rocket').get(db);
    var shipDB = await store.record('ship').get(db);
    var expired = await store.record('expire_vehicles').get(db);

    if (expired != null) {
      final stored = DateTime.fromMillisecondsSinceEpoch(int.parse(expired));
      if (stored.isBefore(DateTime.now())) {
        roadsterDB = null;
        dragonDB = null;
        rocketDB = null;
        shipDB = null;
      }
    }

    var storedRoadster;
    List storedDragon;
    List storedRocket;
    List storedShip;

    if (roadsterDB != null) {
      storedRoadster = jsonDecode(roadsterDB);
    } else {
      final roadsterResponse = await service.getRoadster();
      storedRoadster = roadsterResponse.data;

      await store.record('roadster').put(db, jsonEncode(storedRoadster));

      await store.record('expire_vehicles').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    if (dragonDB != null) {
      storedDragon = jsonDecode(dragonDB);
    } else {
      final dragonResponse = await service.getDragons();
      storedDragon = dragonResponse.data['docs'];
      print(storedDragon);
      await store.record('dragon').put(db, jsonEncode(storedDragon));
      await store.record('expire_vehicles').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    if (rocketDB != null) {
      storedRocket = jsonDecode(rocketDB);
    } else {
      final rocketResponse = await service.getRockets();
      storedRocket = rocketResponse.data['docs'];

      await store.record('rocket').put(db, jsonEncode(storedRocket));
      await store.record('expire_vehicles').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    if (shipDB != null) {
      storedShip = jsonDecode(shipDB);
    } else {
      final shipResponse = await service.getShips();
      storedShip = shipResponse.data['docs'];
      await store.record('ship').put(db, jsonEncode(storedShip));
      await store.record('expire_vehicles').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    return [
      RoadsterVehicle.fromJson(storedRoadster),
      for (final item in storedDragon) DragonVehicle.fromJson(item),
      for (final item in storedRocket) RocketVehicle.fromJson(item),
      for (final item in storedShip) ShipVehicle.fromJson(item),
    ];
  }
}
