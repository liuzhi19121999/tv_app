import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class SettingPageTouch extends StatefulWidget {
  const SettingPageTouch({Key? key}) : super(key: key);
  @override
  State<SettingPageTouch> createState() => _SettingPageTouch();
}

class _SettingPageTouch extends State<SettingPageTouch> {
  GlobalKey<_InputTextWidgetSettingT> hostKey = GlobalKey();
  GlobalKey<_InputTextWidgetSettingT> portKey = GlobalKey();
  GlobalKey<_HttpsSwitch> httpsKey = GlobalKey();
  String host = "";
  String port = "";
  String portcoltemp = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const Text(""),
        title: const Text("设置"),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const Expanded(child: Text("")),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "是否为Https传输协议",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 25),
                    ),
                    HttpsSwitch(
                      key: httpsKey,
                    ),
                  ],
                )),
            const Expanded(flex: 1, child: Text("")),
            Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    Expanded(
                      flex: 3,
                      child: InputTextWidgetSettingTouch(
                        key: hostKey,
                        textLabel: "服务器IPv4地址",
                        maxLen: 15,
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Text(""),
                    ),
                    Expanded(
                      flex: 3,
                      child: InputTextWidgetSettingTouch(
                        key: portKey,
                        textLabel: "端口号",
                        maxLen: 5,
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                      ),
                    ),
                    const Expanded(flex: 1, child: Text("")),
                  ],
                )),
            const Expanded(
              flex: 1,
              child: Text(""),
            ),
            Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.height / 13,
                    child: ComfirmButton(
                      comfirmFunc: () async {
                        var media = MediaQuery.of(context);
                        var msg = ScaffoldMessenger.of(context);
                        host = hostKey.currentState?.inputText as String;
                        port = portKey.currentState?.inputText as String;
                        portcoltemp = httpsKey.currentState?.portcol as String;
                        if (host == "" || port == "") {
                          var snackbar = SnackBar(
                            content: Text(
                              "服务器地址或端口号不为空",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 60),
                            ),
                            duration: const Duration(seconds: 1),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          return;
                        }
                        var hostList = host.split('.');
                        if (hostList.length != 4) {
                          var snackBar = SnackBar(
                            content: Text(
                              "服务器地址有误",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 60),
                            ),
                            duration: const Duration(seconds: 1),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return;
                        }
                        var portList = port.split('');
                        if (portList.contains('.')) {
                          var snackBar = SnackBar(
                            content: Text(
                              "端口号有误",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 60),
                            ),
                            duration: const Duration(seconds: 1),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return;
                        }
                        HostPortStorage.hostname = host;
                        HostPortStorage.hostport = port;
                        HostPortStorage.hostportcol = portcoltemp;
                        await HostPortStorage.setHostPort(
                            host, port, portcoltemp);
                        var snackBar = SnackBar(
                          content: Text(
                            "设置完成",
                            style: TextStyle(fontSize: media.size.width / 60),
                          ),
                          duration: const Duration(seconds: 1),
                        );
                        msg.showSnackBar(snackBar);
                      },
                    ),
                  ),
                )),
            const Expanded(flex: 1, child: Text("")),
          ],
        ),
      ),
    );
  }
}

class HttpsSwitch extends StatefulWidget {
  const HttpsSwitch({Key? key}) : super(key: key);
  @override
  State<HttpsSwitch> createState() => _HttpsSwitch();
}

class _HttpsSwitch extends State<HttpsSwitch> {
  bool httpsFunc = false;
  String portcol = "http";
  @override
  Widget build(BuildContext context) {
    return Switch(
      autofocus: true,
      focusColor: Colors.blueAccent,
      activeColor: Colors.lightBlue,
      value: httpsFunc,
      //materialTapTargetSize: MaterialTapTargetSize.padded,
      onChanged: (value) {
        setState(() {
          if (value) {
            portcol = "https";
          } else {
            portcol = "http";
          }
          httpsFunc = value;
        });
      },
    );
  }
}

class InputTextWidgetSettingTouch extends StatefulWidget {
  const InputTextWidgetSettingTouch(
      {Key? key,
      required this.textLabel,
      required this.maxLen,
      required this.formatters})
      : super(key: key);
  final String textLabel;
  final int maxLen;
  final List<TextInputFormatter> formatters;
  @override
  State<InputTextWidgetSettingTouch> createState() =>
      _InputTextWidgetSettingT();
}

class _InputTextWidgetSettingT extends State<InputTextWidgetSettingTouch> {
  bool selected = false;
  String inputText = "";
  bool enterText = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      onChanged: (value) {
        inputText = value;
      },
      keyboardType: TextInputType.number,
      inputFormatters: widget.formatters,
      maxLength: widget.maxLen,
      decoration: InputDecoration(
        labelText: widget.textLabel,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: HostPortStorage.themeColor, width: 3)),
      ),
    );
  }

  //get inputTextString => inputText;
}

typedef ComfirmFunc = dynamic Function();

class ComfirmButton extends StatefulWidget {
  final ComfirmFunc? comfirmFunc;
  const ComfirmButton({Key? key, this.comfirmFunc}) : super(key: key);
  @override
  State<ComfirmButton> createState() => _ComfirmButton();
}

class _ComfirmButton extends State<ComfirmButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      autofocus: true,
      onPressed: widget.comfirmFunc,
      color: Colors.grey,
      focusColor: HostPortStorage.themeColor,
      child: Center(
        child: Text(
          "确认",
          style: TextStyle(fontSize: MediaQuery.of(context).size.height / 20),
        ),
      ),
    );
  }
}
