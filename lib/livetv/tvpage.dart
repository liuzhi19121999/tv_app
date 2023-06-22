import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:wakelock/wakelock.dart';
import 'tvnetfunc.dart';

// 仿照电视家设计的直播页面
class TVPlayerBody extends StatefulWidget {
  const TVPlayerBody({Key? key}) : super(key: key);
  @override
  State<TVPlayerBody> createState() => _TVPlayerBody();
}

class _TVPlayerBody extends State<TVPlayerBody> {
  //TVHomeStream tvHomeStream = TVHomeStream();
  Future? future;

  @override
  void initState() {
    future = tvHomeStream.initTVPlayers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (tvHomeStream.catesList.isEmpty) {
            return Scaffold(
              body: Center(
                child: Text(
                  "邀请码错误,请返回后重试",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 40),
                ),
              ),
            );
          }
          if (tvHomeStream.m3u8List.isEmpty) {
            if (TVIndexStorage.index >=
                (tvHomeStream.channelLabels.length - 1)) {
              TVIndexStorage.index = 0;
            } else {
              TVIndexStorage.index++;
            }
            setState(() {
              future = tvHomeStream.getStreamList(TVIndexStorage.index);
            });
          }
          return const TVMediaPlayer();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class TVMediaPlayer extends StatefulWidget {
  const TVMediaPlayer({Key? key}) : super(key: key);
  @override
  State<TVMediaPlayer> createState() => _TVMediaPlayer();
}

class _TVMediaPlayer extends State<TVMediaPlayer> {
  FocusNode focusNode = FocusNode();
  //FocusNode blank = FocusNode();
  int tempIndex = 0;
  //int streamId = 0;
  bool chooseStream = false;
  //bool showLabel = false;
  String label = "";
  bool errorStream = false;
  final FijkPlayer fijkPlayer = FijkPlayer();

  _initPlayer() async {
    tvStateClass.streamID = 0;
    tvHomeStream.needRefresh = false;
    tempIndex = TVIndexStorage.index;
    label = tvHomeStream.channelLabels[tempIndex];
    tvHomeStream.needShowLabel = true;
    await Wakelock.enable();
    await fijkPlayer.setOption(FijkOption.formatCategory, "reconnect", 0);
    await fijkPlayer.setOption(FijkOption.formatCategory, "flush_packets", 1);
    await fijkPlayer.setOption(
        FijkOption.playerCategory, "packet-buffering", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "framedrop", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec-hevc", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec", 1);
    await fijkPlayer.setOption(
        FijkOption.playerCategory, "mediacodec-auto-rotate", 1);
    await fijkPlayer.setOption(
        FijkOption.playerCategory, "mediacodec-handle-resolution-change", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "videotoolbox", 1);

    await fijkPlayer.setDataSource(tvHomeStream.m3u8List[0], autoPlay: true);
  }

  Future<void> fijkPlayerListen() async {
    if (fijkPlayer.state == FijkState.started) {
      tempIndex = tvHomeStream.channelsID;
      setState(() {
        tvHomeStream.needShowLabel = false;
      });
    }
    if (fijkPlayer.state == FijkState.error &&
        (tvStateClass.streamID + 1) < tvHomeStream.m3u8List.length &&
        !errorStream) {
      //print("A STREAM is ${tvStateClass.streamID}");
      errorStream = true;
      await fijkPlayer.reset();
    }
    if (fijkPlayer.state == FijkState.idle && errorStream) {
      //sleep(const Duration(milliseconds: 300));
      //print("B STREAM is ${tvStateClass.streamID}");
      errorStream = false;
      tvStateClass.streamID++;
      label =
          "换源：${tvStateClass.streamID + 1} / ${tvHomeStream.m3u8List.length}";
      setState(() {
        tvHomeStream.needShowLabel = true;
      });
      //print("C STREAM IS ${tvStateClass.streamID}");
      //sleep(const Duration(seconds: 20));
      tvStateClass.needRefresh();
      chooseStream = true;
    }
  }

  _addNeedRefreshTV() async {
    if (tvStateClass.showLabel) {
      tvStateClass.showLabel = false;
      setState(() {
        label = tvStateClass.labelString;
        tvHomeStream.needShowLabel = true;
      });
    }
    if (tvStateClass.needRefreshState) {
      tvStateClass.hasRefreshed();
      await fijkPlayer.reset();
      await fijkPlayer.setOption(FijkOption.formatCategory, "reconnect", 0);
      await fijkPlayer.setOption(FijkOption.formatCategory, "flush_packets", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "packet-buffering", 1);
      await fijkPlayer.setOption(FijkOption.playerCategory, "framedrop", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-hevc", 1);
      await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-auto-rotate", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-handle-resolution-change", 1);
      await fijkPlayer.setOption(FijkOption.playerCategory, "videotoolbox", 1);

      await fijkPlayer.setDataSource(
          tvHomeStream.m3u8List[tvStateClass.streamID],
          autoPlay: true);
    }
  }

