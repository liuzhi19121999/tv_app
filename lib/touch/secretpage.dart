import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class SecretPageTouch extends StatefulWidget {
  const SecretPageTouch({Key? key}) : super(key: key);
  @override
  State<SecretPageTouch> createState() => _SecretPageTouch();
}

class _SecretPageTouch extends State<SecretPageTouch> {
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
  GlobalKey<_InputTextWidgetT> indsKey1 = GlobalKey();
  GlobalKey<_InputTextWidgetT> indsKey2 = GlobalKey();
  GlobalKey<_InputTextWidgetT> indsKey3 = GlobalKey();
  GlobalKey<_InputTextWidgetT> indsKey4 = GlobalKey();
  GlobalKey<_InputTextWidgetT> indsKey5 = GlobalKey();

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
            InputTextWidgetTouch(
              key: indsKey1,
              textLabel: "第1个转子",
            ),
            InputTextWidgetTouch(
              key: indsKey2,
              textLabel: "第2个转子",
            ),
            InputTextWidgetTouch(
              key: indsKey3,
              textLabel: "第3个转子",
            ),
            InputTextWidgetTouch(
              key: indsKey4,
              textLabel: "第4个转子",
            ),
            InputTextWidgetTouch(
              key: indsKey5,
              textLabel: "第5个转子",
            ),
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

class InputTextWidgetTouch extends StatefulWidget {
  const InputTextWidgetTouch({Key? key, required this.textLabel})
      : super(key: key);
  final String textLabel;
  @override
  State<InputTextWidgetTouch> createState() => _InputTextWidgetT();
}

class _InputTextWidgetT extends State<InputTextWidgetTouch> {
  String textInput = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.2,
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          textInput = value;
        },
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        maxLength: 2,
        decoration: InputDecoration(
          labelText: widget.textLabel,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: HostPortStorage.themeColor, width: 3)),
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
