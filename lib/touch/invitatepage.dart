import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class InvitationPageTouch extends StatefulWidget {
  const InvitationPageTouch({Key? key}) : super(key: key);
  @override
  State<InvitationPageTouch> createState() => _InvitationPageTouch();
}

class _InvitationPageTouch extends State<InvitationPageTouch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Text(""),
        title: const Text("邀请码填写"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: const InvitationBody(),
    );
  }
}

class InvitationBody extends StatefulWidget {
  const InvitationBody({Key? key}) : super(key: key);
  @override
  State<InvitationBody> createState() => _InvitationBody();
}

class _InvitationBody extends State<InvitationBody> {
  GlobalKey<_InputTextWidgetInviteTouch> inputKey = GlobalKey();
  String inputText = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child:
                InputTextWidgetInviteTouch(key: inputKey, textLabel: "请输入邀请码"),
          ),
          ConformBtnTouch(conformFunc: () async {
            var msg = ScaffoldMessenger.of(context);
            var mqContext = MediaQuery.of(context);
            var snackBar = SnackBar(
              content: Text(
                "邀请码为空",
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 60),
              ),
              duration: const Duration(seconds: 1),
            );
            var getText = inputKey.currentState?.inputText;
            if (getText == null) {
              msg.showSnackBar(snackBar);
              return;
            }
            inputText = getText;
            if (inputText == "") {
              msg.showSnackBar(snackBar);
              return;
            }
            await HostPortStorage.setTokens(inputText);
            msg.showSnackBar(SnackBar(
              content: Text(
                "邀请码设置成功",
                style: TextStyle(fontSize: mqContext.size.width / 60),
              ),
              duration: const Duration(seconds: 1),
            ));
          })
        ],
      ),
    );
  }
}

class InputTextWidgetInviteTouch extends StatefulWidget {
  const InputTextWidgetInviteTouch({Key? key, required this.textLabel})
      : super(key: key);
  final String textLabel;
  @override
  State<InputTextWidgetInviteTouch> createState() =>
      _InputTextWidgetInviteTouch();
}

class _InputTextWidgetInviteTouch extends State<InputTextWidgetInviteTouch> {
  String inputText = "";
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      onChanged: (value) {
        inputText = value;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))
      ],
      maxLength: 20,
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
}

typedef ConformFunc = dynamic Function();

class ConformBtnTouch extends StatefulWidget {
  const ConformBtnTouch({Key? key, required this.conformFunc})
      : super(key: key);
  final ConformFunc? conformFunc;
  @override
  State<ConformBtnTouch> createState() => _ConformBtn();
}

class _ConformBtn extends State<ConformBtnTouch> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: MaterialButton(
        autofocus: true,
        onPressed: widget.conformFunc,
        color: Colors.grey,
        focusColor: HostPortStorage.themeColor,
        child: Center(
            child: Text(
          "确认",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 40),
        )),
      ),
    );
  }
}
