part of 'cart_widget_bloc.dart';

///* Estado de visibilidade del widget de carrinho
enum CartWidgetVisibilityState { visible, hidden }

///* Estado de animação do widget de carrinho
enum CartWidgetAnimationState { animating, idle }

///* Estado de erro do widget de carrinho
sealed class CartWidgetStatusState extends Equatable {
  const CartWidgetStatusState();

  @override
  List<Object> get props => [];
}

class CartWidgetInitialState extends CartWidgetStatusState {}

class CartWidgetSuccessState extends CartWidgetStatusState {}

class CartWidgetErrorState extends CartWidgetStatusState {
  const CartWidgetErrorState({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

///*******************************************************/

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

///* Estado do widget de carrinho
class CartWidgetState extends Equatable {
  const CartWidgetState({
    required this.visibilityState,
    required this.animationState,
    required this.operationState,
    required this.statusState,
  });

  final CartWidgetVisibilityState visibilityState;
  final CartWidgetAnimationState animationState;
  final CartWidgetOperationState operationState;
  final CartWidgetStatusState statusState;

  CartWidgetState copyWith({
    CartWidgetVisibilityState? visibilityState,
    CartWidgetAnimationState? animationState,
    CartWidgetOperationState? operationState,
    CartWidgetStatusState? statusState,
  }) {
    return CartWidgetState(
      visibilityState: visibilityState ?? this.visibilityState,
      animationState: animationState ?? this.animationState,
      operationState: operationState ?? this.operationState,
      statusState: statusState ?? this.statusState,
    );
  }

  @override
  List<Object> get props => [
        visibilityState,
        animationState,
        operationState,
        statusState,
      ];
}
