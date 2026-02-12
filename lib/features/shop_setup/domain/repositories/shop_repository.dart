import '../../data/models/shop_model.dart';

abstract class ShopRepository {
  Future<ShopModel> createShop(Map<String, dynamic> data);
  Future<ShopModel> updateShop(String id, Map<String, dynamic> data);
  Future<void> deleteShop(String id);
  Future<List<ShopModel>> getMyShops();
  Future<ShopModel> getShop(String id);
}
