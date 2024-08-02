import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/product.dart';
import '../cubit/cart_cubit.dart';

class WidgetVerticalListCart extends StatelessWidget {
  final Map<Product, GlobalKey> cartItemKeys;
  final ScrollController scrollController;

  const WidgetVerticalListCart({
    super.key,
    required this.cartItemKeys,
    required this.scrollController,
  });

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
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        if (state.status == CartStatus.empty) {
                          return const SizedBox.shrink();
                        }
                        return AnimatedList(
                          controller: scrollController,
                          initialItemCount: state.cartItems.length,
                          itemBuilder: (context, index, animation) {
                            final product = state.cartItems[index];
                            return Container(
                              height: 80,
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Hero(
                                    tag: 'product_${product.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        cacheKey: product.image,
                                        imageUrl: product.image,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                        placeholder: (context, url) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Produto ${product.id}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
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
