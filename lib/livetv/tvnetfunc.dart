import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tv_old_ver/datastore/secrectcode.dart';
import '../datastore/dataserver.dart';

// 仿照主流电视直播应用进行设计
TVHomeStream tvHomeStream = TVHomeStream();

class TVHomeStream {
  List<dynamic> channelLabels = [];
  List<dynamic> channelReq = [];
  List<String> m3u8List = [];
  int requestID = 0;
  bool needRefresh = false;
  bool needShowLabel = true;
  int channelsID = 0;
  List<int> sliceIndex = [];
  List<String> catesList = [];

  Future<void> initTVPlayers() async {
    await getLabelsJson();
    await getStreamList(TVIndexStorage.index);
  }

  Future<void> getLabelsJson() async {
    String requestPath =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/tvlabel";
    try {
      var resp = await Dio(BaseOptions(connectTimeout: 10000)).get(requestPath,
          queryParameters: {"tokens": HostPortStorage.tokensText});
      if (resp.statusCode == 200) {
        var respString = resp.toString();
        if (HostPortStorage.useEnigma) {
          await SecrectCodeClass.checkCodesFunc();
          respString = SecrectCodeClass.decodeEnigmaString(resp.toString());
        }
        var jsonData = jsonDecode(respString);
        catesList = List.from(jsonData["cate"]);
        List<List<dynamic>> labelList = List.from(jsonData["labels"]);
        List<List<dynamic>> reqsList = List.from(jsonData["reqs"]);
        if (labelList.length != reqsList.length ||
            labelList.length != catesList.length) return;
        channelLabels = [];
        channelReq = [];
        sliceIndex = [];
        int countNum = -1;
        for (var i = 0; i < catesList.length; i++) {
          countNum += 1;
          sliceIndex.add(countNum);
          List<dynamic> labelTemp = labelList[i];
          List<dynamic> reqsTemp = reqsList[i];
          if (labelTemp.length != reqsTemp.length) continue;
          channelLabels += labelTemp;
          channelReq += reqsTemp;
          countNum += labelTemp.length - 1;
          sliceIndex.add(countNum);
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> getStreamList(int channelID) async {
    String postPath =
        "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/tvstream";
    if (catesList.isEmpty) {
      return;
    }
    try {
      if (requestID > 9000) {
        requestID = 0;
      }
      requestID += 1;
      var response = await Dio(BaseOptions(connectTimeout: 10000))
          .get(postPath, queryParameters: {
        "channel": channelReq[channelID],
        "id": requestID,
        "tokens": HostPortStorage.tokensText
      });
      if (response.statusCode == 200) {
        var respString = response.toString();
        if (HostPortStorage.useEnigma) {
          await SecrectCodeClass.checkCodesFunc();
          respString = SecrectCodeClass.decodeEnigmaString(response.toString());
        }
        var jsonData = jsonDecode(respString);
        if (jsonData["reqid"] == requestID) {
          tvStateClass.streamID = 0;
          m3u8List = List.from(jsonData["streams"]);
          needRefresh = true;
          channelsID = channelID;
        }
      }
    } catch (e) {
      //
    }
  }
}

TVStateClass tvStateClass = TVStateClass();

class TVStateClass extends ChangeNotifier {
  bool needRefreshState = false;
  bool showLabel = false;
  String labelString = "";
  int streamID = 0;
  int channelIndex = 0;

  void changeChannels(int index) async {
    streamID = 0;
    labelString = tvHomeStream.channelLabels[index];
    showLabel = true;
    if (hasListeners) {
      notifyListeners();
    }
    await tvHomeStream.getStreamList(index);
    needRefresh();
  }

  void needRefresh() {
    needRefreshState = true;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void hasRefreshed() {
    needRefreshState = false;
    if (hasListeners) {
      notifyListeners();
    }
  }
}
