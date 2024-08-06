part of 'cart_widget_bloc.dart';

///* Estado de visibilidade del widget de carrinho
enum CartWidgetVisibilityState { visible, hidden }

///* Estado de animação do widget de carrinho
enum CartWidgetAnimationState { animating, idle }

///* Estado de operação do widget de carrinho
sealed class CartWidgetOperationState extends Equatable {
  const CartWidgetOperationState();

  @override
  List<Object> get props => [];
}

class CartWidgetOperationInitialState extends CartWidgetOperationState {}

class CartWidgetLoadingState extends CartWidgetOperationState {}

class CartWidgetLoadedState extends CartWidgetOperationState {
  const CartWidgetLoadedState(this.items);

  final List<CartItem> items;

  @override
  List<Object> get props => [items];
}

class CartWidgetErrorState extends CartWidgetOperationState {
  const CartWidgetErrorState({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

///* Estado do widget de carrinho
class CartWidgetState extends Equatable {
  const CartWidgetState({
    required this.visibilityState,
    required this.animationState,
    required this.operationState,
  });

  final CartWidgetVisibilityState visibilityState;
  final CartWidgetAnimationState animationState;
  final CartWidgetOperationState operationState;

  CartWidgetState copyWith({
    CartWidgetVisibilityState? visibilityState,
    CartWidgetAnimationState? animationState,
    CartWidgetOperationState? operationState,
  }) {
    return CartWidgetState(
      visibilityState: visibilityState ?? this.visibilityState,
      animationState: animationState ?? this.animationState,
      operationState: operationState ?? this.operationState,
    );
  }

  @override
  List<Object> get props => [
        visibilityState,
        animationState,
        operationState,
      ];
}
