import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/video/requestinfo.dart';

class VideoRecommPage extends StatefulWidget {
  const VideoRecommPage({Key? key}) : super(key: key);
  @override
  State<VideoRecommPage> createState() => _VideoRecommPage();
}

class _VideoRecommPage extends State<VideoRecommPage> {
  int pageIndex = 0;
  bool film = false;
  bool drama = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PageButton(
                  clickPage: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  label: "电影",
                  index: pageIndex,
                  id: 0,
                ),
                PageButton(
                  clickPage: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  label: "电视剧",
                  index: pageIndex,
                  id: 1,
                ),
              ],
            ),
          )),
          const VerticalDivider(
            thickness: 2,
            color: Colors.white,
          ),
          Expanded(flex: 8, child: RecommBody(index: pageIndex)),
        ],
      ),
    ));
  }
}

typedef ClickPage = dynamic Function();

class PageButton extends StatefulWidget {
  const PageButton(
      {Key? key,
      required this.clickPage,
      required this.label,
      required this.index,
      required this.id})
      : super(key: key);
  final ClickPage? clickPage;
  final String label;
  final int index;
  final int id;
  @override
  State<PageButton> createState() => _PageButton();
}

class _PageButton extends State<PageButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        autofocus: true,
        onFocusChange: (value) {
          setState(() {
            focused = value;
          });
        },
        onPressed: widget.clickPage,
        child: Text(
          widget.label,
          style: TextStyle(
              color: (widget.index == widget.id)
                  ? Colors.blue
                  : focused
                      ? Colors.white
                      : Colors.white54,
              fontSize: MediaQuery.of(context).size.width / 45),
        ));
  }
}

class RecommBody extends StatefulWidget {
  const RecommBody({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  State<RecommBody> createState() => _RecommBody();
}

class _RecommBody extends State<RecommBody> {
  NewVideoFetch newVideoFetch = NewVideoFetch();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: newVideoFetch.getVideoRecomInfos(widget.index),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Widget> getListTiles() {
            List<Widget> res = [];
            List<Widget> temp = [];
            for (var i = 0; i < newVideoFetch.videosRecom.length; i++) {
              var recom = newVideoFetch.videosRecom[i];
              temp.add(VideoItem(
                  rate: recom["rate"],
                  title: recom["title"],
                  img: recom["img"]));
              if ((i + 1) % 5 == 0) {
                res.add(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: temp,
                ));
                res.add(Divider(
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.height / 80,
                ));
                temp = [];
              }
              if ((i + 1) == newVideoFetch.videosRecom.length) {
                var lefted = 5 - (newVideoFetch.videosRecom.length % 5);
                if (lefted < 5) {
                  for (var j = 0; j < lefted; j++) {
                    temp.add(SizedBox(
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.height * 0.38,
                      child: const Text(""),
                    ));
                  }
                  res.add(Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: temp,
                  ));
                  temp = [];
                }
              }
            }
            return res;
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height,
            child: ListView(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              children: getListTiles(),
            ),
          );
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class VideoItem extends StatefulWidget {
  const VideoItem(
      {Key? key, required this.rate, required this.title, required this.img})
      : super(key: key);
  final String rate;
  final String title;
  final String img;
  @override
  State<VideoItem> createState() => _VideoItem();
}

class _VideoItem extends State<VideoItem> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.16,
      height: MediaQuery.of(context).size.height * 0.38,
      child: InkWell(
        autofocus: true,
        onTap: () {
          GoRouter.of(context).push("/search", extra: widget.title);
        },
        onFocusChange: (value) {
          setState(() {
            selected = value;
          });
        },
        focusColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(
                color: selected ? Colors.lightBlue : Colors.transparent,
                width: 2.0),
            boxShadow: [
              BoxShadow(
                color: selected ? Colors.lightBlue : Colors.transparent,
                blurRadius:
                    selected ? MediaQuery.of(context).size.width * 0.02 : 0,
                spreadRadius:
                    selected ? MediaQuery.of(context).size.width * 0.01 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.network(
                widget.img,
                width: MediaQuery.of(context).size.width * 0.13,
                height: MediaQuery.of(context).size.height * 0.3,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.13,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Icon(
                      Icons.error,
                      size: MediaQuery.of(context).size.height / 4,
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: Text(
                    widget.rate,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: MediaQuery.of(context).size.width / 60),
                  )),
                  Expanded(
                      flex: 4,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 60),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
