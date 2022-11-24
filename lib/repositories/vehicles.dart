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

  @override
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

    List storedRoadster;
    List storedDragon;
    List storedRocket;
    List storedShip;

    if (roadsterDB != null) {
      storedRoadster = jsonDecode(roadsterDB);
    } else {
      final roadsterResponse = await service.getRoadster();
      RoadsterVehicle.fromJson(roadsterResponse.data);
    }

    if (dragonDB != null) {
      storedDragon = jsonDecode(dragonDB);
    } else {
      final dragonResponse = await service.getDragons();
      for (final item in dragonResponse.data['docs'])
        DragonVehicle.fromJson(item);
    }

    if (rocketDB != null) {
      storedRocket = jsonDecode(rocketDB);
    } else {
      final rocketResponse = await service.getRockets();
      for (final item in rocketResponse.data['docs'])
        RocketVehicle.fromJson(item);
    }

    if (shipDB != null) {
      storedShip = jsonDecode(shipDB);
    } else {
      final shipResponse = await service.getShips();
      for (final item in shipResponse.data['docs']) ShipVehicle.fromJson(item);
    }

    return [storedRoadster, storedDragon, storedRocket, storedShip]
        .expand((x) => x)
        .toList();
  }
}
