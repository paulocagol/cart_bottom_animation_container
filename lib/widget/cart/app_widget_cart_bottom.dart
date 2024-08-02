import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/product.dart';
import 'controller/app_widget_cart_bottom_controller.dart';
import 'cubit/cart_cubit.dart';
import 'widget/widget_background_container.dart';
import 'widget/widget_draggable_cart_sheet.dart';

class AppWidgetCartBottom extends StatefulWidget {
  const AppWidgetCartBottom({super.key, required this.child});

  final Widget child;

  @override
  State<AppWidgetCartBottom> createState() => AppWidgetCartBottomState();

  static AppWidgetCartBottomState of(BuildContext context) {
    final AppWidgetCartBottomState? result = context.findAncestorStateOfType<AppWidgetCartBottomState>();
    assert(result != null, 'No AppWidgetCartBottomState found in context');
    return result!;
  }
}

class AppWidgetCartBottomState extends State<AppWidgetCartBottom> with TickerProviderStateMixin {
  late final AppWidgetCartBottomController _controller;

  Future<void> toggle() async => await _controller.toggle();

  Future<void> show() async => await _controller.show();

  Future<void> max() async => await _controller.max();

  Future<void> hide() async => await _controller.hide();

  Future<void> addItemToCart({required Product product, required String tag}) async =>
      await _controller.addItemToCart(product: product, tag: tag);

  Future<void> removeItemFromCart({required Product product}) async =>
      await _controller.removeItemFromCart(product: product);

  @override
  void initState() {
    super.initState();
    _controller = AppWidgetCartBottomController(context: context, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        _controller.updateCartItemKeys(state);
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            WidgetBackgroundContainer(controller: _controller, child: widget.child),
            WidgetDraggableSheet(controller: _controller),
          ],
        ),
      ),
    );
  }
}
