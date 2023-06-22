import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/services.dart';
import 'package:tv_old_ver/video_state.dart';
import './video/requestinfo.dart';
import './history/database.dart';
import 'package:wakelock/wakelock.dart';

class PlayerVideosPage extends StatefulWidget {
  const PlayerVideosPage(
      {Key? key,
      required this.videopath,
      required this.startpoint,
      required this.id,
      required this.station,
      required this.urlpath,
      required this.imgpath,
      required this.searchTansform})
      : super(key: key);
  final int id;
  final String videopath;
  final int startpoint;
  final String station;
  final String urlpath;
  final String imgpath;
  final SearchTansform searchTansform;
  @override
  State<PlayerVideosPage> createState() => _PlayerVideosPage();
}

class _PlayerVideosPage extends State<PlayerVideosPage> {
  late int index = widget.id;
  bool first = true;
  int showFloatingLabel = 0; // 0 不显示  1 显示暂停   2 显示快进  3 显示快退
  String floatingLabel = "";
  var currentTimeStamp = 0;
  FocusNode videoFocus = FocusNode();

  // 展示图标
  Widget? showIcons() {
    switch (showFloatingLabel) {
      case 0:
        return null;
      case 1:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.pause,
                    size: MediaQuery.of(context).size.width / 8,
                  ),
                  Text(
                    "暂停",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 45),
                  ),
                ],
              ),
            ),
          ),
        );
      case 2:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.skip_next,
                    size: MediaQuery.of(context).size.width / 8,
                  ),
                  Text(
                    floatingLabel,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 50),
                  ),
                ],
              ),
            ),
          ),
        );
      case 3:
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.skip_next,
                    size: MediaQuery.of(context).size.width / 8,
                  ),
                  Text(
                    floatingLabel,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 50),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return null;
    }
  }

  Future<void> _fijkPlayerListener() async {
    FijkValue value = fijkPlayer.value;
    if (value.state == FijkState.completed &&
        index != (widget.searchTansform.videosInfo.length - 1)) {
      index += 1;
      first = false;
      await fijkPlayer.reset();
      /*
      await fijkPlayer.setOption(
          FijkOption.hostCategory, "request-audio-focus", 1);
      */
      await fijkPlayer.setOption(FijkOption.formatCategory, "reconnect", 1);

      await fijkPlayer.setOption(FijkOption.playerCategory, "framedrop", 10);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-hevc", 1);
      await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-auto-rotate", 1);
      await fijkPlayer.setOption(
          FijkOption.playerCategory, "mediacodec-handle-resolution-change", 1);
      await fijkPlayer.setOption(FijkOption.playerCategory, "videotoolbox", 1);
      await fijkPlayer.setDataSource(
          widget.searchTansform.videosInfo[index]["m3u8"],
          autoPlay: true);
    }
    if (value.state == FijkState.prepared && first) {
      await fijkPlayer.seekTo(widget.startpoint);
    }
    if (value.state == FijkState.started && showFloatingLabel != 0) {
      setState(() {
        showFloatingLabel = 0;
      });
    }
  }

  final FijkPlayer fijkPlayer = FijkPlayer();

  _initPlayer() async {
    await Wakelock.enable();
    fijkPlayer.addListener(_fijkPlayerListener);
    await fijkPlayer.setOption(FijkOption.formatCategory, "reconnect", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "framedrop", 10);
    await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec-hevc", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "mediacodec", 1);
    await fijkPlayer.setOption(
        FijkOption.playerCategory, "mediacodec-auto-rotate", 1);
    await fijkPlayer.setOption(
        FijkOption.playerCategory, "mediacodec-handle-resolution-change", 1);
    await fijkPlayer.setOption(FijkOption.playerCategory, "videotoolbox", 1);
    //await fijkPlayer.setOption(
    //    FijkOption.playerCategory, "enable-accurate-seek", 1);

    await fijkPlayer.setDataSource(
        widget.searchTansform.videosInfo[index]["m3u8"],
        autoPlay: true);
  }

  @override
  void initState() {
    //FocusScope.of(context).requestFocus(videoFocus);
    _initPlayer();
    super.initState();
  }

  Future<void> _disposeVideoPlayer() async {
    await Wakelock.disable();
    int endtime = fijkPlayer.currentPos.inMilliseconds;
    if (endtime > 20000) {
      endtime -= 10000;
    }
    videoTextState.setTempInfo(fijkPlayer.currentPos.inMilliseconds, index);
    videoTextState.needRefresh();
    videoBtnState.setTempInfo(fijkPlayer.currentPos.inMilliseconds, index);
    videoBtnState.needRefresh();
    await HistoryStorageDB.insertStorage(
        widget.searchTansform.videoTitle,
        index,
        endtime,
        widget.station,
        widget.urlpath,
        widget.searchTansform.videoPic);
  }

  @override
  void didChangeDependencies() {
    FocusScope.of(context).requestFocus(videoFocus);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    fijkPlayer.removeListener(_fijkPlayerListener);
    _disposeVideoPlayer();
    fijkPlayer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: videoFocus,
        autofocus: true,
        includeSemantics: false,
        onKey: (RawKeyEvent event) async {
          if (event.isKeyPressed(LogicalKeyboardKey.select) &&
              videoFocus.hasFocus) {
            switch (fijkPlayer.state) {
              case FijkState.started:
                floatingLabel = "暂停";
                setState(() {
                  showFloatingLabel = 1;
                });
                await fijkPlayer.pause();
                currentTimeStamp = fijkPlayer.currentPos.inMilliseconds;
                break;
              case FijkState.paused:
                floatingLabel = "";
                await fijkPlayer.seekTo(currentTimeStamp);
                await fijkPlayer.start();
                break;
              default:
                break;
            }
          }

          // left Key
          if (event.runtimeType == RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.arrowLeft &&
              videoFocus.hasFocus) {
            if (fijkPlayer.state == FijkState.started) {
              await fijkPlayer.pause();
            }
            if (!event.repeat) {
              currentTimeStamp = fijkPlayer.currentPos.inMilliseconds;
              setState(() {
                showFloatingLabel = 3;
              });
            }
            currentTimeStamp -= 5000;
            if (currentTimeStamp <= 0) {
              currentTimeStamp = 10000;
            }
            int totalTime = fijkPlayer.value.duration.inSeconds;
            setState(() {
              floatingLabel =
                  "快退:${(currentTimeStamp / 60000).floor().toString().padLeft(3, '0')}:${((currentTimeStamp / 1000) % 60).toInt().toString().padLeft(2, '0')} / ${(totalTime / 60).floor().toString().padLeft(3, '0')}:${(totalTime % 60).toInt().toString().padLeft(2, '0')}";
            });
          }

          if (event.runtimeType == RawKeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.arrowLeft &&
              videoFocus.hasFocus) {
            await fijkPlayer.seekTo(currentTimeStamp);
            await fijkPlayer.start();
          }

          // right Key
          if (event.runtimeType == RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.arrowRight &&
              videoFocus.hasFocus) {
            if (fijkPlayer.state == FijkState.started) {
              await fijkPlayer.pause();
            }
            if (!event.repeat) {
              currentTimeStamp = fijkPlayer.currentPos.inMilliseconds;
              setState(() {
                showFloatingLabel = 2;
              });
            }
            currentTimeStamp += 5000;
            if (currentTimeStamp >= fijkPlayer.value.duration.inMilliseconds) {
              currentTimeStamp =
                  (fijkPlayer.value.duration.inMilliseconds - 10000);
            }
            int totalTime = fijkPlayer.value.duration.inSeconds;
            setState(() {
              floatingLabel =
                  "快进:${(currentTimeStamp / 60000).floor().toString().padLeft(3, '0')}:${((currentTimeStamp / 1000) % 60).toInt().toString().padLeft(2, '0')} / ${(totalTime / 60).floor().toString().padLeft(3, '0')}:${(totalTime % 60).toInt().toString().padLeft(2, '0')}";
            });
          }
          if (event.runtimeType == RawKeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.arrowRight &&
              videoFocus.hasFocus) {
            await fijkPlayer.seekTo(currentTimeStamp);
            await fijkPlayer.start();
          }
        },
        child: FijkView(
          player: fijkPlayer,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showIcons(),
    );
  }
}
