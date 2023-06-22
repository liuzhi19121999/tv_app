import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:tv_old_ver/video/requestinfo.dart';
import 'package:tv_old_ver/video_state.dart';

class VideoOrderPage extends StatefulWidget {
  const VideoOrderPage({Key? key}) : super(key: key);
  @override
  State<VideoOrderPage> createState() => _VideoOrderPage();
}

class _VideoOrderPage extends State<VideoOrderPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: VideoPageBody(),
      resizeToAvoidBottomInset: false,
    );
  }
}

class VideoPageBody extends StatefulWidget {
  const VideoPageBody({Key? key}) : super(key: key);
  @override
  State<VideoPageBody> createState() => _VideoPageBody();
}

class _VideoPageBody extends State<VideoPageBody> {
  late String videoNameLabel = "";
  GlobalKey<_InputSearchField> videos = GlobalKey();
  FocusNode inputText = FocusNode();
  FocusNode searchBtnNode = FocusNode();
  FocusNode inputBox = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(children: [
        Expanded(
            flex: 28,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.search,
                    size: (MediaQuery.of(context).size.height / 10),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: InputSearchField(
                      key: videos,
                      focusNode: inputText,
                      boxNode: inputBox,
                    )),
                Expanded(
                    flex: 1,
                    child: Center(
                      widthFactor: MediaQuery.of(context).size.width / 4,
                      child: SearchButton(
                        btnNode: searchBtnNode,
                        name: videos.currentState?.videoName,
                      ),
                    )),
              ],
            )),
        const Spacer(
          flex: 2,
        ),
        const Expanded(flex: 50, child: RecommendVideo()),
        const Spacer(
          flex: 4,
        ),
      ]),
    );
  }
}

//typedef OnTapSearchBox = dynamic Function();
class InputSearchField extends StatefulWidget {
  const InputSearchField(
      {Key? key,
      //required this.onTapSearchBox,
      required this.focusNode,
      required this.boxNode})
      : super(key: key);
  //final OnTapSearchBox? onTapSearchBox;
  final FocusNode focusNode;
  final FocusNode boxNode;

  @override
  State<InputSearchField> createState() => _InputSearchField();
}

class _InputSearchField extends State<InputSearchField>
    with WidgetsBindingObserver {
  //OnTapSearchBox onTapSearchBox;
  //_InputSearchField(this.onTapSearchBox);
  String videoname = "";
  bool needKeyBoard = false;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid && widget.focusNode.hasFocus) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          needKeyBoard = false;
          FocusScope.of(context).requestFocus(widget.boxNode);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        autofocus: true,
        focusColor: Colors.transparent,
        onTap: () {
          needKeyBoard = true;
          FocusScope.of(context).requestFocus(widget.focusNode);
        },
        onFocusChange: (value) {
          setState(() {
            if (value && !needKeyBoard) {
              widget.boxNode.requestFocus();
            }
            selected = value;
          });
        },
        focusNode: widget.boxNode,
        child: TextField(
          autofocus: false,
          focusNode: widget.focusNode,
          //onEditingComplete: widget.onTapSearchBox,
          onChanged: (value) {
            setState(() {
              videoname = value;
            });
          },
          decoration: InputDecoration(
            labelText: "请输入影片名称",
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: selected ? HostPortStorage.themeColor : Colors.grey,
                    width: 3)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: HostPortStorage.themeColor, width: 3)),
            //icon: Icon(Icons.search, size: 20),
          ),
          autocorrect: false,
          enableSuggestions: false,
        ));
  }

  get videoName => videoname;
}

class SearchButton extends StatefulWidget {
  const SearchButton({Key? key, required this.btnNode, required this.name})
      : super(key: key);
  final FocusNode btnNode;
  final String? name;
  @override
  State<SearchButton> createState() => _SearchButton();
}

