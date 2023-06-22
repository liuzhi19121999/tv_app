import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

//SecrectCodeClass secrectCodeClass = SecrectCodeClass();

class SecrectCodeClass {
  static List<String> secretCodes = [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    '频',
    'p',
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
    '0',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    'Q',
    'A',
    'Z',
    'W',
    'S',
    'X',
    'E',
    'D',
    'C',
    'R',
    'F',
    'V',
    '央',
    'T',
    'G',
    'B',
    'Y',
    'H',
    'N',
    'U',
    'J',
    'M',
    'I',
    'K',
    'O',
    'L',
    'P',
    '3',
    '2',
    '1',
    '集',
    '的',
    '一',
    '在',
    '国',
    '年',
    '和',
    '道',
    '业',
    '法',
    '发',
    '为',
    '产',
    '会',
    '工',
    '经',
    '地',
    '市',
    '家',
    '以',
    '成',
    '到',
    '地',
    '民',
    '我',
    '对',
    '部',
    '近',
    '中',
    '多',
    '进',
    '他',
    '们',
    '公',
    '开',
    '场',
    '第'
  ];

  static String checkCodes = "5543jkldr980";

  static const String checkKey = "check";
  static const String secCodeKey = "security";

  static Future<void> initCodesFunc() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var codesTemp = sharedPreferences.getString(checkKey);
    if (codesTemp != null) {
      checkCodes = codesTemp;
    }
    var codesListTemp = sharedPreferences.getStringList(secCodeKey);
    if (codesListTemp != null) {
      secretCodes = codesListTemp;
    }
  }

  static Future<void> checkCodesFunc() async {
    String checksUrl =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/checkCodes";
    String fetchUrl =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/fetchCodes";
    try {
      var resp = await Dio(BaseOptions(connectTimeout: 5000)).get(checksUrl,
          queryParameters: {"tokens": HostPortStorage.tokensText});
      if (resp.statusCode == 200) {
        var jsonData = resp.data.toString();
        if (jsonData != checkCodes) {
          var response = await Dio(BaseOptions(connectTimeout: 5000)).get(
              fetchUrl,
              queryParameters: {"tokens": HostPortStorage.tokensText});
          if (response.statusCode == 200) {
            var jsonDataNew = jsonDecode(response.data.toString());
            secretCodes = List.from(jsonDataNew["listcodes"]);
            SecrectCodeClass.checkCodes = jsonData;
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            await sharedPreferences.setString(checkKey, checkCodes);
            await sharedPreferences.setStringList(secCodeKey, secretCodes);
          }
        }
      }
    } catch (e) {
      //
    }
  }

  static String decodeEnigmaString(String inputText) {
    // 5 转子加密机
    int totalLength = secretCodes.length;
    List<String> temp = inputText.split("");
    List<int> codesCount = List.from(HostPortStorage.enigmaCode);
    String result = "";
    for (var i = 0; i < temp.length; i += 5) {
      // 解密过程
      // 1~5转子
      for (var j = 0; j < 5; j++) {
        if (i + j >= temp.length) break;
        int tempIndex = secretCodes.indexOf(temp[i + j]);
        if (tempIndex == -1) {
          result += temp[i + j];
        } else {
          tempIndex -= codesCount[j];
          while (tempIndex < 0) {
            tempIndex += totalLength;
          }
          result += secretCodes[tempIndex];
        }
        //result += decodeChar(temp[i + j], codesCount[j], totalLength);
        codesCount[j] = codesCount[j] + 1;
        while (codesCount[j] > totalLength) {
          codesCount[j] = codesCount[j] - totalLength;
        }
      }
      /*
      for (var j = 0; j < 5; j++) {
        codesCount[j] = codesCount[j] + 1;
        while (codesCount[j] >= totalLength) {
          codesCount[j] = codesCount[j] - totalLength;
        }
      }
      */
    }
    return result;
  }

  static String decodeChar(String chars, int codes, int totalLength) {
    int indexSec = secretCodes.indexOf(chars);
    if (indexSec == -1) {
      return chars;
    }
    indexSec -= codes;
    while (indexSec < 0) {
      indexSec += totalLength;
    }
    return secretCodes[indexSec];
  }
}
