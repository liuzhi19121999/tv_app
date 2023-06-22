import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:tv_old_ver/history/database.dart';
import 'package:tv_old_ver/video_state.dart';
import '../title_button.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  State<HistoryPage> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("历史记录"),
        centerTitle: true,
        leading: const Text(""),
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        actions: [
          TitleButton(
              iconData: Icons.refresh,
              label: "刷新",
              bgcolor: Colors.lightBlue,
              titelClick: () async {
                historyState.setFresh();
              }),
          TitleButton(
              iconData: Icons.delete_forever,
              label: "清空",
              bgcolor: Colors.lightBlue,
              titelClick: () async {
                await HistoryStorageDB.clearStorage();
                historyState.setFresh();
              }),
        ],
      ),
      body: const HistoryBody(),
    );
  }
}

class HistoryBody extends StatefulWidget {
  const HistoryBody({Key? key}) : super(key: key);
  @override
  State<HistoryBody> createState() => _HistoryBody();
}

class _HistoryBody extends State<HistoryBody> {
  Future<void> initInfos() async {
    //late var provider = Provider.of<HistoryState>(context, listen: false);
    await HistoryStorageDB.initStorage();
    historyState.setHistory(HistoryStorageDB.storages["storages"]);
  }

  void setStateListen() async {
    if (historyState.needRefresh) {
      await HistoryStorageDB.initStorage();
      historyState.setHistory(HistoryStorageDB.storages["storages"]);
      historyState.setFreshed();
      setState(() {});
    }
  }

  @override
  void initState() {
    historyState.setFreshed();
    historyState.addListener(setStateListen);
    super.initState();
  }

  @override
  void dispose() {
    historyState.removeListener(setStateListen);
    super.dispose();
  }

  List<Widget> showHistoryBlock() {
    List<Widget> results = [];
    List hstorages = historyState.historyInfo;
    int count = 0;
    List<Widget> rowChildren = [];
    for (var i = hstorages.length - 1; i >= 0; i--) {
      count += 1;
      var itemBlock = ClickHistoryBlock(
        name: hstorages[i]["name"],
        imgPath: hstorages[i]["img"],
        station: hstorages[i]["station"],
        urlPath: hstorages[i]["urlpath"],
        videoIndex: hstorages[i]["vindex"],
        seekTime: hstorages[i]["seektime"],
      );
      rowChildren.add(itemBlock);
      if (count % 5 == 0) {
        results.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren));
        results.add(Divider(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height / 80,
        ));
        rowChildren = [];
      }
      if (i == 0) {
        var lefted = 5 - rowChildren.length;
        for (var j = 0; j < lefted; j++) {
          rowChildren.add(Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.006),
            width: MediaQuery.of(context).size.width * 0.19,
            height: MediaQuery.of(context).size.height * 0.35,
            child: const Text(""),
          ));
        }
        results.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren));
        rowChildren = [];
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initInfos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return historyState.historyInfo.isEmpty
              ? Center(
                  child: Text(
                    "暂无观看记录",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 45),
                  ),
                )
              : ListView(
                  children: showHistoryBlock(),
                );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

//typedef DelectFunction = dynamic Function();

class ClickHistoryBlock extends StatefulWidget {
  const ClickHistoryBlock({
    Key? key,
    required this.name,
    required this.imgPath,
    required this.station,
    required this.urlPath,
    required this.videoIndex,
    required this.seekTime,
    //required this.delectFunction
  }) : super(key: key);
  final String imgPath;
  final String station;
  final String urlPath;
  final int videoIndex;
  final int seekTime;
  final String name;
  //final DelectFunction? delectFunction;
  @override
  State<ClickHistoryBlock> createState() => _ClickHistoryBlock();
}

