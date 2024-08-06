import 'package:bloc/bloc.dart';
import 'package:cart_bottom_animation_container/model/product.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

import '../../../model/cart_item.dart';
import '../../../repository/cart_repository.dart';
import '../controller/app_widget_cart_bottom_controller.dart';

part 'cart_widget_event.dart';
part 'cart_widget_state.dart';

class CartWidgetBloc extends Bloc<CartWidgetEvent, CartWidgetState> {
  late final CartRepository _cartRepository;
  late final AppWidgetCartBottomController _controller;

  CartWidgetBloc({
    required CartRepository cartRepository,
    required AppWidgetCartBottomController appWidgetCartBottomController,
  }) : super((CartWidgetState(
          animationState: CartWidgetAnimationState.idle,
          visibilityState: CartWidgetVisibilityState.hidden,
          operationState: CartWidgetOperationInitialState(),
        ))) {
    _cartRepository = cartRepository;
    _controller = appWidgetCartBottomController;

    on<CartWidgetToggleEvent>(_onToggle);
    on<CartWidgetHideEvent>(_onHide);
    on<CartWidgetShowEvent>(_onShow);
    on<CartWidgetAddEvent>(_onAddToCart);
    on<CartWidgetRemoveEvent>(_onRemoveFromCart);
    on<CartWidgetLoadEvent>(_onLoadCartItems);
  }

  AppWidgetCartBottomController get controller => _controller;

  Future<void> _onToggle(
    CartWidgetToggleEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));

    var visibilityState = state.visibilityState;

    if (state.visibilityState == CartWidgetVisibilityState.visible) {
      await _controller.hide();
      visibilityState = CartWidgetVisibilityState.hidden;
    } else {
      await _controller.show();
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
    await _controller.hide();
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
    await _controller.show();
    emit(state.copyWith(
      visibilityState: CartWidgetVisibilityState.visible,
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  Future<void> _onAddToCart(
    CartWidgetAddEvent event,
    Emitter<CartWidgetState> emit,
  ) async {
    emit(state.copyWith(animationState: CartWidgetAnimationState.animating));
    final listOfProducts = _getItemsFromState(state);
    final item = CartItem(id: event.product.id, product: event.product, quantity: event.quantity);

    emit(state.copyWith(operationState: CartWidgetLoadedState(await _cartRepository.addCartItem(item))));
    await _controller.addItemToCart(
      vsync: event.vsync,
      cartItems: listOfProducts,
      product: item.product,
      tag: event.tag,
    );
    emit(state.copyWith(animationState: CartWidgetAnimationState.idle));
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
    _controller.updateCartItemKeys(cartItems);
    emit(state.copyWith(
      operationState: CartWidgetLoadedState(cartItems),
      animationState: CartWidgetAnimationState.idle,
    ));
  }

  List<CartItem> _getItemsFromState(CartWidgetState state) {
    if (state.operationState is CartWidgetLoadedState) {
      return (state.operationState as CartWidgetLoadedState).items;
    }

    return [];
  }
}
