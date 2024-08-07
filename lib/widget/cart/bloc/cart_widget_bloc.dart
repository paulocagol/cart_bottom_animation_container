import 'package:bloc/bloc.dart';
import 'package:cart_bottom_animation_container/model/product.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../model/cart_item.dart';
import '../../../repository/cart_repository.dart';
import '../controller/app_widget_cart_bottom_controller.dart';

part 'cart_widget_event.dart';
part 'cart_widget_state.dart';

class CartWidgetBloc extends Bloc<CartWidgetEvent, CartWidgetState> {
  late final CartRepository _cartRepository;
  late final AppWidgetCartBottomController _screenController;

  CartWidgetBloc({
    required CartRepository cartRepository,
    required AppWidgetCartBottomController appWidgetCartBottomController,
  }) : super((CartWidgetState(
          animationState: CartWidgetAnimationState.idle,
          visibilityState: CartWidgetVisibilityState.hidden,
          operationState: CartWidgetOperationInitialState(),
          statusState: CartWidgetInitialState(),
        ))) {
    _cartRepository = cartRepository;
    _screenController = appWidgetCartBottomController;

    on<CartWidgetToggleEvent>(_onToggle);
    on<CartWidgetHideEvent>(_onHide);
    on<CartWidgetShowEvent>(_onShow);
    on<CartWidgetAddEvent>(_onAddToCart);
    on<CartWidgetRemoveEvent>(_onRemoveFromCart);
    on<CartWidgetLoadEvent>(_onLoadCartItems);
    on<CartWidgetShowErrorEvent>(_onShowError);
  }

  AppWidgetCartBottomController get screenController => _screenController;

  Future<void> _onToggle(
    CartWidgetToggleEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));

    var visibilityState = state.visibilityState;

    if (state.visibilityState == CartWidgetVisibilityState.visible) {
      await _screenController.hide();
      visibilityState = CartWidgetVisibilityState.hidden;
    } else {
      await _screenController.show();
      visibilityState = CartWidgetVisibilityState.visible;
    }

    emit(state.copyWith(
      visibilityState: visibilityState,
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  Future<void> _onHide(
    CartWidgetHideEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));
    await _screenController.hide();
    emit(state.copyWith(
      visibilityState: CartWidgetVisibilityState.hidden,
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  Future<void> _onShow(
    CartWidgetShowEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));
    await _screenController.show();
    emit(state.copyWith(
      visibilityState: CartWidgetVisibilityState.visible,
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  Future<void> _onAddToCart(
    CartWidgetAddEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    //? Inicia o estado de animação
    emit(state.copyWith(
      animationState: CartWidgetAnimationState.animating,
      statusState: CartWidgetInitialState(),
    ));

    //? Adiciona o item ao carrinho
    final listOfOptimisticProducts = List<CartItem>.from(_getItemsFromState(state));
    final listOfProducts = List<CartItem>.from(listOfOptimisticProducts);

    CartItem? item = listOfOptimisticProducts.firstWhereOrNull((element) => element.product.id == event.product.id);

    if (item != null) {
      //? Atualiza o item ao carrinho de forma otimista
      for (int i = 0; i < listOfOptimisticProducts.length; i++) {
        final itemList = listOfOptimisticProducts[i];
        if (itemList.product.id == item.product.id) {
          listOfOptimisticProducts[i] = itemList.copyWith(quantity: itemList.quantity + event.quantity);
        }
      }
      emit(state.copyWith(operationState: CartWidgetLoadedState(listOfOptimisticProducts)));
    } else {
      //? Cria um item temporário para adicionar ao carrinho
      final tempId = UniqueKey().toString();
      item = CartItem(id: tempId, product: event.product, quantity: event.quantity);

      //? Adiciona o item temporário ao carrinho de forma otimista
      listOfOptimisticProducts.insert(0, item);
      emit(state.copyWith(operationState: CartWidgetLoadedState(listOfOptimisticProducts)));
    }

    //? Realiza a animação
    await _screenController.addItemToCart(
      vsync: event.vsync,
      cartItems: listOfProducts,
      product: item.product,
      tag: event.tag,
    );

    //? Finaliza o estado de animação
    emit(state.copyWith(animationState: CartWidgetAnimationState.idle));

    try {
      //? Adiciona o item ao carrinho - Backend
      final backendItem = await _cartRepository.addCartItem(item);

      //? Substitui o item temporário pelo item adicionado ao backend
      final replacedItems =
          listOfOptimisticProducts.map((itemList) => itemList.id == item!.id ? backendItem : itemList).toList();

      //? Atualiza o estado do widget
      emit(state.copyWith(
        operationState: CartWidgetLoadedState(replacedItems),
        statusState: CartWidgetSuccessState(),
      ));
    } catch (e) {
      //? Reverte o item temporário
      _screenController.updateCartItemKeys(listOfProducts);

      //? Atualiza o estado do widget
      emit(state.copyWith(
        operationState: CartWidgetLoadedState(listOfProducts),
        statusState: CartWidgetErrorState(error: e.toString()),
      ));
    }
  }

  Future<void> _onRemoveFromCart(
    CartWidgetRemoveEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));
    await _cartRepository.removeCartItem(event.item);
    emit(state.copyWith(
      animationState: CartWidgetAnimationState.idle,
      operationState: CartWidgetLoadedState(_cartRepository.getProducts()),
    ));
  }

  Future<void> _onLoadCartItems(
    CartWidgetLoadEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(
      operationState: CartWidgetLoadingState(),
      animationState: CartWidgetAnimationState.animating,
    ));
    final cartItems = _cartRepository.getProducts();
    _screenController.updateCartItemKeys(cartItems);
    emit(state.copyWith(
      operationState: CartWidgetLoadedState(cartItems),
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  Future<void> _onShowError(
    CartWidgetShowErrorEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    //? Oculta o widget
    await _screenController.hide();

    //? Exibe a mensagem de erro
    if (event.context.mounted) {
      ScaffoldMessenger.of(event.context).showSnackBar(
        SnackBar(
          content: Text(event.error),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1000),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 2000));
    }

    //? Restaura o estado inicial do widget
    emit(state.copyWith(
      statusState: CartWidgetInitialState(),
      animationState: CartWidgetAnimationState.idle,
    ));

    //? Mostra o widget novamente
    await _screenController.show();
  }

  List<CartItem> _getItemsFromState(CartWidgetState state) {
    if (state.operationState is CartWidgetLoadedState) {
      return (state.operationState as CartWidgetLoadedState).items;
    }

    return [];
  }
}
