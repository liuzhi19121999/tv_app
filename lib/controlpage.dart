import 'package:flutter/material.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';

UpdateHomePage updateHomePage = UpdateHomePage();

class UpdateHomePage extends ChangeNotifier {
  bool needUpdate = false;

  void setUpdate() {
    needUpdate = true;
  }

  void upDated() {
    needUpdate = false;
  }

  bool get needupdate => needUpdate;
}

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("设置"),
        leading: const Text(""),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: const ControlPageBody(),
      ),
    );
  }
}

class ControlPageBody extends StatefulWidget {
  const ControlPageBody({Key? key}) : super(key: key);
  @override
  State<ControlPageBody> createState() => _ControlPageBody();
}

class _ControlPageBody extends State<ControlPageBody> {
  bool useOrNot = false;

  @override
  void initState() {
    useOrNot = HostPortStorage.useTouch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Colors.yellow,
              size: MediaQuery.of(context).size.width / 40,
            ),
            Text(
              "请勿在不了解的情况下更改以下配置，以免损坏已有程序文件",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 50),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "是否对触摸操作进行优化：",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 50),
            ),
            Switch(
              autofocus: true,
              focusColor: Colors.blueAccent,
              activeColor: Colors.lightBlue,
              value: useOrNot,
              onChanged: (value) {
                setState(() {
                  useOrNot = value;
                });
              },
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: MaterialButton(
            color: Colors.grey,
            autofocus: true,
            focusColor: HostPortStorage.themeColor,
            onPressed: () async {
              var media = MediaQuery.of(context);
              var msg = ScaffoldMessenger.of(context);
              await HostPortStorage.setUseTouch(useOrNot);
              updateHomePage.setUpdate();
              msg.showSnackBar(SnackBar(
                content: Text(
                  "设置完成",
                  style: TextStyle(fontSize: media.size.width / 60),
                ),
                duration: const Duration(seconds: 1),
              ));
            },
            child: Text(
              "确认",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 40),
            ),
          ),
        ),
      ],
    );
  }
}