class _SearchButton extends State<SearchButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (widget.name != "" && widget.name != null) {
          String videoName = widget.name as String;
          GoRouter.of(context).push("/search", extra: videoName);
        }
      },
      autofocus: true,
      shape: const StadiumBorder(),
      color: Colors.grey,
      focusNode: widget.btnNode,
      focusColor: Colors.blue,
      elevation: 4.0,
      focusElevation: 10.0,
      child: const Text(
        "搜索",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class RecommendVideo extends StatefulWidget {
  const RecommendVideo({Key? key}) : super(key: key);
  @override
  State<RecommendVideo> createState() => _RecommendVideo();
}

class _RecommendVideo extends State<RecommendVideo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FetchNewVideoInfo.fetchNewVideoInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            FetchNewVideoInfo.totalfiles != 0) {
          List<Widget> showNewVideo() {
            List<Widget> elements = [];
            for (var i = 0; i < FetchNewVideoInfo.totalfiles; i++) {
              var videoName = FetchNewVideoInfo.newVideoStorage[i]["name"];
              var videoImage = FetchNewVideoInfo.newVideoStorage[i]["imgpath"];
              //var videopath = FetchNewVideoInfo.newVideoStorage[i]["videopath"];
              var element =
                  VideoInfoBlock(imgpath: videoImage, videoName: videoName);
              elements.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: element,
              ));
            }
            return elements;
          }

          return ListView(
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            scrollDirection: Axis.horizontal,
            children: showNewVideo(),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            FetchNewVideoInfo.totalfiles == 0) {
          return Center(
            widthFactor: MediaQuery.of(context).size.width,
            child: const Text(
              "无法连接到服务器",
              style: TextStyle(fontSize: 30),
            ),
          );
        } else {
          return Center(
            widthFactor: MediaQuery.of(context).size.width,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class VideoInfoBlock extends StatefulWidget {
  const VideoInfoBlock(
      {Key? key, required this.imgpath, required this.videoName})
      : super(key: key);
  final String imgpath;
  final String videoName;
  @override
  State<VideoInfoBlock> createState() => _VideoInfoBlock();
}

class _VideoInfoBlock extends State<VideoInfoBlock> {
  bool focusState = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.16,
      child: InkWell(
        autofocus: true,
        onFocusChange: (value) {
          setState(() {
            focusState = value;
          });
        },
        enableFeedback: false,
        borderRadius: BorderRadius.circular(10),
        focusColor: Colors.transparent,
        onTap: () {
          GoRouter.of(context).push("/search", extra: widget.videoName);
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: focusState ? Colors.lightBlue : Colors.transparent,
                  blurRadius:
                      focusState ? MediaQuery.of(context).size.width * 0.02 : 0,
                  spreadRadius:
                      focusState ? MediaQuery.of(context).size.width * 0.01 : 0,
                ),
              ],
              border: Border.all(
                  color: focusState ? Colors.blue : Colors.transparent,
                  width: 3.0)),
          child: Column(
            children: [
              Image.network(
                widget.imgpath,
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.height * 0.5,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Icon(
                        Icons.error,
                        size: MediaQuery.of(context).size.height / 4,
                      ));
                },
              ),
              Text(
                widget.videoName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: MediaQuery.of(context).size.width / 70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.videoName}) : super(key: key);
  final String videoName;
  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SearchVideoInfo.searchResult(widget.videoName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            SearchVideoInfo.searchable) {
          List<Widget> searchResList() {
            List<Widget> eles = [];
            List<dynamic> hostNames = SearchVideoInfo.responseData["hosts"];
            for (var ele in hostNames) {
              var eleData = SearchVideoInfo.responseData[ele];
              String hostName = eleData["station"];
              List searchInfos = eleData["infos"];
              if (searchInfos.isNotEmpty) {
                for (var i = 0; i < searchInfos.length; i++) {
                  var tempItem = ListTile(
                    autofocus: true,
                    title: Text(
                        "$hostName : ${searchInfos[i]['name']}  <${searchInfos[i]['state']}>"),
                    focusColor: Colors.blue,
                    onTap: () {
                      videoTextState.setTempInfo(0, 0);
                      videoBtnState.setTempInfo(0, 0);
                      GoRouter.of(context).replace("/videoinfo", extra: {
                        "url": searchInfos[i]["path"],
                        "stations": ele,
                        "id": 0,
                        "seek": 0,
                      });
                    },
                  );
                  eles.add(tempItem);
                }
              }
            }
            return eles;
          }

          return Scaffold(
            body: ListView(children: searchResList()),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !SearchVideoInfo.searchable) {
          return Scaffold(
            body: Center(
                child: Text("邀请码错误或服务器无法连接",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 50))),
          );
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

class SearchShowPage extends StatefulWidget {
  const SearchShowPage({
    Key? key,
    required this.urlpath,
    required this.stations,
    //required this.videoIndex,
    //required this.seekTimes
  }) : super(key: key);
  final String urlpath;
  final String stations;
  //final int videoIndex;
  //final int seekTimes;
  @override
  State<SearchShowPage> createState() => _SearchShowPage();
}

class _SearchShowPage extends State<SearchShowPage> {
  late Future _futureFunction;
  SearchTansform searchTansform = SearchTansform();

  @override
  void initState() {
    _futureFunction =
        searchTansform.getVideoInfo(widget.urlpath, widget.stations);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureFunction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return searchTansform.videosInfo.isEmpty
              ? Scaffold(
                  body: Center(
                    widthFactor: MediaQuery.of(context).size.width,
                    heightFactor: MediaQuery.of(context).size.height,
                    child: Text(
                      "无法获取视频信息",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 50),
                    ),
                  ),
                )
              : VideoInfoShowContent(
                  station: widget.stations,
                  urlpath: widget.urlpath,
                  searchTansform: searchTansform,
                );
        } else {
          return Center(
            widthFactor: MediaQuery.of(context).size.width,
            heightFactor: MediaQuery.of(context).size.height,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class VideoInfoShowContent extends StatefulWidget {
  const VideoInfoShowContent(
      {Key? key,
      required this.station,
      required this.urlpath,
      required this.searchTansform})
      : super(key: key);
  final String station;
  final String urlpath;
  final SearchTansform searchTansform;
  @override
  State<VideoInfoShowContent> createState() => _VideoInfoShowContent();
}

class _VideoInfoShowContent extends State<VideoInfoShowContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    historyState.setFresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Image.network(
                      widget.searchTansform.videoPic,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Icon(
                            Icons.error,
                            size: MediaQuery.of(context).size.width / 40,
                          ),
                        );
                      },
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width / 100,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.77,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: Center(
                            child: Text(
                              widget.searchTansform.videoTitle,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 50,
                                  color: Colors.white),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                        const Divider(),
                        Text(
                          "年份:${widget.searchTansform.videoYear} 演员:${widget.searchTansform.actors}",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 60,
                              color: Colors.white60),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.26,
                          child: Text(
                            widget.searchTansform.description,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 60,
                                color: Colors.white70),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Text("    "),
                            ContinueVideoButton(
                              //videoIndex: widget.videoIndex,
                              //seekTimes: widget.seekTimes,
                              station: widget.station,
                              urlpath: widget.urlpath,
                              imgPath: widget.searchTansform.videoPic,
                              searchTansform: widget.searchTansform,
                            ),
                            const Text("  "),
                            const TextLabelWidget(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.97,
                child: ChooseVideoBox(
                  station: widget.station,
                  urlpath: widget.urlpath,
                  img: widget.searchTansform.videoPic,
                  searchTansform: widget.searchTansform,
                ),
              ),
            ],
          )),
    );
  }
}

