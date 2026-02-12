import 'package:dio/dio.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../data/models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  final Dio _dio;

  ShopRepositoryImpl(this._dio);

  @override
  Future<ShopModel> createShop(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/v1/petshops', data: data);
    return ShopModel.fromJson(response.data['data']);
  }

  @override
  Future<ShopModel> updateShop(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/v1/petshops/$id', data: data);
    return ShopModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteShop(String id) async {
    await _dio.delete('/api/v1/petshops/$id');
  }

  @override
  Future<List<ShopModel>> getMyShops() async {
    final response = await _dio.get('/api/v1/petshops/mine');
    final list = response.data['data'] as List? ?? [];
    return list.map((json) => ShopModel.fromJson(json)).toList();
  }

  @override
  Future<ShopModel> getShop(String id) async {
    final response = await _dio.get('/api/v1/petshops/$id');
    return ShopModel.fromJson(response.data['data']);
  }
}
