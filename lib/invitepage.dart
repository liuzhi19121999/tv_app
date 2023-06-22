import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({Key? key}) : super(key: key);
  @override
  State<InvitationPage> createState() => _InvitationPage();
}

class _InvitationPage extends State<InvitationPage> {
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
  FocusNode boxNode = FocusNode();
  FocusNode inputNode = FocusNode();
  GlobalKey<_InputTextWidgetInvite> inputKey = GlobalKey();
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
          InputTextWidgetInvite(
              key: inputKey,
              textLabel: "请输入邀请码",
              boxNode: boxNode,
              inputNode: inputNode),
          ConformBtn(conformFunc: () async {
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

class InputTextWidgetInvite extends StatefulWidget {
  const InputTextWidgetInvite(
      {Key? key,
      required this.textLabel,
      required this.boxNode,
      required this.inputNode})
      : super(key: key);
  final String textLabel;
  final FocusNode boxNode;
  final FocusNode inputNode;
  @override
  State<InputTextWidgetInvite> createState() => _InputTextWidgetInvite();
}

class _InputTextWidgetInvite extends State<InputTextWidgetInvite>
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
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
              inputText = value;
            });
          },
          //keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]'))
          ],
          maxLength: 20,
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

typedef ConformFunc = dynamic Function();

class ConformBtn extends StatefulWidget {
  const ConformBtn({Key? key, required this.conformFunc}) : super(key: key);
  final ConformFunc? conformFunc;
  @override
  State<ConformBtn> createState() => _ConformBtn();
}

class _ConformBtn extends State<ConformBtn> {
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
