import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter/material.dart';

class HostPortStorage {
  static const String portcol = "Portcol";
  static const String hostip = "Host";
  static const String port = "Port";
  static const String tokenKey = "tokenKey";
  static const String enigmaKey = "enigma";
  static const String enigmaCodeKey = "enigmaCode";
  static const String useTouchKey = "touch";
  static String hostportcol = "http";
  static String hostname = "192.168.1.10";
  static String hostport = "7215";
  static String tokensText = "";
  static bool useEnigma = false;
  static List<int> enigmaCode = [];
  static bool useTouch = false;
  static Color themeColor = Colors.lightBlue;

  static Future<void> initSPonLoad() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var temp0 = sharedPreferences.getBool(useTouchKey);
    if (temp0 != null) {
      useTouch = temp0;
    }
    var temp = sharedPreferences.getString(tokenKey);
    if (temp != null) {
      tokensText = temp;
    }
    var temp1 = sharedPreferences.getString(portcol);
    if (temp1 != null) {
      hostportcol = temp1;
    }
    var temp2 = sharedPreferences.getString(hostip);
    if (temp2 != null) {
      hostname = temp2;
    }
    var temp3 = sharedPreferences.getString(port);
    if (temp3 != null) {
      hostport = temp3;
    }
    var useE = sharedPreferences.getBool(enigmaKey);
    if (useE != null) {
      useEnigma = useE;
    }
    var codeList = sharedPreferences.getStringList(enigmaCodeKey);
    if (codeList != null) {
      List<int> results = [];
      for (var i in codeList) {
        var ele = int.tryParse(i);
        if (ele == null) continue;
        results.add(ele);
      }
      if (results.length == 5) {
        enigmaCode = results;
      } else {
        useEnigma = false;
      }
    } else {
      useEnigma = false;
    }
  }

  static Future<void> setUseTouch(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(useTouchKey, value);
    useTouch = value;
  }

  static Future<void> setEnigmaCodeList(List<int> codes) async {
    List<String> codesList = [];
    for (var i in codes) {
      codesList.add(i.toString());
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList(enigmaCodeKey, codesList);
    enigmaCode = codes;
  }

  static Future<void> getEnigmaCodeList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var temp = sharedPreferences.getStringList(enigmaCodeKey);
    if (temp == null) {
      enigmaCode = [];
      useEnigma = false;
      return;
    }
    List<int> results = [];
    for (var i in temp) {
      var ele = int.tryParse(i);
      if (ele == null) {
        useEnigma = false;
        enigmaCode = [];
        return;
      }
      results.add(ele);
    }
    enigmaCode = results;
  }

  static Future<void> setUseEnigma(bool adjust) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(enigmaKey, adjust);
    useEnigma = true;
  }

  static Future<void> getUseEnigma() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var res = sharedPreferences.getBool(enigmaKey);
    if (res != null) {
      useEnigma = res;
    }
  }

  static Future<void> setTokens(String tokens) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(tokenKey, tokens);
    tokensText = tokens;
  }

  static Future<void> getTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tok = sharedPreferences.getString(tokenKey);
    if (tok != null) {
      tokensText = tok;
    }
  }

  static Future<void> setHostPort(
      String hostname0, String port0, String portcols) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(hostip, hostname0);
    await sharedPreferences.setString(port, port0);
    await sharedPreferences.setString(portcol, portcols);
  }

  static Future<void> getHostPort() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var host = sharedPreferences.getString(hostip);
    if (host != null) {
      hostname = host;
    }
    var ports = sharedPreferences.getString(port);
    if (ports != null) {
      hostport = ports;
    }
    var portcols = sharedPreferences.getString(portcol);
    if (portcols != null) {
      hostportcol = portcols;
    }
  }
}

class TVIndexStorage {
  static int index = 0;
  static Future<void> setTVIndex(int indexNew) async {
    index = indexNew;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt("index", indexNew);
  }

  static Future<void> getTVIndex() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var ind = sharedPreferences.getInt("index");
    if (ind != null) {
      index = ind;
    }
  }
}