class _ClickHistoryBlock extends State<ClickHistoryBlock> {
  //FocusNode deletedFocus = FocusNode();
  FocusNode inkWellNode =
      FocusNode(canRequestFocus: false, descendantsAreFocusable: false);
  FocusNode focusNode = FocusNode();
  bool selected = false;
  bool deleted = false; // 显示删除按钮

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        selected = true;
      });
    } else {
      setState(() {
        selected = false;
        deleted = false;
      });
    }
  }

  @override
  void initState() {
    focusNode.addListener(onFocusChange);
    //deletedFocus.addListener(onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    //deletedFocus.removeListener(onFocusChange);
    super.dispose();
  }

  Widget delectOrNot() {
    if (deleted) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.17,
        height: MediaQuery.of(context).size.height * 0.28,
        child: Icon(
          Icons.delete,
          color: Colors.red,
          size: MediaQuery.of(context).size.height / 6,
        ),
      );
    } else {
      return Image.network(
        widget.imgPath,
        width: MediaQuery.of(context).size.width * 0.17,
        height: MediaQuery.of(context).size.height * 0.28,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.17,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Icon(
              Icons.error,
              size: MediaQuery.of(context).size.height / 6,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HostPortStorage.useTouch
        ? InkWell(
            autofocus: false,
            focusColor: Colors.transparent,
            focusNode: inkWellNode,
            onLongPress: () async {
              await HistoryStorageDB.clearTarget(
                  widget.name,
                  widget.videoIndex,
                  widget.seekTime,
                  widget.station,
                  widget.urlPath,
                  widget.imgPath);
              historyState.setFresh();
            },
            onTap: () {
              videoTextState.setTempInfo(widget.seekTime, widget.videoIndex);
              videoBtnState.setTempInfo(widget.seekTime, widget.videoIndex);
              GoRouter.of(context).push("/videoinfo", extra: {
                "url": widget.urlPath,
                "stations": widget.station,
                "id": widget.videoIndex,
                "seek": widget.seekTime,
              });
            },
            child: Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.006),
              width: MediaQuery.of(context).size.width * 0.19,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? Colors.blue : Colors.transparent,
                      width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: selected ? Colors.blue : Colors.transparent,
                      blurRadius: selected
                          ? MediaQuery.of(context).size.width * 0.02
                          : 0,
                      spreadRadius: selected
                          ? MediaQuery.of(context).size.width * 0.01
                          : 0,
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  delectOrNot(),
                  Text(
                    "${widget.name} 第${widget.videoIndex + 1}集",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ))
        : RawKeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            includeSemantics: false,
            onKey: (RawKeyEvent event) async {
              if (event.isKeyPressed(LogicalKeyboardKey.select)) {
                //late GoRouter goRouter = GoRouter.of(context);
                if (selected && deleted) {
                  await HistoryStorageDB.clearTarget(
                      widget.name,
                      widget.videoIndex,
                      widget.seekTime,
                      widget.station,
                      widget.urlPath,
                      widget.imgPath);
                  historyState.setFresh();
                } else if (selected && !deleted) {
                  videoTextState.setTempInfo(
                      widget.seekTime, widget.videoIndex);
                  videoBtnState.setTempInfo(widget.seekTime, widget.videoIndex);
                  GoRouter.of(context).push("/videoinfo", extra: {
                    "url": widget.urlPath,
                    "stations": widget.station,
                    "id": widget.videoIndex,
                    "seek": widget.seekTime,
                  });
                }
              }
              if (event.isKeyPressed(LogicalKeyboardKey.contextMenu) &&
                  selected) {
                switch (deleted) {
                  case true:
                    setState(() {
                      deleted = false;
                    });
                    //FocusScope.of(context).requestFocus(focusNode);
                    break;
                  case false:
                    setState(() {
                      deleted = true;
                    });
                    break;
                  default:
                    break;
                }
              }
            },
            child: Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.006),
              width: MediaQuery.of(context).size.width * 0.19,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? Colors.blue : Colors.transparent,
                      width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: selected ? Colors.blue : Colors.transparent,
                      blurRadius: selected
                          ? MediaQuery.of(context).size.width * 0.02
                          : 0,
                      spreadRadius: selected
                          ? MediaQuery.of(context).size.width * 0.01
                          : 0,
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  delectOrNot(),
                  Text(
                    "${widget.name} 第${widget.videoIndex + 1}集",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ));
  }
}
