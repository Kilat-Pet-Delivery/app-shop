import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shop_setup/data/models/shop_model.dart';
import '../../../shop_setup/domain/repositories/shop_repository.dart';

// States
abstract class ShopDashboardState extends Equatable {
  const ShopDashboardState();
  @override
  List<Object?> get props => [];
}

class ShopDashboardInitial extends ShopDashboardState {}

class ShopDashboardLoading extends ShopDashboardState {}

class ShopDashboardLoaded extends ShopDashboardState {
  final ShopModel shop;
  const ShopDashboardLoaded(this.shop);
  @override
  List<Object?> get props => [shop.id];
}

class ShopDashboardNoShop extends ShopDashboardState {}

class ShopDashboardError extends ShopDashboardState {
  final String message;
  const ShopDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class ShopDashboardUpdating extends ShopDashboardState {
  final ShopModel shop;
  const ShopDashboardUpdating(this.shop);
  @override
  List<Object?> get props => [shop.id];
}

// Cubit
class ShopDashboardCubit extends Cubit<ShopDashboardState> {
  final ShopRepository _repository;

  ShopDashboardCubit(this._repository) : super(ShopDashboardInitial());

  Future<void> loadShop() async {
    emit(ShopDashboardLoading());
    try {
      final shops = await _repository.getMyShops();
      if (shops.isNotEmpty) {
        emit(ShopDashboardLoaded(shops.first));
      } else {
        emit(ShopDashboardNoShop());
      }
    } catch (e) {
      emit(ShopDashboardError(e.toString()));
    }
  }

  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    final currentState = state;
    if (currentState is ShopDashboardLoaded) {
      emit(ShopDashboardUpdating(currentState.shop));
    }
    try {
      final updated = await _repository.updateShop(shopId, data);
      emit(ShopDashboardLoaded(updated));
    } catch (e) {
      emit(ShopDashboardError(e.toString()));
    }
  }

  Future<void> deleteShop(String shopId) async {
    emit(ShopDashboardLoading());
    try {
      await _repository.deleteShop(shopId);
      emit(ShopDashboardNoShop());
    } catch (e) {
      emit(ShopDashboardError(e.toString()));
    }
  }
}
