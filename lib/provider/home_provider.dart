import 'package:flutter/material.dart';

class HomeScreenProvider extends ChangeNotifier {
  static final HomeScreenProvider _instance = HomeScreenProvider._internal();
  factory HomeScreenProvider() => _instance;
  HomeScreenProvider._internal();

  int _currentIndex = 1;

  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
