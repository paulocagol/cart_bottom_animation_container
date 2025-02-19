import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../model/product.dart';
import '../widget/cart/bloc/cart_widget_bloc.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Product> _listOfProducts = List.generate(
      50,
      (index) => Product(
            id: const Uuid().v4(),
            name: 'Product $index',
            description: 'Description of product $index',
            image: 'https://picsum.photos/200/300?random=$index',
            price: Random().nextDouble() * 100,
          ));

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartWidgetBloc>().add(CartWidgetShowEvent());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<CartWidgetBloc>().add(CartWidgetToggleEvent());
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
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
            footer: ClipSmoothRect(
              radius: const SmoothBorderRadius.only(
                bottomLeft: SmoothRadius(
                  cornerRadius: 22,
                  cornerSmoothing: 1,
                ),
                bottomRight: SmoothRadius(
                  cornerRadius: 22,
                  cornerSmoothing: 1,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  context.read<CartWidgetBloc>().add(CartWidgetAddEvent(
                        product: product,
                        quantity: 1,
                        vsync: this,
                        tag: 'homeScreen',
                      ));
                },
                child: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(product.name),
                  subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
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
              child: Hero(
                tag: '${product.id}-hero',
                child: ClipSmoothRect(
                  radius: const SmoothBorderRadius.all(
                    SmoothRadius(
                      cornerRadius: 22,
                      cornerSmoothing: 1,
                    ),
                  ),
                  child: CachedNetworkImage(
                    cacheKey: product.image,
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    key: product.getGlobalKey('homeScreen'),
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
