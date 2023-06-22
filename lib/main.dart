import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_old_ver/controlpage.dart';
import 'package:tv_old_ver/invitepage.dart';
import 'package:tv_old_ver/secretpage.dart';
import 'package:tv_old_ver/touch/invitatepage.dart';
import 'package:tv_old_ver/touch/secretpage.dart';
import 'package:tv_old_ver/touch/settingpage.dart';
import 'package:tv_old_ver/touch/videopage.dart';
import 'package:tv_old_ver/video/requestinfo.dart';
import 'package:tv_old_ver/video_state.dart';
import 'homepage.dart';
import 'livetv/tvpage.dart';
import 'video/videopage.dart';
import './history/historypage.dart';
import './video_player.dart';
import 'package:provider/provider.dart';
import 'setting.dart';
import 'infopage.dart';
import './video/videorecom.dart';

class GloblaHttpOvrride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  HttpOverrides.global = GloblaHttpOvrride();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => VideoTextState()),
        Provider(create: (_) => VideoBtnState()),
        Provider(create: (_) => HistoryState()),
      ],
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
        },
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //Provider.of<ServerProvinder>(context).initData();
    return MaterialApp.router(
      title: "彩云影视",
      routerConfig: _router,
      theme: ThemeData.dark(useMaterial3: true),
      //themeMode: ThemeMode.dark,
      //darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: "/main",
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: "/tvlive",
        builder: (context, state) => const TVPlayerBody(),
      ),
      GoRoute(
        path: "/videos",
        builder: (context, state) => const VideoOrderPage(),
      ),
      GoRoute(
        path: "/search",
        builder: (context, state) {
          return SearchPage(videoName: state.extra.toString());
        },
      ),
      GoRoute(
        path: "/videoinfo",
        builder: (context, state) {
          var inputEle = Map.from(state.extra as Map<String, dynamic>);
          return SearchShowPage(
            urlpath: inputEle['url'],
            stations: inputEle['stations'],
            //videoIndex: inputEle['id'],
            //seekTimes: inputEle['seek'],
          );
        },
      ),
      GoRoute(
        path: "/mediaPlayer",
        builder: (context, state) {
          var inputElement = Map.from(state.extra as Map<String, dynamic>);
          return PlayerVideosPage(
            videopath: inputElement["path"]! as String,
            startpoint: inputElement["start"]! as int,
            id: inputElement["id"]! as int,
            station: inputElement["station"]! as String,
            urlpath: inputElement["urlpath"]! as String,
            imgpath: inputElement["imgpath"]! as String,
            searchTansform: inputElement["search"]! as SearchTansform,
          );
        },
      ),
      GoRoute(
        path: "/history",
        builder: (context, state) {
          return const HistoryPage();
        },
      ),
      GoRoute(
        path: "/netset",
        builder: (context, state) {
          return const SettingPage();
        },
      ),
      GoRoute(
        path: "/infopage",
        builder: (context, state) {
          return const InfoPage();
        },
      ),
      GoRoute(
        path: "/videoreomm",
        builder: (context, state) {
          return const VideoRecommPage();
        },
      ),
      GoRoute(
        path: "/invite",
        builder: (context, state) {
          return const InvitationPage();
        },
      ),
      GoRoute(
        path: "/secretCode",
        builder: (context, state) {
          return const SecretPage();
        },
      ),
      GoRoute(
        path: "/setting",
        builder: (context, state) {
          return const ControlPage();
        },
      ),
      // 触摸优化
      GoRoute(
        path: "/inviteTouch",
        builder: (context, state) {
          return const InvitationPageTouch();
        },
      ),
      GoRoute(
        path: "/secretTouch",
        builder: (context, state) {
          return const SecretPageTouch();
        },
      ),
      GoRoute(
        path: "/settingTouch",
        builder: (context, state) {
          return const SettingPageTouch();
        },
      ),
      GoRoute(
        path: "/videopageTouch",
        builder: (context, state) {
          return const VideoOrderPageTouch();
        },
      )
    ],
    initialLocation: "/main",
  );
}
