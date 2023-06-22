import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class HistoryStorageWeb {
  /*
  json : {
    "exits": int,
    "storages": [
      {"name": string, "index": int, "seektime": int},
    ],
  }
   */
  static Map<String, dynamic> storages = {
    "storages": [],
  };
  static bool reFreshed = false;

  static Future<void> initStorage() async {
    //print("init Here History");
    String urlpath =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/newHistory";
    try {
      var res = await Dio().get(urlpath);
      var response = jsonDecode(res.data.toString());
      storages["storages"] = List.from(response["infos"]);
    } catch (e) {
      //storages["count"] = 0;
      storages["storages"] = [];
    }
  }

  static Future<void> clearStorage() async {
    String cleardata =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/clearHistory";
    try {
      var res = await Dio().get(cleardata);
      if (res.statusCode == 200) {
        reFreshed = true;
      }
    } catch (e) {
      //
    }
  }

  static Future<int> insertStorage(String videoname, int index, int seektime,
      String station, String urlpath, String imgpath) async {
    String insertdata =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/insertHistory";
    Map<String, dynamic> tempdata = {
      "name": videoname,
      "index": index,
      "seektime": seektime,
      "station": station,
      "urlpath": urlpath,
      "img": imgpath,
    };
    try {
      var response = await Dio().post(insertdata, data: tempdata);
      if (response.statusCode == 200) {
        //storages["count"] += 1;
        return 0;
      }
    } catch (e) {
      return 1;
    }
    return 0;
  }

  static Future<void> clearTarget(String videoname, int index, int seektime,
      String station, String urlpath, String imgpath) async {
    String deletedata =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/delectHistory";
    Map<String, dynamic> tempdata = {
      "name": videoname,
      "index": index,
      "seektime": seektime,
      "station": station,
      "urlpath": urlpath,
      "img": imgpath,
    };
    try {
      var response = await Dio().post(deletedata, data: tempdata);
      if (response.statusCode == 200) {
        reFreshed = true;
      }
    } catch (e) {
      //
    }
  }
}

class HistoryStorageDB {
  static String dbName = "history.db";
  static Database? database;
  static Map<String, dynamic> storages = {
    "storages": [],
  };

  static Future<void> openDB() async {
    var dataPath = await getDatabasesPath();
    String pathDb = p.join(dataPath, dbName);
    database = await openDatabase(
      pathDb,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE History (name TEXT PRIMARY KEY, vindex INTEGER, seektime INTEGER, station TEXT, urlpath TEXT, img TEXT)');
      },
      onOpen: (db) {
        database = db;
      },
    );
  }

  static Future<void> initStorage() async {
    var result = await database!.rawQuery("SELECT * FROM History");
    storages["storages"] = result;
  }

  static Future<void> clearStorage() async {
    await database!.delete("History");
    storages["storages"] = [];
  }

  static Future<void> insertStorage(String videoname, int index, int seektime,
      String station, String urlpath, String imgpath) async {
    await database!
        .delete("History", where: "name = ?", whereArgs: [videoname]);
    await database!.insert("History", {
      "name": videoname,
      "vindex": index,
      "seektime": seektime,
      "station": station,
      "urlpath": urlpath,
      "img": imgpath
    });
  }

  static Future<void> clearTarget(String videoname, int index, int seektime,
      String station, String urlpath, String imgpath) async {
    await database!
        .delete("History", where: "name = ?", whereArgs: [videoname]);
  }
}
