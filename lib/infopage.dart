import 'package:flutter/material.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:tv_old_ver/upgrade.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);
  @override
  State<InfoPage> createState() => _InfoPage();
}

class _InfoPage extends State<InfoPage> {
  Widget labelText(String label, String info) {
    return Row(
      children: [
        const Expanded(
            flex: 2,
            child: Text(
              "",
            )),
        Expanded(
            flex: 9,
            child: Text(label,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 40))),
        Expanded(
            flex: 1,
            child: Text(":",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 40))),
        Expanded(
            flex: 15,
            child: Text(info,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 40))),
        const Expanded(flex: 1, child: Text(""))
      ],
    );
  }

  Widget newVersion() {
    if (OTAUpdate.ignored) {
      return labelText("升级信息", "有新版本(${OTAUpdate.newVersion})");
    }
    return labelText("升级信息", "已是最新版本");
  }

  Widget useEnigmaCodes() {
    if (HostPortStorage.useEnigma) {
      return labelText(
          "是否启用Enigma加密", "启用(加密码：${HostPortStorage.enigmaCode.toString()})");
    } else {
      return labelText("是否启用Enigma加密", "不启用");
    }
  }

  Widget inviteCodes() {
    if (HostPortStorage.tokensText == "") {
      return labelText("邀请码", "无");
    } else {
      return labelText("邀请码", HostPortStorage.tokensText);
    }
  }

  Widget getBodyInfo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          Expanded(child: labelText("名称", OTAUpdate.appName)),
          Expanded(child: labelText("版本名称", OTAUpdate.tempVersion)),
          Expanded(child: labelText("服务器IP地址 ", HostPortStorage.hostname)),
          Expanded(child: labelText("服务器端口号 ", HostPortStorage.hostport)),
          Expanded(child: useEnigmaCodes()),
          Expanded(child: inviteCodes()),
          Expanded(child: newVersion()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Text(""),
        title: const Text("版本信息"),
        centerTitle: true,
      ),
      body: Center(
        child: getBodyInfo(),
      ),
    );
  }
}