class TextLabelWidget extends StatefulWidget {
  const TextLabelWidget({Key? key}) : super(key: key);
  @override
  State<TextLabelWidget> createState() => _TextLabelWidget();
}

class _TextLabelWidget extends State<TextLabelWidget> {
  void _refreshListen() {
    if (videoTextState.setTextState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        videoTextState.hasTextRefreshed();
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    videoTextState.hasTextRefreshed();
    videoTextState.addListener(_refreshListen);
    super.initState();
  }

  @override
  void dispose() {
    videoTextState.hasTextRefreshed();
    videoTextState.removeListener(_refreshListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "从第${(videoTextState.videoIndex + 1).toString().padLeft(3, ' ')}集 ${(videoTextState.seekTime / 60000).floor().toString().padLeft(3, ' ')}:${((videoTextState.seekTime / 1000) % 60).floor().toString().padLeft(2, '0')}处播放",
      style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: MediaQuery.of(context).size.width / 65),
    );
  }
}

class ChooseVideoBox extends StatefulWidget {
  const ChooseVideoBox(
      {Key? key,
      required this.station,
      required this.urlpath,
      required this.img,
      required this.searchTansform})
      : super(key: key);
  final String station;
  final String urlpath;
  final String img;
  final SearchTansform searchTansform;
  @override
  State<ChooseVideoBox> createState() => _ChooseVideoBox();
}

class _ChooseVideoBox extends State<ChooseVideoBox> {
  @override
  Widget build(BuildContext context) {
    List<Row> videosBox() {
      List<Widget> rowitems = [];
      List<Row> videoBox = [];
      int count = 0;
      int lengitems = widget
          .searchTansform.videosInfo.length; //SearchTansform.videosInfo.length;
      for (var i = 0; i < lengitems; i++) {
        count += 1;
        rowitems.add(ChooseVideoButton(
          id: i,
          label: widget.searchTansform.videosInfo[i]["label"],
          path: widget.searchTansform.videosInfo[i]["m3u8"],
          station: widget.station,
          urlpath: widget.urlpath,
          imgpath: widget.searchTansform.videoPic,
          searchTansform: widget.searchTansform,
        ));
        if (count == 7 || i == (lengitems - 1)) {
          videoBox.add(Row(
            children: rowitems,
          ));
          rowitems = [];
          count = 0;
        }
      }
      return videoBox;
    }

    return ListView(
      children: videosBox(),
    );
  }
}

