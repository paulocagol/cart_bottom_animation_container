import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_widget_bloc.dart';

class WidgetVerticalListCart extends StatelessWidget {
  const WidgetVerticalListCart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              height: 50,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produtos 10',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total R\$ 750,00',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 18.0,
              left: 18.0,
              right: 18.0,
            ),
            height: MediaQuery.of(context).size.height - 110,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    child: BlocBuilder<CartWidgetBloc, CartWidgetState>(
                      builder: (context, state) {
                        // final visibilityState = state.visibilityState;
                        // final animationState = state.animationState;
                        final operationState = state.operationState;

                        if (operationState is CartWidgetLoadingState) {
                          return const CircularProgressIndicator.adaptive();
                        }

                        if (operationState is CartWidgetErrorState) {
                          return Text('Erro ao carregar o carrinho ${operationState.error}');
                        }

                        if (operationState is CartWidgetLoadedState) {
                          return AnimatedList(
                            controller: context.read<CartWidgetBloc>().controller.scrollController,
                            initialItemCount: operationState.items.length,
                            itemBuilder: (context, index, animation) {
                              final item = operationState.items[index];
                              return Container(
                                height: 80,
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Hero(
                                      tag: 'product_${item.product.id}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          cacheKey: item.product.image,
                                          imageUrl: item.product.image,
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                          placeholder: (context, url) => const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Produto ${item.product.id}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
