import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  GlobalKey<_InputTextWidgetSetting> hostKey = GlobalKey();
  GlobalKey<_InputTextWidgetSetting> portKey = GlobalKey();
  GlobalKey<_HttpsSwitch> httpsKey = GlobalKey();
  FocusNode hostBox = FocusNode();
  FocusNode hostinput = FocusNode();
  FocusNode portBox = FocusNode();
  FocusNode portinput = FocusNode();
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
                      child: InputTextWidgetSetting(
                        key: hostKey,
                        textLabel: "服务器IPv4地址",
                        boxNode: hostBox,
                        inputNode: hostinput,
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
                      child: InputTextWidgetSetting(
                        key: portKey,
                        textLabel: "端口号",
                        boxNode: portBox,
                        inputNode: portinput,
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

class InputTextWidgetSetting extends StatefulWidget {
  const InputTextWidgetSetting(
      {Key? key,
      required this.textLabel,
      required this.boxNode,
      required this.inputNode,
      required this.maxLen,
      required this.formatters})
      : super(key: key);
  final String textLabel;
  final FocusNode boxNode;
  final FocusNode inputNode;
  final int maxLen;
  final List<TextInputFormatter> formatters;
  @override
  State<InputTextWidgetSetting> createState() => _InputTextWidgetSetting();
}

class _InputTextWidgetSetting extends State<InputTextWidgetSetting>
    with WidgetsBindingObserver {
  bool selected = false;
  String inputText = "";
  bool enterText = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid && widget.inputNode.hasFocus) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          enterText = false;
          FocusScope.of(context).requestFocus(widget.boxNode);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: widget.boxNode,
      onFocusChange: (value) {
        setState(() {
          if (value && !enterText) {
            widget.boxNode.requestFocus();
          }
          selected = value;
        });
      },
      onTap: () {
        enterText = true;
        FocusScope.of(context).requestFocus(widget.inputNode);
      },
      autofocus: true,
      focusColor: Colors.transparent,
      child: TextField(
        focusNode: widget.inputNode,
        autofocus: false,
        onChanged: (value) {
          setState(() {
            inputText = value;
          });
        },
        keyboardType: TextInputType.number,
        inputFormatters: widget.formatters,
        maxLength: widget.maxLen,
        decoration: InputDecoration(
          labelText: widget.textLabel,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: selected ? HostPortStorage.themeColor : Colors.grey,
                width: 3),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: HostPortStorage.themeColor, width: 3)),
        ),
        autocorrect: false,
        enableSuggestions: false,
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
