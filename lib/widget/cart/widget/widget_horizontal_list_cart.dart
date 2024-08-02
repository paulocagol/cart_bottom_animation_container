import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_widget_cart_bottom.dart';
import '../controller/app_widget_cart_bottom_controller.dart';
import '../cubit/cart_cubit.dart';

class WidgetHorizontalListCart extends StatelessWidget {
  final AppWidgetCartBottomController controller;

  const WidgetHorizontalListCart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return BlocConsumer<CartCubit, CartState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: constraints.maxWidth,
                    decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(16))),
                    child: SizedBox(
                      key: controller.cartKey,
                      height: double.infinity,
                      width: double.infinity,
                      child: AnimatedList(
                        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        key: controller.listKey,
                        controller: controller.scrollController,
                        scrollDirection: Axis.horizontal,
                        initialItemCount: state.cartItems.length,
                        itemBuilder: (context, index, animation) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              child: GestureDetector(
                                onLongPress: () {
                                  AppWidgetCartBottom.of(context).removeItemFromCart(product: state.cartItems[index]);
                                },
                                child: Opacity(
                                  opacity: 1,
                                  // opacity: animatingItems.contains(product) ? 0 : 1,
                                  child: Hero(
                                    tag: 'product_${state.cartItems[index].id}',
                                    child: ClipSmoothRect(
                                      key: controller.cartItemKeys[state.cartItems[index]],
                                      radius: const SmoothBorderRadius.all(
                                        SmoothRadius(
                                          cornerRadius: 18,
                                          cornerSmoothing: 1,
                                        ),
                                      ),
                                      child: CachedNetworkImage(
                                        cacheKey: state.cartItems[index].image,
                                        imageUrl: state.cartItems[index].image,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        placeholder: (context, url) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      for (int i = state.cartItems.length - 1; i >= 0; i--) {
                        controller.listKey.currentState?.removeItem(
                          i,
                          (context, animation) => SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: Colors.redAccent,
                              child: const Text(
                                'Removing...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          duration: const Duration(milliseconds: 300),
                        );
                        controller.cartItemKeys.remove(state.cartItems[i]);
                      }
                      context.read<CartCubit>().clearCart();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 10),
                      alignment: Alignment.topCenter,
                      height: constraints.maxHeight - 70,
                      width: constraints.maxWidth,
                      child: Text(
                        'Total R\$ ${state.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
