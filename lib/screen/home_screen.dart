import 'package:cached_network_image/cached_network_image.dart';
import 'package:cart_bottom_animation_container/widget/cart/app_widget_cart_bottom.dart';
import 'package:flutter/material.dart';

import '../model/product.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Product> _listOfProducts = List.generate(
      10,
      (index) => Product(
            id: index.toString(),
            name: 'Product $index',
            description: 'Description of product $index',
            image: 'https://picsum.photos/200/300?random=$index',
            price: index.toDouble(),
          ));

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (AppWidgetCartBottom.of(context).isNotVisible) {
      AppWidgetCartBottom.of(context).show();
      // }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _listOfProducts.length,
        itemBuilder: (context, index) {
          final product = _listOfProducts[index];
          return GridTile(
            footer: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
              child: GestureDetector(
                onTap: () async {
                  if (AppWidgetCartBottom.of(context).isNotVisible) {
                    if (context.mounted) await AppWidgetCartBottom.of(context).show();
                  }

                  if (context.mounted) {
                    await AppWidgetCartBottom.of(context).addToCart(product);
                    // if (context.mounted) await AppWidgetCartBottom.of(context).hide();
                  }
                },
                child: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(product.name),
                  trailing: const Icon(Icons.add_shopping_cart),
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                ProductScreen.routeName,
                arguments: product,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Hero(
                  tag: '${product.id}-hero',
                  child: CachedNetworkImage(
                    cacheKey: product.image,
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    key: product.globalKey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
