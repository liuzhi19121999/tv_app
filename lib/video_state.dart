import 'package:flutter/material.dart';

VideoTextState videoTextState = VideoTextState();
VideoBtnState videoBtnState = VideoBtnState();
HistoryState historyState = HistoryState();

class VideoTextState extends ChangeNotifier {
  int seekTimes = 0;
  int videoIndex = 0;
  bool setTextBool = false;

  void setTempInfo(int seekTime, int index) {
    seekTimes = seekTime;
    videoIndex = index;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void needRefresh() {
    setTextBool = true;
    //setButtonBool = true;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void hasTextRefreshed() {
    setTextBool = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  int get seekTime => seekTimes;
  int get videoIndexs => videoIndex;
  bool get setTextState => setTextBool;
}

class VideoBtnState extends ChangeNotifier {
  int seekTimes = 0;
  int videoIndex = 0;
  bool setBtnBool = false;

  void setTempInfo(int seekTime, int index) {
    seekTimes = seekTime;
    videoIndex = index;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void needRefresh() {
    //setTextBool = true;
    setBtnBool = true;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void hasBtnRefreshed() {
    setBtnBool = false;
    if (hasListeners) {
      notifyListeners();
    }
  }

  int get seekTime => seekTimes;
  int get videoIndexs => videoIndex;
  bool get setBtnState => setBtnBool;
}

class HistoryState extends ChangeNotifier {
  bool needRefresh = false;
  List<dynamic> historyInfos = [];
  void setFresh() {
    needRefresh = true;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void setFreshed() {
    if (needRefresh) {
      needRefresh = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  void setHistory(List<dynamic> infos) {
    historyInfos = infos;
    if (hasListeners) {
      notifyListeners();
    }
  }

  bool get refreshState => needRefresh;
  List<dynamic> get historyInfo => historyInfos;
}
