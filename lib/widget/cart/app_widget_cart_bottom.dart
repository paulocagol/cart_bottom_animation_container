import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import '../../model/product.dart';

//* Constantes sheet
const minProportionalExtent = 0.0;
const middleProportionalExtent = 0.17;
const maxProportionalExtent = 0.9;
//* ----------------------------------

class AppWidgetCartBottom extends StatefulWidget {
  const AppWidgetCartBottom({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppWidgetCartBottom> createState() => AppWidgetCartBottomState();

  static AppWidgetCartBottomState of(BuildContext context) {
    final AppWidgetCartBottomState? result = context.findAncestorStateOfType<AppWidgetCartBottomState>();
    assert(result != null, 'No AppWidgetCartBottomState found in context');
    return result!;
  }
}

class AppWidgetCartBottomState extends State<AppWidgetCartBottom> with TickerProviderStateMixin {
  final StreamController<void> _itemChangeController = StreamController<void>.broadcast();

  //* Sheet variáveis
  double _currentExtent = 0.2;
  late final SheetController _sheetController;
  late final HeroController _heroController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  //* ------------------------------------------------------------------------------------------------

  //* Carinho variáveis
  final ValueNotifier<List<Product>> _cartItems = ValueNotifier<List<Product>>([]);
  final Map<Product, GlobalKey> _cartItemKeys = {};
  final ScrollController _scrollController = ScrollController();
  final List<OverlayEntry> _overlayEntries = [];
  final List<AnimationController> _listOfControllersAnimationsOverlay = [];
  final Set<Product> _animatingItems = {};

  Offset _imageOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;

  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  //* ------------------------------------------------------------------------------------------------

  //* Variáveis calculadas
  final ValueNotifier<double> _currentTotalCart = ValueNotifier<double>(0);
  //* ------------------------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _cartItems.addListener(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        _currentTotalCart.value = _cartItems.value.fold(0.0, (previousValue, element) => previousValue + element.price);
      });
    });

    _sheetController = SheetController();
    _heroController =
        HeroController(createRectTween: (Rect? begin, Rect? end) => MaterialRectArcTween(begin: begin, end: end));

    _sheetController.addListener(() {
      final metrics = _sheetController.value;
      setState(() {
        _currentExtent = metrics.pixels / metrics.maxPixels;

        // Check current route and navigate accordingly
        if (_currentExtent > 0.4) {
          if (!_isVerticalListRouteActive()) {
            _navigatorKey.currentState?.pushNamed("/vertical");
          }
        } else {
          if (_isVerticalListRouteActive()) {
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _sheetController.dispose();
    _itemChangeController.close();
    super.dispose();
  }

  bool _isVerticalListRouteActive() => _navigatorKey.currentState?.canPop() ?? false;

  bool get isVisible => _currentExtent > 0.1;

  bool get isNotVisible => _currentExtent < 0.1;

  Future<void> show() async {
    _sheetController.animateTo(
      const Extent.proportional(middleProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> max() async {
    _sheetController.animateTo(
      const Extent.proportional(maxProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  Future<void> hide() async {
    while (_overlayEntries.isNotEmpty) {
      await _itemChangeController.stream.first;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _sheetController.animateTo(
      const Extent.pixels(middleProportionalExtent),
      duration: const Duration(milliseconds: 300),
    );

    await Future.delayed(const Duration(milliseconds: 350));
  }

  //* Funções de carrinho
  /// Rola a lista do carrinho para tornar o item visível, se não estiver atualmente visível.
  Future<void> _scrollToItem(GlobalKey key) async {
    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    }
  }

  //* Adiciona um produto ao carrinho com animação.
  Future<void> addToCart(Product product) async {
    //? Previne a adição do mesmo produto enquanto ele está animando.
    if (_animatingItems.contains(product)) return;

    final productContext = product.globalKey.currentContext;
    final cartContext = _cartKey.currentContext;

    // final screenFrameContext = _getScreenFrameKey().currentContext;
    final screenFrameContext = context;
    // final screenFrameContext = widget.masterKey.currentContext;

    if (productContext != null && cartContext != null) {
      RenderBox productRenderBox = productContext.findRenderObject() as RenderBox;
      final RenderBox deviceFrameRenderBox = screenFrameContext.findRenderObject() as RenderBox;

      //? Calcula a posição da imagem do produto.
      _imageOffset = productRenderBox.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox);
      final RenderBox cartRenderBox = cartContext.findRenderObject() as RenderBox;

      if (_cartItems.value.contains(product)) {
        print('Product already in cart');
        var cartItem = _cartItemKeys[product]!;

        if (cartItem.currentContext == null) {
          //? Aproxima o scroll até a posição do item
          final itemIndex = _cartItems.value.indexOf(product);
          final targetPosition = (itemIndex * 50.0).clamp(0.0, _scrollController.position.maxScrollExtent);
          await _scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          cartItem = _cartItemKeys[product]!;
        }

        await _scrollToItem(cartItem);

        _targetOffset = (cartItem.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox) ??
            _targetOffset;

        await _animateItemToCart(product, productRenderBox);
      } else {
        // Move o scroll para o início antes de adicionar o item ao carrinho.
        if (_scrollController.offset != 0) {
          await _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }

        _targetOffset = cartRenderBox.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox);

        //? Adiciona o item à lista de itens animados
        _animatingItems.add(product);

        //? Adiciona o item à lista do carrinho.
        final cartItemKey = await _addItemToCart(product);

        await Future.delayed(const Duration(milliseconds: 600));

        _targetOffset = (cartItemKey.currentContext?.findRenderObject() as RenderBox?)
                ?.localToGlobal(Offset.zero, ancestor: deviceFrameRenderBox) ??
            _targetOffset;
        await _animateItemToCart(product, productRenderBox);
      }
    }
  }

  void _addItem(Product product) {
    _cartItems.value = List.from(_cartItems.value)..insert(0, product);
  }

  void _removeItem(Product product) {
    _cartItems.value = List.from(_cartItems.value)..remove(product);
  }

  //? Adiciona o item à lista do carrinho.
  Future<GlobalKey<State<StatefulWidget>>> _addItemToCart(Product product) async {
    final GlobalKey itemKey = GlobalKey();
    _cartItemKeys[product] = itemKey;
    _addItem(product);
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 300));
    return itemKey;
  }

  /// Anima a adição do item ao carrinho.
  Future<void> _animateItemToCart(Product product, RenderBox productRenderBox) async {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 2300),
      vsync: this,
    );

    final offsetAnimation = Tween<Offset>(
      begin: _imageOffset,
      end: _targetOffset,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));

    final sizeAnimation = Tween<double>(
      begin: productRenderBox.size.width,
      end: 50,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));

    final overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: offsetAnimation,
        builder: (context, child) {
          // return AnimatedPositioned(
          return Positioned(
            // duration: const Duration(milliseconds: 2300),
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
                // child: CachedNetworkImage(
                //   cacheKey: product.image,
                //   imageUrl: product.image,
                //   fit: BoxFit.cover,
                //   // width: sizeAnimation.value,
                //   // height: sizeAnimation.value,
                //   placeholder: (context, url) => const SizedBox.shrink(),
                // ),
              },
            ),
          );
        },
      ),
    );

    _overlayEntries.add(overlayEntry);
    Overlay.of(context).insert(overlayEntry);
    _listOfControllersAnimationsOverlay.add(controller);

    //? Adiciona o item à lista de itens animados
    // _animatingItems.add(product);

    sizeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final entryIndex = _overlayEntries.indexOf(overlayEntry);
        if (entryIndex != -1) {
          _overlayEntries[entryIndex].remove();
          _overlayEntries.removeAt(entryIndex);
        }
        controller.dispose();
        _listOfControllersAnimationsOverlay.remove(controller);
        _animatingItems.remove(product);
        setState(() {});
        // return;
      }
    });

    await controller.forward();
  }
  //* ------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //? Definindo o valor da borda
    double borderRadiusValue = 16 * _currentExtent;

    //? Definindo a opacidade da sombra
    double shadowOpacity = 0.2 + (0.3 * _currentExtent);

    //? Definindo a opacidade mínima da sombra e aumentando gradualmente
    double minSheetShadowOpacity = 0.1; //* Opacidade mínima da sombra
    double maxSheetShadowOpacity = 0.4; //* Opacidade máxima da sombra
    double sheetShadowOpacity = _currentExtent > maxProportionalExtent
        ? minSheetShadowOpacity + (maxSheetShadowOpacity - minSheetShadowOpacity) * _currentExtent
        : 0.0;

    //? Adicionando a lógica para escalar e transladar gradualmente
    double scaleEffect = _currentExtent > maxProportionalExtent
        ? 1.0 - (0.1 * (_currentExtent - maxProportionalExtent) * 5).clamp(0.0, 0.1)
        : 1.0;

    //? Adicionando a lógica para escalar e transladar gradualmente
    double translateEffect =
        _currentExtent > maxProportionalExtent ? 50 * (_currentExtent - maxProportionalExtent) * 5 : 0.0;

    //* Material para o conteúdo da tela
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          //* Conteúdo da tela
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(shadowOpacity),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Transform.scale(
                scale: scaleEffect, //? Ajusta a escala da tela de fundo
                child: Transform.translate(
                  offset: Offset(0, translateEffect), //? Ajusta a posição da tela de fundo
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadiusValue),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableSheet(
              controller: _sheetController,
              minExtent: const Extent.proportional(minProportionalExtent),
              maxExtent: const Extent.proportional(maxProportionalExtent),
              initialExtent: const Extent.proportional(minProportionalExtent),
              physics: BouncingSheetPhysics(
                parent: SnappingSheetPhysics(
                  snappingBehavior: SnapToNearest(
                    snapTo: [
                      const Extent.proportional(minProportionalExtent),
                      const Extent.proportional(middleProportionalExtent),
                      const Extent.proportional(maxProportionalExtent),
                    ],
                  ),
                ),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _currentExtent > maxProportionalExtent
                          ? const SizedBox.shrink()
                          : Container(
                              height: 10,
                              width: 100,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Divider(
                                thickness: 2,
                                color: Colors.black.withOpacity(0.5),
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(sheetShadowOpacity),
                              blurRadius: 10,
                              spreadRadius: 0.1,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: constraints.maxHeight - 10,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Navigator(
                              key: _navigatorKey,
                              observers: [_heroController],
                              onGenerateRoute: (RouteSettings settings) {
                                return PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 1000), // Define a duração de transição
                                  reverseTransitionDuration: const Duration(milliseconds: 1000),
                                  barrierColor: Colors.green,
                                  opaque: true,
                                  settings: settings,

                                  pageBuilder: (context, animation, secondaryAnimation) {
                                    if (settings.name == "/vertical") {
                                      return _buildVerticalList();
                                    }
                                    return _buildHorizontalList();
                                  },
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.fastOutSlowIn;

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalList() {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: _currentExtent > maxProportionalExtent ? 0 : 70,
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                ),
                child: SizedBox(
                  key: _cartKey,
                  child: AnimatedList(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    key: _listKey,
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    initialItemCount: _cartItems.value.length,
                    itemBuilder: (context, index, animation) {
                      final product = _cartItems.value[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: Opacity(
                            opacity: _animatingItems.contains(product) ? 0 : 1,
                            child: Hero(
                              tag: 'product_${product.id}',
                              child: ClipRRect(
                                key: _cartItemKeys[product],
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  cacheKey: product.image,
                                  imageUrl: product.image,
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
                color: Colors.red,
                height: constraints.maxHeight - 70,
                width: constraints.maxWidth,
                child: ValueListenableBuilder<double>(
                  valueListenable: _currentTotalCart,
                  builder: (context, value, child) {
                    return Text(
                      'Total R\$ ${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerticalList() {
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
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produtos 10',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total R\$ 750,00',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
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
                    // height: MediaQuery.of(context).size.height,
                    child: AnimatedList(
                      primary: true,
                      shrinkWrap: true,
                      initialItemCount: _cartItems.value.length,
                      itemBuilder: (context, index, animation) {
                        final product = _cartItems.value[index];
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
