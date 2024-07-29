import 'package:cached_network_image/cached_network_image.dart';
import 'package:cart_bottom_animation_container/widget/cart/app_widget_cart_bottom.dart';
import 'package:flutter/material.dart';

import '../model/product.dart';

class ProductScreen extends StatelessWidget {
  static const routeName = '/product';

  const ProductScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AppWidgetCartBottom(
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: '${product.id}-hero',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    cacheKey: product.image,
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                    placeholder: (context, url) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                product.description,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Text(
                '\$${product.price}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () async {
                    AppWidgetCartBottom.of(context).show().then(
                      (value) {
                        AppWidgetCartBottom.of(context).hide();
                      },
                    );
                  },
                  child: const Text('Add to cart'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
