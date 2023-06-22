import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/controlpage.dart';
import 'package:tv_old_ver/datastore/secrectcode.dart';
import 'package:tv_old_ver/history/database.dart';
import './upgrade.dart';
import './datastore/dataserver.dart';
import 'title_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Future<void> _initData() async {
    await HostPortStorage.initSPonLoad();
    await TVIndexStorage.getTVIndex();
    await SecrectCodeClass.initCodesFunc();
    await HistoryStorageDB.openDB();
    await OTAUpdate.checkVersion();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const TimeShowItem(),
        leadingWidth: MediaQuery.of(context).size.width * 0.4,
        title: const Text("主页"),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        actions: [
          TitleButton(
              iconData: Icons.settings,
              label: "基本设置",
              bgcolor: HostPortStorage.themeColor,
              titelClick: () {
                GoRouter.of(context).push("/setting");
              }),
          TitleButton(
              iconData: Icons.lan,
              label: "网络配置",
              bgcolor: HostPortStorage.themeColor,
              titelClick: () {
                var paths =
                    HostPortStorage.useTouch ? "/settingTouch" : "/netset";
                GoRouter.of(context).push(paths);
              }),
          TitleButton(
              iconData: Icons.security,
              label: "加密方式",
              bgcolor: HostPortStorage.themeColor,
              titelClick: () {
                var paths =
                    HostPortStorage.useTouch ? "/secretTouch" : "/secretCode";
                GoRouter.of(context).push(paths);
              })
        ],
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _initData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return OTAUpdate.updating
                ? UpdatePage(
                    ignoreFunc: () {
                      OTAUpdate.updating = false;
                      OTAUpdate.ignored = true;
                      setState(() {});
                    },
                  )
                : const Center(
                    child: BodyContainer(),
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class TimeShowItem extends StatefulWidget {
  const TimeShowItem({Key? key}) : super(key: key);
  @override
  State<TimeShowItem> createState() => _TimeShowItem();
}

class _TimeShowItem extends State<TimeShowItem> {
  DateTime dateTime = DateTime.now();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        " ${dateTime.year.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}  ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} ",
        style: const TextStyle(fontSize: 23),
      ),
    );
  }
}

class BodyContainer extends StatefulWidget {
  const BodyContainer({Key? key}) : super(key: key);
  @override
  State<BodyContainer> createState() => _BodyContainer();
}

class _BodyContainer extends State<BodyContainer> {
  void _upDateBody() {
    if (updateHomePage.needupdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          updateHomePage.upDated();
        });
      });
    }
  }

  @override
  void initState() {
    updateHomePage.upDated();
    updateHomePage.addListener(_upDateBody);
    super.initState();
  }

  @override
  void dispose() {
    updateHomePage.removeListener(_upDateBody);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TwoMulOneButton(
                  tapFunction: () {
                    GoRouter.of(context).push("/tvlive");
                  },
                  iconData: Icons.live_tv,
                  text: "电视直播",
                  color: Colors.orange),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OneMulOneButton(
                        tapFunction: () {
                          GoRouter.of(context).push("/infopage");
                        },
                        iconData: Icons.perm_device_info,
                        text: "版本信息",
                        color: Colors.green),
                    OneMulOneButton(
                        tapFunction: () {
                          var paths = HostPortStorage.useTouch
                              ? "/inviteTouch"
                              : "/invite";
                          GoRouter.of(context).push(paths);
                        },
                        iconData: Icons.check_box,
                        text: "邀请码",
                        color: Colors.pink),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OneMulOneButton(
                  tapFunction: () {
                    var paths = HostPortStorage.useTouch
                        ? "/videopageTouch"
                        : "/videos";
                    GoRouter.of(context).push(paths);
                  },
                  iconData: Icons.search,
                  text: "影视搜索",
                  color: Colors.teal),
              OneMulOneButton(
                  tapFunction: () {
                    GoRouter.of(context).push("/videoreomm");
                  },
                  iconData: Icons.local_movies,
                  text: "最新影视",
                  color: Colors.purpleAccent)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OneMulTwoButton(
                  tapFunction: () {
                    GoRouter.of(context).push("/history");
                  },
                  iconData: Icons.history,
                  text: "观看历史",
                  color: Colors.redAccent)
            ],
          ),
        ],
      ),
    );
  }
}

