import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cart_widget_bloc.dart';
import 'widget/widget_background_container.dart';
import 'widget/widget_draggable_cart_sheet.dart';

class AppWidgetCartBottom extends StatefulWidget {
  const AppWidgetCartBottom({super.key, required this.child});

  final Widget child;

  @override
  State<AppWidgetCartBottom> createState() => AppWidgetCartBottomState();

  // static AppWidgetCartBottomState of(BuildContext context) {
  //   final AppWidgetCartBottomState? result = context.findAncestorStateOfType<AppWidgetCartBottomState>();
  //   assert(result != null, 'No AppWidgetCartBottomState found in context');
  //   return result!;
  // }
}

class AppWidgetCartBottomState extends State<AppWidgetCartBottom> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartWidgetBloc>().add(CartWidgetLoadEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          WidgetBackgroundContainer(child: widget.child),
          const WidgetDraggableSheet(),
        ],
      ),
    );
  }
}
