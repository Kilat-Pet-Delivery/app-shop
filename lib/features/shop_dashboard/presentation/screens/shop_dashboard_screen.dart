import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/shop_dashboard_cubit.dart';
import '../../../shop_setup/data/models/shop_model.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShopDashboardCubit>().loadShop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<ShopDashboardCubit, ShopDashboardState>(
        builder: (context, state) {
          if (state is ShopDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ShopDashboardNoShop) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No shop yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/shop-setup'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your Shop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is ShopDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ShopDashboardCubit>().loadShop(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          ShopModel? shop;
          if (state is ShopDashboardLoaded) shop = state.shop;
          if (state is ShopDashboardUpdating) shop = state.shop;
          if (shop == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => context.read<ShopDashboardCubit>().loadShop(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Shop Header Card
                _buildShopHeader(shop),
                const SizedBox(height: 16),

                // Quick Stats
                _buildStatsRow(shop),
                const SizedBox(height: 16),

                // Services
                _buildServicesCard(shop),
                const SizedBox(height: 16),

                // Info Card
                _buildInfoCard(shop),
                const SizedBox(height: 16),

                // Actions
                _buildActionsCard(shop),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopHeader(ShopModel shop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, size: 40, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _categoryLabel(shop.category),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => context.push('/edit-shop'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(shop.address,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ShopModel shop) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.star, '${shop.rating}', 'Rating', Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.category, _categoryLabel(shop.category), 'Category', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.build, '${shop.services.length}', 'Services', Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(ShopModel shop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Services Offered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (shop.services.isEmpty)
              const Text('No services listed yet', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: shop.services
                    .map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ShopModel shop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _infoRow(Icons.schedule, 'Hours', shop.openingHours.isNotEmpty ? shop.openingHours : 'Not set'),
            _infoRow(Icons.phone, 'Phone', shop.phone.isNotEmpty ? shop.phone : 'Not set'),
            _infoRow(Icons.email, 'Email', shop.email.isNotEmpty ? shop.email : 'Not set'),
            if (shop.description.isNotEmpty) ...[
              const Divider(),
              Text(shop.description, style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildActionsCard(ShopModel shop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Shop Details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/edit-shop'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Shop', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _confirmDelete(shop.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String shopId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shop?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ShopDashboardCubit>().deleteShop(shopId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'grooming':
        return 'Grooming';
      case 'vet':
        return 'Veterinary';
      case 'boarding':
        return 'Boarding';
      case 'pet_store':
        return 'Pet Store';
      default:
        return category;
    }
  }
}
