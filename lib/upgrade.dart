import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OTAUpdate {
  static String newVersion = "";
  static bool updating = false;
  static List<String> updataContent = [];
  static String newApkUrl = "";
  static bool ignored = false;
  static String tempVersion = "";
  static String appName = "";

  static checkVersion() async {
    // 获取json文件
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      tempVersion = packageInfo.version;
      appName = packageInfo.appName;
      if (!ignored) {
        var jsonFile = await Dio(BaseOptions(connectTimeout: 5000)).get(
            "${HostPortStorage.hostportcol}://${HostPortStorage.hostname}:${HostPortStorage.hostport}/update");
        //print(fetchurl);
        var resDate = jsonDecode(jsonFile.toString());
        if (resDate["Version"] != tempVersion) {
          updating = true;
          newVersion = resDate["Version"];
          newApkUrl = resDate["apkurl"];
          updataContent = List.from(resDate["content"]);
        }
      }
    } catch (e) {
      //print(e.toString());
    }
  }
}

typedef IgnoreFunc = dynamic Function();

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key, required this.ignoreFunc}) : super(key: key);
  final IgnoreFunc? ignoreFunc;
  @override
  State<UpdatePage> createState() => _UpdatePage();
}

class _UpdatePage extends State<UpdatePage> {
  String downoaderState = "开始更新";
  bool downloaded = false;
  FocusNode updateFocus = FocusNode();

  Future<void> tryUpdate() async {
    try {
      OtaUpdate()
          .execute(OTAUpdate.newApkUrl, destinationFilename: "temp.apk")
          .listen((event) {
        switch (event.status) {
          case OtaStatus.DOWNLOADING:
            downoaderState = "下载中: ${event.value}%";
            setState(() {});
            break;
          case OtaStatus.INSTALLING:
            downoaderState = "正在安装";
            setState(() {});
            break;
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
            downoaderState = "更新错误，请稍后重试";
            setState(() {});
            break;
          default:
            break;
        }
      });
      OTAUpdate.updating = false;
    } catch (e) {
      downoaderState = "错误: ${e.toString()}";
      setState(() {});
    }
  }

  List<Widget> updateContent() {
    List<Widget> widgets = [];
    widgets.addAll([
      Text(
        "新版本: ${OTAUpdate.newVersion}",
        style: const TextStyle(fontSize: 25),
      ),
      const Text(
        "更新说明:",
        style: TextStyle(fontSize: 25),
      ),
    ]);
    for (var i = 0; i < OTAUpdate.updataContent.length; i++) {
      widgets.add(Text(
        OTAUpdate.updataContent[i],
        style: const TextStyle(fontSize: 24),
      ));
    }

    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Spacer(),
        Expanded(
            flex: 4,
            child: MaterialButton(
              focusNode: updateFocus,
              onPressed: () {
                tryUpdate();
                setState(() {
                  downloaded = true;
                });
              },
              focusColor: Colors.blue,
              color: Colors.grey,
              autofocus: true,
              child: const Text(
                "立刻更新",
                style: TextStyle(fontSize: 25),
              ),
            )),
        const Spacer(),
        Expanded(
            flex: 4,
            child: MaterialButton(
              onPressed: widget.ignoreFunc,
              focusColor: Colors.blue,
              color: Colors.grey,
              autofocus: true,
              child: const Text(
                "暂不更新",
                style: TextStyle(fontSize: 25),
              ),
            )),
        const Spacer()
      ],
    ));
    return widgets;
  }

  List<Widget> updatingContent() {
    List<Widget> lists = [];
    lists.add(Text(
      "  ",
      style: TextStyle(fontSize: MediaQuery.of(context).size.height / 10),
    ));
    lists.add(const Center(
      child: CircularProgressIndicator(),
    ));
    lists.add(Text(
      "  ",
      style: TextStyle(fontSize: MediaQuery.of(context).size.height / 15),
    ));
    lists.add(Center(
      child: Text(
        downoaderState,
        style: const TextStyle(fontSize: 25),
      ),
    ));
    return lists;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: MediaQuery.of(context).size.width * 0.7,
      heightFactor: MediaQuery.of(context).size.height * 0.8,
      child: ListView(
        children: downloaded ? updatingContent() : updateContent(),
      ),
    );
  }
}