  @override
  void initState() {
    _initPlayer();
    fijkPlayer.addListener(fijkPlayerListen);
    tvStateClass.addListener(_addNeedRefreshTV);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void didChangeDependencies() {
    //FocusScope.of(context).requestFocus(focusNode);
    super.didChangeDependencies();
  }

  Future<void> _disposePlayer() async {
    await Wakelock.disable();
    await TVIndexStorage.setTVIndex(tempIndex);
  }

  @override
  void dispose() {
    _disposePlayer();
    tvStateClass.removeListener(_addNeedRefreshTV);
    fijkPlayer.removeListener(fijkPlayerListen);
    fijkPlayer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: HostPortStorage.useTouch
          ? InkWell(
              autofocus: false,
              onDoubleTap: () {
                Navigator.push(
                    context,
                    PopRouter(
                        child: TVChannelContainer(
                      index: tempIndex,
                    )));
              },
              child: FijkView(
                player: fijkPlayer,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
              ),
            )
          : RawKeyboardListener(
              focusNode: focusNode,
              onKey: (RawKeyEvent event) async {
                if (event.isKeyPressed(LogicalKeyboardKey.select) &&
                    focusNode.hasFocus) {
                  Navigator.push(
                      context,
                      PopRouter(
                          child: TVChannelContainer(
                        index: tempIndex,
                      )));
                }
                // 换源
                if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
                    focusNode.hasFocus) {
                  if (tvStateClass.streamID > 0) {
                    tvStateClass.streamID--;
                    label =
                        "换源：${tvStateClass.streamID + 1} / ${tvHomeStream.m3u8List.length}";
                    setState(() {
                      tvHomeStream.needShowLabel = true;
                    });
                    tvStateClass.needRefresh();
                    chooseStream = true;
                  }
                }
                if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
                    focusNode.hasFocus) {
                  if ((tvStateClass.streamID + 1) <
                      tvHomeStream.m3u8List.length) {
                    tvStateClass.streamID++;
                    label =
                        "换源：${tvStateClass.streamID + 1} / ${tvHomeStream.m3u8List.length}";
                    setState(() {
                      tvHomeStream.needShowLabel = true;
                    });
                    tvStateClass.needRefresh();
                    chooseStream = true;
                  }
                }
                // 换台
                // +
                if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
                    focusNode.hasFocus) {
                  tvStateClass.streamID = 0;
                  if (tempIndex == (tvHomeStream.channelLabels.length - 1)) {
                    tempIndex = 0;
                  } else {
                    tempIndex++;
                  }
                  label = tvHomeStream.channelLabels[tempIndex];
                  setState(() {
                    tvHomeStream.needShowLabel = true;
                  });
                  await tvHomeStream.getStreamList(tempIndex);
                  tvStateClass.needRefresh();
                }
                // -
                if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
                    focusNode.hasFocus) {
                  tvStateClass.streamID = 0;
                  if (tempIndex == 0) {
                    tempIndex = tvHomeStream.channelLabels.length - 1;
                  } else {
                    tempIndex--;
                  }
                  label = tvHomeStream.channelLabels[tempIndex];
                  setState(() {
                    tvHomeStream.needShowLabel = true;
                  });
                  await tvHomeStream.getStreamList(tempIndex);
                  tvStateClass.needRefresh();
                }
              },
              child: FijkView(
                player: fijkPlayer,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: tvHomeStream.needShowLabel
          ? Container(
              //color: Colors.black54,
              height: MediaQuery.of(context).size.height * 0.12,
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(179, 0, 0, 0),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.white, width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const CircularProgressIndicator(),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 45),
                  )
                ],
              ))
          : null,
    );
  }
}

class PopRouter extends PopupRoute {
  final Duration _duration = const Duration(milliseconds: 300);
  Widget child;

  PopRouter({required this.child});

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _duration;
}

class TVChannelContainer extends StatelessWidget {
  const TVChannelContainer({Key? key, required this.index}) : super(key: key);
  final int index;

  List<TVChannelsColumn> generateColums() {
    List<TVChannelsColumn> listChildren = [];
    for (var i = 0; i < tvHomeStream.catesList.length; i++) {
      listChildren.add(TVChannelsColumn(
          start: tvHomeStream.sliceIndex[i * 2],
          end: tvHomeStream.sliceIndex[i * 2 + 1],
          choose: index,
          label: tvHomeStream.catesList[i]));
    }
    return listChildren;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color.fromARGB(179, 0, 0, 0),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: generateColums(),
            ),
          )
        ],
      ),
    );
  }
}

class TVChannelsColumn extends StatelessWidget {
  const TVChannelsColumn(
      {Key? key,
      required this.start,
      required this.end,
      required this.choose,
      required this.label})
      : super(key: key);
  final int start;
  final int end;
  final int choose;
  final String label;
  List<Widget> listTileList() {
    List<Widget> temp = [];
    for (var i = start; i <= end; i++) {
      temp.add(TVChannelItem(ind: i, choose: choose));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.78 /
          tvHomeStream.catesList.length,
      child: Column(
        children: [
          const Expanded(child: Text("")),
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 40),
          )),
          Expanded(
              flex: 12,
              child: ListView(
                children: listTileList(),
              )),
        ],
      ),
    );
  }
}

class TVChannelItem extends StatefulWidget {
  const TVChannelItem({Key? key, required this.ind, required this.choose})
      : super(key: key);
  final int ind;
  final int choose;
  @override
  State<TVChannelItem> createState() => _TVChannelItem();
}

class _TVChannelItem extends State<TVChannelItem> {
  bool selected = false;
  bool autoFocus = false;
  FocusNode tempFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.transparent,
      ),
      width: MediaQuery.of(context).size.width *
          0.75 /
          tvHomeStream.catesList.length,
      height: MediaQuery.of(context).size.height * 0.1,
      child: InkWell(
        autofocus: !HostPortStorage.useTouch,
        focusNode: tempFocus,
        onFocusChange: (value) {
          setState(() {
            selected = value;
          });
        },
        focusColor: Colors.transparent,
        onTap: () {
          final nav = Navigator.of(context);
          tvStateClass.changeChannels(widget.ind);
          nav.pop();
        },
        child: Center(
          child: Text(
            tvHomeStream.channelLabels[widget.ind],
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 45),
          ),
        ),
      ),
    );
  }
}
