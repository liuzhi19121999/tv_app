import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/datastore/dataserver.dart';
import 'package:tv_old_ver/video/requestinfo.dart';

class VideoOrderPageTouch extends StatefulWidget {
  const VideoOrderPageTouch({Key? key}) : super(key: key);
  @override
  State<VideoOrderPageTouch> createState() => _VideoOrderPageTouch();
}

class _VideoOrderPageTouch extends State<VideoOrderPageTouch> {
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
  GlobalKey<_InputSearchFieldTouch> videos = GlobalKey();
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
                    child: InputSearchFieldTouch(
                      key: videos,
                    )),
                Expanded(
                    flex: 1,
                    child: Center(
                      widthFactor: MediaQuery.of(context).size.width / 4,
                      child: SearchButton(
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
class InputSearchFieldTouch extends StatefulWidget {
  const InputSearchFieldTouch({
    Key? key,
    //required this.onTapSearchBox,
  }) : super(key: key);
  //final OnTapSearchBox? onTapSearchBox;
  @override
  State<InputSearchFieldTouch> createState() => _InputSearchFieldTouch();
}

class _InputSearchFieldTouch extends State<InputSearchFieldTouch> {
  //OnTapSearchBox onTapSearchBox;
  //_InputSearchField(this.onTapSearchBox);
  String videoname = "";

  @override
  Widget build(BuildContext context) {
    return TextField(
      //autofocus: true,
      //onEditingComplete: widget.onTapSearchBox,
      onChanged: (value) {
        videoname = value;
      },
      decoration: InputDecoration(
        labelText: "请输入影片名称",
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 3)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: HostPortStorage.themeColor, width: 3)),
        //icon: Icon(Icons.search, size: 20),
      ),
    );
  }

  get videoName => videoname;
}

class SearchButton extends StatefulWidget {
  const SearchButton({Key? key, required this.name}) : super(key: key);
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
      //autofocus: true,
      shape: const StadiumBorder(),
      color: Colors.grey,
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
        //autofocus: true,
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
