import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/shop_model.dart';
import '../../domain/repositories/shop_repository.dart';

// States
abstract class ShopSetupState extends Equatable {
  const ShopSetupState();
  @override
  List<Object?> get props => [];
}

class ShopSetupInitial extends ShopSetupState {}

class ShopSetupLoading extends ShopSetupState {}

class ShopSetupCheckingExisting extends ShopSetupState {}

class ShopSetupNeeded extends ShopSetupState {}

class ShopSetupAlreadyHasShop extends ShopSetupState {
  final ShopModel shop;
  const ShopSetupAlreadyHasShop(this.shop);
  @override
  List<Object?> get props => [shop.id];
}

class ShopSetupSuccess extends ShopSetupState {
  final ShopModel shop;
  const ShopSetupSuccess(this.shop);
  @override
  List<Object?> get props => [shop.id];
}

class ShopSetupError extends ShopSetupState {
  final String message;
  const ShopSetupError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ShopSetupCubit extends Cubit<ShopSetupState> {
  final ShopRepository _repository;

  ShopSetupCubit(this._repository) : super(ShopSetupInitial());

  Future<void> checkExistingShop() async {
    emit(ShopSetupCheckingExisting());
    try {
      final shops = await _repository.getMyShops();
      if (shops.isNotEmpty) {
        emit(ShopSetupAlreadyHasShop(shops.first));
      } else {
        emit(ShopSetupNeeded());
      }
    } catch (e) {
      emit(ShopSetupNeeded());
    }
  }

  Future<void> createShop({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
    required String email,
    required String category,
    required List<String> services,
    required String openingHours,
    required String description,
  }) async {
    emit(ShopSetupLoading());
    try {
      final data = {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'email': email,
        'category': category,
        'services': services,
        'opening_hours': openingHours,
        'description': description,
      };

      final shop = await _repository.createShop(data);
      emit(ShopSetupSuccess(shop));
    } catch (e) {
      emit(ShopSetupError(e.toString()));
    }
  }
}
