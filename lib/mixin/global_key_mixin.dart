import 'package:flutter/widgets.dart';

mixin GlobalKeyMixin<T> {
  final GlobalKey _globalKey = GlobalKey();

  GlobalKey get globalKey => _globalKey;
}