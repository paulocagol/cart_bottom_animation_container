import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/product.dart';
import '../widget/cart/bloc/cart_widget_bloc.dart';

class ProductScreen extends StatefulWidget {
  static const routeName = '/product';

  const ProductScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: '${widget.product.id}-hero',
              child: ClipSmoothRect(
                radius: const SmoothBorderRadius.all(
                  SmoothRadius(
                    cornerRadius: 22,
                    cornerSmoothing: 1,
                  ),
                ),
                child: CachedNetworkImage(
                  cacheKey: widget.product.image,
                  imageUrl: widget.product.image,
                  fit: BoxFit.cover,
                  height: 300,
                  width: 300,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  key: widget.product.getGlobalKey('productScreen'),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.product.description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            Text(
              'R\$ ${widget.product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartWidgetBloc>().add(CartWidgetAddEvent(
                        product: widget.product,
                        quantity: 1,
                        vsync: this,
                        tag: 'productScreen',
                      ));
                },
                child: const Text('Add to cart'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