class ContinueVideoButton extends StatefulWidget {
  const ContinueVideoButton(
      {Key? key,
      //required this.videoIndex,
      //required this.seekTimes,
      required this.station,
      required this.urlpath,
      required this.imgPath,
      required this.searchTansform})
      : super(key: key);
  //final int videoIndex;
  //final int seekTimes;
  final SearchTansform searchTansform;
  final String station;
  final String urlpath;
  final String imgPath;
  @override
  State<ContinueVideoButton> createState() => _ContinueVideoButton();
}

class _ContinueVideoButton extends State<ContinueVideoButton> {
  bool selected = false;
  final FocusNode _focusNode = FocusNode();

  void _refreshBtnListen() {
    if (videoBtnState.setBtnBool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //_btnLabelGet();
        videoBtnState.hasBtnRefreshed();
        setState(() {
          _focusNode.requestFocus();
        });
      });
    }
  }

  @override
  void initState() {
    //_btnLabelGet();
    videoBtnState.hasBtnRefreshed();
    videoBtnState.addListener(_refreshBtnListen);
    super.initState();
  }

  @override
  void dispose() {
    videoBtnState.removeListener(_refreshBtnListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width / 250),
      child: InkWell(
        focusNode: _focusNode,
        autofocus: true,
        onFocusChange: (value) {
          setState(() {
            selected = value;
          });
        },
        onTap: () {
          GoRouter.of(context).push("/mediaPlayer", extra: {
            "path": widget.searchTansform.videosInfo[videoBtnState.videoIndexs]
                ["m3u8"],
            "start": videoBtnState.seekTime,
            "id": videoBtnState.videoIndexs,
            "station": widget.station,
            "urlpath": widget.urlpath,
            "imgpath": widget.imgPath,
            "search": widget.searchTansform,
          });
        },
        focusColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.deepOrange,
            boxShadow: [
              BoxShadow(
                color: selected ? Colors.lightBlue : Colors.transparent,
                blurRadius:
                    selected ? MediaQuery.of(context).size.width * 0.01 : 0,
                spreadRadius:
                    selected ? MediaQuery.of(context).size.width * 0.005 : 0,
              ),
            ],
            border: Border.all(
                width: 2, color: selected ? Colors.white : Colors.transparent),
          ),
          width: MediaQuery.of(context).size.width * 0.13,
          height: MediaQuery.of(context).size.height * 0.08,
          child: Center(
            child: Text(
              (videoBtnState.seekTime == 0 && videoBtnState.videoIndexs == 0)
                  ? "立刻播放"
                  : "继续播放",
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 65),
            ),
          ),
        ),
      ),
    );
  }
}

class ChooseVideoButton extends StatefulWidget {
  const ChooseVideoButton(
      {Key? key,
      required this.id,
      required this.label,
      required this.path,
      required this.station,
      required this.urlpath,
      required this.imgpath,
      required this.searchTansform})
      : super(key: key);
  final int id;
  final String label;
  final String path;
  final String station;
  final String urlpath;
  final String imgpath;
  final SearchTansform searchTansform;
  @override
  State<ChooseVideoButton> createState() => _ChooseVideoButton();
}

class _ChooseVideoButton extends State<ChooseVideoButton> {
  bool choosen = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width / 240),
      child: InkWell(
        autofocus: true,
        onTap: () {
          GoRouter.of(context).push("/mediaPlayer", extra: {
            "path": widget.path,
            "start": 1,
            "id": widget.id,
            "station": widget.station,
            "urlpath": widget.urlpath,
            "imgpath": widget.imgpath,
            "search": widget.searchTansform
          });
        },
        onFocusChange: (value) {
          setState(() {
            choosen = value;
          });
        },
        focusColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  color: choosen ? Colors.lightBlue : Colors.transparent,
                  blurRadius:
                      choosen ? MediaQuery.of(context).size.width * 0.01 : 0,
                  spreadRadius:
                      choosen ? MediaQuery.of(context).size.width * 0.005 : 0,
                ),
              ],
              border: Border.all(
                width: 2.0,
                color: choosen ? Colors.white : Colors.transparent,
              )),
          width: MediaQuery.of(context).size.width * 0.13,
          height: MediaQuery.of(context).size.height * 0.09,
          child: Center(
            child: Text(
              widget.label,
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 65),
            ),
          ),
        ),
      ),
    );
  }
}
