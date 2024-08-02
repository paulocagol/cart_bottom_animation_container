import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../model/product.dart';

class WidgetCartItem extends StatelessWidget {
  final Product product;
  final Animation<double> sizeAnimation;
  final Animation<Offset> offsetAnimation;

  const WidgetCartItem({
    super.key,
    required this.product,
    required this.sizeAnimation,
    required this.offsetAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Positioned(
          left: offsetAnimation.value.dx,
          top: offsetAnimation.value.dy,
          child: AnimatedBuilder(
            animation: sizeAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  cacheKey: product.image,
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
    );
  }
}
