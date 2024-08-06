import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import '../../../model/cart_item.dart';
import '../../../model/product.dart';

class AppWidgetCartBottomController {
  final BuildContext context;

  final double minProportionalExtent = 0.0;
  final double middleProportionalExtent = 0.17;
  final double maxProportionalExtent = 0.9;

  final GlobalKey cartKey = GlobalKey();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  final SheetController sheetController = SheetController();
  final HeroController heroController;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final Map<Product, GlobalKey> cartItemKeys = {};
  final ScrollController scrollController = ScrollController();
  final List<OverlayEntry> overlayEntries = [];
  final List<AnimationController> listOfControllersAnimationsOverlay = [];
  final Set<Product> animatingItems = {};

  Offset imageOffset = Offset.zero;
  Offset targetOffset = Offset.zero;

  ValueNotifier<double> valueNotifierCurrentExtent = ValueNotifier(0.2);
  double get currentExtent => valueNotifierCurrentExtent.value;
  // double currentExtent = 0.2;

  AppWidgetCartBottomController(this.context)
      : heroController =
            HeroController(createRectTween: (Rect? begin, Rect? end) => MaterialRectArcTween(begin: begin, end: end)) {
    sheetController.addListener(() {
      final metrics = sheetController.value;
      valueNotifierCurrentExtent.value = metrics.pixels / metrics.maxPixels;

      if (currentExtent > 0.4) {
        if (!_isVerticalListRouteActive()) {
          navigatorKey.currentState?.pushNamed("/vertical");
        }
      } else {
        if (_isVerticalListRouteActive()) {
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      }
    });
  }

  void dispose() {
    heroController.dispose();
    sheetController.dispose();
  }

  bool _isVerticalListRouteActive() => navigatorKey.currentState?.canPop() ?? false;

  bool get isVisible => currentExtent > 0.1;

  bool get isNotVisible => currentExtent < 0.1;

  Future<void> max() async {
    sheetController.animateTo(
      Extent.proportional(maxProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> hide() async {
    while (overlayEntries.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await sheetController.animateTo(
      Extent.pixels(middleProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> show() async {
    sheetController.animateTo(
      Extent.proportional(middleProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> toggle() async {
    if (isNotVisible) {
      await show();
    } else {
      await hide();
    }
  }

  Future<void> addItemToCart({
    required TickerProvider vsync,
    required List<CartItem> cartItems,
    required Product product,
    required String tag,
  }) async {
    if (animatingItems.contains(product)) return;

    final productContext = product.getGlobalKey(tag).currentContext;
    final cartContext = cartKey.currentContext;
    final screenFrameContext = context;

    if (productContext != null && cartContext != null) {
      RenderBox productRenderBox = productContext.findRenderObject() as RenderBox;
      final RenderBox deviceFrameRenderBox = screenFrameContext.findRenderObject() as RenderBox;

      imageOffset = productRenderBox.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox);
      final RenderBox cartRenderBox = cartContext.findRenderObject() as RenderBox;

      if (cartItems.any((element) => element.product == product)) {
        var cartItem = cartItemKeys[product]!;

        if (cartItem.currentContext == null) {
          final itemIndex = cartItems.indexWhere((element) => element.product == product);
          final targetPosition = (itemIndex * 50.0).clamp(0.0, scrollController.position.maxScrollExtent);
          await scrollController.animateTo(targetPosition,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          cartItem = cartItemKeys[product]!;
        }

        await _scrollToItem(cartItem);

        targetOffset = (cartItem.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox) ??
            targetOffset;

        await _animateItemToCart(vsync, product, productRenderBox);
      } else {
        if (cartItems.isNotEmpty) {
          if (scrollController.offset != 0) {
            await scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
        cartItemKeys[product] = GlobalKey();
        animatingItems.add(product);

        listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
        await Future.delayed(const Duration(milliseconds: 310));

        targetOffset = cartRenderBox.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox);
        targetOffset = (targetOffset + const Offset(10.0, 10.0));

        await _animateItemToCart(vsync, product, productRenderBox);
      }
    }
  }

  Future<void> _scrollToItem(GlobalKey key) async {
    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(context,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit);
    }
  }

  Future<void> _animateItemToCart(
    TickerProvider vsync,
    Product product,
    RenderBox productRenderBox,
  ) async {
    final controller = AnimationController(duration: const Duration(milliseconds: 2300), vsync: vsync);

    final offsetAnimation = Tween<Offset>(begin: imageOffset, end: targetOffset)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final sizeAnimation = Tween<double>(begin: productRenderBox.size.width, end: 50)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: offsetAnimation,
        builder: (context, child) {
          return Positioned(
            left: offsetAnimation.value.dx,
            top: offsetAnimation.value.dy,
            child: AnimatedBuilder(
              animation: sizeAnimation,
              builder: (context, child) {
                return ClipSmoothRect(
                  radius: const SmoothBorderRadius.all(
                    SmoothRadius(
                      cornerRadius: 18,
                      cornerSmoothing: 1,
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    width: sizeAnimation.value,
                    height: sizeAnimation.value,
                    placeholder: (context, url) => const SizedBox.shrink(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );

    overlayEntries.add(overlayEntry);
    Overlay.of(context).insert(overlayEntry);
    listOfControllersAnimationsOverlay.add(controller);

    sizeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final entryIndex = overlayEntries.indexOf(overlayEntry);
        if (entryIndex != -1) {
          overlayEntries[entryIndex].remove();
          overlayEntries.removeAt(entryIndex);
        }
        controller.dispose();
        listOfControllersAnimationsOverlay.remove(controller);
        animatingItems.remove(product);
      }
    });

    await controller.forward();
  }

  void updateCartItemKeys(List<CartItem> cartItems) {
    if (cartItems.isEmpty) return;

    cartItemKeys.clear();
    for (final item in cartItems) {
      cartItemKeys[item.product] = GlobalKey();
    }
  }
}
