import 'dart:convert';

import 'package:flutter_request_bloc/flutter_request_bloc.dart';
import 'package:sembast/sembast.dart';

import '../models/index.dart';
import '../services/index.dart';

/// Handles retrieve and transformation of [ComapnyInfo] from the API.
class CompanyRepository extends BaseRepository<CompanyService, CompanyInfo> {
  Database db;
  CompanyRepository(CompanyService service, Database this.db) : super(service);

  @override
  Future<CompanyInfo> fetchData() async {
    var store = StoreRef<String, String>.main();
    print('Store: $store');
    var companyDB = await store.record('company').get(db);
    print('CompanyDB: $companyDB');
    var expired = await store.record('expire_company').get(db);
    print('Expired: $expired');
    if (expired != null) {
      final stored = DateTime.fromMillisecondsSinceEpoch(int.parse(expired));
      if (stored.isBefore(DateTime.now())) {
        companyDB = null;
      }
    }
    Map<String, dynamic> storedCompany;
    if (companyDB != null) {
      storedCompany = jsonDecode(companyDB);
    } else {
      final response = await service.getCompanyInformation();
      storedCompany = response.data;
      print('StoredCompany: $storedCompany');
      await store.record('company').put(db, jsonEncode(storedCompany));
      await store.record('expire_company').put(
          db,
          DateTime.now()
              .add(Duration(seconds: 120))
              .millisecondsSinceEpoch
              .toString());
    }

    return CompanyInfo.fromJson(storedCompany);
  }
}
