import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_widget_bloc.dart';

class WidgetHorizontalListCart extends StatelessWidget {
  const WidgetHorizontalListCart({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return BlocConsumer<CartWidgetBloc, CartWidgetState>(
            listener: (context, state) {
              // final visibilityState = state.visibilityState;
              // final animationState = state.animationState;
              final statusState = state.statusState;

              if (statusState is CartWidgetErrorState) {
                context.read<CartWidgetBloc>().add(CartWidgetShowErrorEvent(
                      context: context,
                      error: statusState.error,
                    ));
              }
            },
            builder: (context, state) {
              // final visibilityState = state.visibilityState;
              // final animationState = state.animationState;
              final operationState = state.operationState;

              if (operationState is CartWidgetLoadingState) {
                return const CircularProgressIndicator.adaptive();
              }

              // if (operationState is CartWidgetErrorState) {
              //   return Text('Erro ao carregar o carrinho ${operationState.error}');
              // }

              if (operationState is CartWidgetLoadedState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: constraints.maxWidth,
                      decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(16))),
                      child: SizedBox(
                        key: context.read<CartWidgetBloc>().screenController.cartKey,
                        height: double.infinity,
                        width: double.infinity,
                        child: AnimatedList(
                          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                          key: context.read<CartWidgetBloc>().screenController.listKey,
                          controller: context.read<CartWidgetBloc>().screenController.scrollController,
                          scrollDirection: Axis.horizontal,
                          initialItemCount: operationState.items.length,
                          itemBuilder: (context, index, animation) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: Opacity(
                                  opacity: context
                                          .read<CartWidgetBloc>()
                                          .screenController
                                          .animatingItems
                                          .contains(operationState.items[index].product)
                                      ? 0
                                      : 1,
                                  child: Hero(
                                    tag: 'product_${operationState.items[index].product.id}',
                                    child: ClipSmoothRect(
                                      key: context
                                          .read<CartWidgetBloc>()
                                          .screenController
                                          .cartItemKeys[operationState.items[index].product],
                                      radius: const SmoothBorderRadius.all(
                                        SmoothRadius(
                                          cornerRadius: 18,
                                          cornerSmoothing: 1,
                                        ),
                                      ),
                                      child: CachedNetworkImage(
                                        cacheKey: operationState.items[index].product.image,
                                        imageUrl: operationState.items[index].product.image,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        placeholder: (context, url) => const SizedBox.shrink(),
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
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      alignment: Alignment.topCenter,
                      height: constraints.maxHeight - 70,
                      width: constraints.maxWidth,
                      child: Text(
                        'Total R\$ ${operationState.items.fold(
                              0.0,
                              (sum, item) => sum + item.product.price * item.quantity,
                            ).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
