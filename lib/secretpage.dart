import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class SecretPage extends StatefulWidget {
  const SecretPage({Key? key}) : super(key: key);
  @override
  State<SecretPage> createState() => _SecretPage();
}

class _SecretPage extends State<SecretPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("加密方式"),
        centerTitle: true,
        leading: const Text(""),
      ),
      body: const SecretBody(),
    );
  }
}

class SecretBody extends StatefulWidget {
  const SecretBody({Key? key}) : super(key: key);
  @override
  State<SecretBody> createState() => _SecretBody();
}

class _SecretBody extends State<SecretBody> {
  List<int> stringList = [];
  GlobalKey<_SwitchBtn> switchKey = GlobalKey();

  FocusNode btnNode = FocusNode();
  FocusNode switchNode = FocusNode();

  FocusNode boxNode1 = FocusNode();
  FocusNode textNode1 = FocusNode();
  GlobalKey<_InputTextWidget> indsKey1 = GlobalKey();

  FocusNode boxNode2 = FocusNode();
  FocusNode textNode2 = FocusNode();
  GlobalKey<_InputTextWidget> indsKey2 = GlobalKey();

  FocusNode boxNode3 = FocusNode();
  FocusNode textNode3 = FocusNode();
  GlobalKey<_InputTextWidget> indsKey3 = GlobalKey();

  FocusNode boxNode4 = FocusNode();
  FocusNode textNode4 = FocusNode();
  GlobalKey<_InputTextWidget> indsKey4 = GlobalKey();

  FocusNode boxNode5 = FocusNode();
  FocusNode textNode5 = FocusNode();
  GlobalKey<_InputTextWidget> indsKey5 = GlobalKey();

  SnackBar showSnackBarLabel(String label) {
    return SnackBar(
      content: Text(
        label,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 60),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "是否启用Enigma加密系统:",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 50),
            ),
            SwitchBtn(
              key: switchKey,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InputTextWidget(
                key: indsKey1,
                textLabel: "第1个转子",
                boxNode: boxNode1,
                inputNode: textNode1),
            InputTextWidget(
                key: indsKey2,
                textLabel: "第2个转子",
                boxNode: boxNode2,
                inputNode: textNode2),
            InputTextWidget(
                key: indsKey3,
                textLabel: "第3个转子",
                boxNode: boxNode3,
                inputNode: textNode3),
            InputTextWidget(
                key: indsKey4,
                textLabel: "第4个转子",
                boxNode: boxNode4,
                inputNode: textNode4),
            InputTextWidget(
                key: indsKey5,
                textLabel: "第5个转子",
                boxNode: boxNode5,
                inputNode: textNode5),
          ],
        ),
        const Text(""),
        const Text(""),
        OKBtnClass(btnfunc: () async {
          var msg = ScaffoldMessenger.of(context);
          stringList = [];
          var useE = switchKey.currentState?.state;
          if (useE == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误01"));
            return;
          }

          var code1 = indsKey1.currentState?.textInput;
          if (code1 == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误02"));
            return;
          }
          var num1 = int.tryParse(code1);
          if (num1 != null) {
            stringList.add(num1);
          }
          code1 = null;
          num1 = null;
          code1 = indsKey2.currentState?.textInput;
          if (code1 == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误02"));
            return;
          }
          num1 = int.tryParse(code1);
          if (num1 != null) {
            stringList.add(num1);
          }
          code1 = null;
          num1 = null;
          code1 = indsKey3.currentState?.textInput;
          if (code1 == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误02"));
            return;
          }
          num1 = int.tryParse(code1);
          if (num1 != null) {
            stringList.add(num1);
          }
          code1 = null;
          num1 = null;
          code1 = indsKey4.currentState?.textInput;
          if (code1 == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误02"));
            return;
          }
          num1 = int.tryParse(code1);
          if (num1 != null) {
            stringList.add(num1);
          }
          code1 = null;
          num1 = null;
          code1 = indsKey5.currentState?.textInput;
          if (code1 == null) {
            msg.showSnackBar(showSnackBarLabel("配置错误02"));
            return;
          }
          num1 = int.tryParse(code1);
          if (num1 != null) {
            stringList.add(num1);
          }
          code1 = null;
          num1 = null;

          if (stringList.length != 5) {
            msg.showSnackBar(showSnackBarLabel("转子密码与转子数不匹配"));
            return;
          }
          await HostPortStorage.setUseEnigma(useE);
          await HostPortStorage.setEnigmaCodeList(stringList);
          msg.showSnackBar(showSnackBarLabel("配置成功"));
        })
      ],
    );
  }
}

class InputTextWidget extends StatefulWidget {
  const InputTextWidget(
      {Key? key,
      required this.textLabel,
      required this.boxNode,
      required this.inputNode})
      : super(key: key);
  final String textLabel;
  final FocusNode boxNode;
  final FocusNode inputNode;
  @override
  State<InputTextWidget> createState() => _InputTextWidget();
}

class _InputTextWidget extends State<InputTextWidget>
    with WidgetsBindingObserver {
  bool selected = false;
  String textInput = "";
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.2,
      child: InkWell(
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
              textInput = value;
            });
          },
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
          ],
          maxLength: 2,
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
      ),
    );
  }
}

class SwitchBtn extends StatefulWidget {
  const SwitchBtn({Key? key}) : super(key: key);
  @override
  State<SwitchBtn> createState() => _SwitchBtn();
}

class _SwitchBtn extends State<SwitchBtn> {
  bool state = false;
  @override
  void initState() {
    state = HostPortStorage.useEnigma;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      autofocus: true,
      focusColor: Colors.blueAccent,
      activeColor: Colors.lightBlue,
      value: state,
      onChanged: (value) {
        setState(() {
          state = value;
        });
      },
    );
  }
}

class SnackBarLabel extends StatelessWidget {
  const SnackBarLabel({Key? key, required this.label}) : super(key: key);
  final String label;
  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(
        label,
        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 60),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}

typedef OKBtnFunc = dynamic Function();

class OKBtnClass extends StatefulWidget {
  const OKBtnClass({Key? key, required this.btnfunc}) : super(key: key);
  final OKBtnFunc? btnfunc;
  @override
  State<OKBtnClass> createState() => _OKBtnClass();
}

class _OKBtnClass extends State<OKBtnClass> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      child: MaterialButton(
        color: Colors.grey,
        onPressed: widget.btnfunc,
        focusColor: HostPortStorage.themeColor,
        autofocus: true,
        child: Center(
          child: Text(
            "确认",
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 45),
          ),
        ),
      ),
    );
  }
}
