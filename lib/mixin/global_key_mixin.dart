import 'package:flutter/widgets.dart';

/// Mixin que permite gerar GlobalKeys para cada objeto.
/// ```dart
/// class MyClass with GlobalKeyMixin {
///   final String id;
///   MyClass(this.id);
/// }
/// ```
mixin GlobalKeyMixin {
  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};

  /// Retorna ou cria um GlobalKey com a tag informada.
  /// ```dart
  /// final myClass = MyClass('my-id');
  /// final globalKey = myClass.getGlobalKey('my-id');
  ///
  /// Container(
  ///   key: globalKey,
  ///   child: Text('MyClass'),
  /// )
  /// ```
  GlobalKey<State<StatefulWidget>> getGlobalKey(String tag) {
    if (!_globalKeys.containsKey(tag)) {
      _globalKeys[tag] = GlobalKey<State<StatefulWidget>>(debugLabel: tag);
    }
    return _globalKeys[tag]!;
  }
}