typedef TapFunction = dynamic Function();

// 2x1 button

class TwoMulOneButton extends StatefulWidget {
  const TwoMulOneButton(
      {Key? key,
      this.tapFunction,
      required this.iconData,
      required this.text,
      required this.color})
      : super(key: key);
  final IconData iconData;
  final String text;
  final Color color;
  final TapFunction? tapFunction;
  @override
  State<TwoMulOneButton> createState() => _TwoMulOneButton();
}

class _TwoMulOneButton extends State<TwoMulOneButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.42,
      height: MediaQuery.of(context).size.height * 0.35,
      child: InkWell(
        onTap: widget.tapFunction,
        autofocus: !HostPortStorage.useTouch,
        onFocusChange: (value) {
          setState(() {
            focused = value;
          });
        },
        focusColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(
                color: focused ? Colors.lightBlue : Colors.transparent,
                width: 2.0),
            boxShadow: [
              BoxShadow(
                color: focused ? Colors.lightBlue : Colors.transparent,
                blurRadius:
                    focused ? MediaQuery.of(context).size.width * 0.02 : 0,
                spreadRadius:
                    focused ? MediaQuery.of(context).size.width * 0.01 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                widget.iconData,
                size: MediaQuery.of(context).size.width / 8,
              ),
              Text(
                widget.text,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 1x1 button

class OneMulOneButton extends StatefulWidget {
  const OneMulOneButton(
      {Key? key,
      this.tapFunction,
      required this.iconData,
      required this.text,
      required this.color})
      : super(key: key);
  final IconData iconData;
  final String text;
  final Color color;
  final TapFunction? tapFunction;
  @override
  State<OneMulOneButton> createState() => _OneMulOneButton();
}

class _OneMulOneButton extends State<OneMulOneButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.35,
      child: InkWell(
        onTap: widget.tapFunction,
        autofocus: !HostPortStorage.useTouch,
        onFocusChange: (value) {
          setState(() {
            focused = value;
          });
        },
        focusColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(
                color: focused ? Colors.lightBlue : Colors.transparent,
                width: 2.0),
            boxShadow: [
              BoxShadow(
                color: focused ? Colors.lightBlue : Colors.transparent,
                blurRadius:
                    focused ? MediaQuery.of(context).size.width * 0.02 : 0,
                spreadRadius:
                    focused ? MediaQuery.of(context).size.width * 0.01 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                widget.iconData,
                size: MediaQuery.of(context).size.width / 14,
              ),
              Text(
                widget.text,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 50),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 1x2 button

class OneMulTwoButton extends StatefulWidget {
  const OneMulTwoButton(
      {Key? key,
      this.tapFunction,
      required this.iconData,
      required this.text,
      required this.color})
      : super(key: key);
  final IconData iconData;
  final String text;
  final Color color;
  final TapFunction? tapFunction;
  @override
  State<OneMulTwoButton> createState() => _OneMulTwoButton();
}

class _OneMulTwoButton extends State<OneMulTwoButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * 0.75,
      child: InkWell(
        onTap: widget.tapFunction,
        autofocus: !HostPortStorage.useTouch,
        onFocusChange: (value) {
          setState(() {
            focused = value;
          });
        },
        focusColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(
                color: focused ? Colors.lightBlue : Colors.transparent,
                width: 2.0),
            boxShadow: [
              BoxShadow(
                color: focused ? Colors.lightBlue : Colors.transparent,
                blurRadius:
                    focused ? MediaQuery.of(context).size.width * 0.02 : 0,
                spreadRadius:
                    focused ? MediaQuery.of(context).size.width * 0.01 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                widget.iconData,
                size: MediaQuery.of(context).size.width / 8,
              ),
              Text(
                widget.text,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 40),
              )
            ],
          ),
        ),
      ),
    );
  }
}
