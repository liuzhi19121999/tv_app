import 'dart:convert';
import "package:dio/dio.dart";
import 'package:tv_old_ver/datastore/secrectcode.dart';
import "../datastore/dataserver.dart";

class FetchNewVideoInfo {
  static List<Map> newVideoStorage = [];
  static int totalfiles = 0;

  static fetchNewVideoInfo() async {
    String fetchurl =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/infos";
    try {
      //print(fetchurl);
      var jsonFile =
          await Dio(BaseOptions(connectTimeout: 20000)).get(fetchurl);
      var resDate = jsonDecode(jsonFile.toString());
      totalfiles = resDate["total"];
      newVideoStorage = List.from(resDate["videos"]);
    } catch (e) {
      //print(e.toString());
    }
  }
}

class SearchVideoInfo {
  static Map<String, dynamic> responseData = {};
  static bool searchable = false;
  static Future<void> searchResult(String videoName) async {
    String searchPath =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/search";
    try {
      var response = await Dio(BaseOptions(
              connectTimeout: 29000, sendTimeout: 9000, receiveTimeout: 20000))
          .get(searchPath, queryParameters: {
        "name": videoName,
        "wd": "submit",
        "tokens": HostPortStorage.tokensText
      });
      if (response.statusCode == 200) {
        var respString = response.data.toString();
        if (HostPortStorage.useEnigma) {
          await SecrectCodeClass.checkCodesFunc();
          respString =
              SecrectCodeClass.decodeEnigmaString(response.data.toString());
        }
        var jsonData = jsonDecode(respString);
        responseData = Map.from(jsonData);
        //print(videoName + "  " + response.data.toString());
        //print(List.from(responseData["liangzi"]["infos"]));
        searchable = true;
      } else {
        searchable = false;
      }
    } catch (e) {
      searchable = false;
    }
  }
}

class SearchTansform {
  List<Map> videosInfo = [];
  String videoPic = "";
  String description = "";
  String videoTitle = "";
  String videoYear = "";
  String actors = "";

  String serverUrl =
      "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/videolink";

  Future<void> getVideoInfo(String path, String station) async {
    //print("init Search");
    try {
      var response = await Dio(BaseOptions(connectTimeout: 20000))
          .get(serverUrl, queryParameters: {
        "path": path,
        "station": station,
        "tokens": HostPortStorage.tokensText
      });
      if (response.statusCode == 200) {
        var respString = response.data.toString();
        if (HostPortStorage.useEnigma) {
          await SecrectCodeClass.checkCodesFunc();
          respString =
              SecrectCodeClass.decodeEnigmaString(response.data.toString());
        }
        var jsonData = jsonDecode(respString);
        //print(jsonData);
        videoTitle = jsonData["title"];
        actors = jsonData["actors"];
        videoYear = jsonData["year"];
        videoPic = jsonData["imgpath"];
        description = jsonData["content"];
        videosInfo = List.from(jsonData["items"]);
      }
    } catch (e) {
      // print(e.toString());
    }
  }
}

class NewVideoFetch {
  List videosRecom = [];

  Future<void> getVideoRecomInfos(int index) async {
    try {
      String urlPath =
          "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/recomVideo";
      String param = "";
      if (index == 0) {
        param = "movie";
      }
      if (index == 1) {
        param = "tv";
      }
      var resp = await Dio(BaseOptions(connectTimeout: 20000))
          .get(urlPath, queryParameters: {"index": param});
      if (resp.statusCode == 200) {
        var jsonData = jsonDecode(resp.data.toString());
        videosRecom = List.from(jsonData["total"]);
      } else {
        videosRecom = [];
      }
    } catch (e) {
      //
    }
  }
}
