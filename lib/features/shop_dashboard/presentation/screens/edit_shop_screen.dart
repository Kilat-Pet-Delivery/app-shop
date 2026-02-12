import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../shop_setup/data/models/shop_model.dart';
import '../cubit/shop_dashboard_cubit.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'grooming';
  final List<String> _selectedServices = [];
  LatLng _selectedLocation = const LatLng(3.1390, 101.6869);
  ShopModel? _shop;

  final _allServices = {
    'grooming': ['Bath & Blow Dry', 'Full Grooming', 'Nail Trimming', 'Ear Cleaning', 'De-shedding', 'Flea Treatment', 'Creative Styling', 'Teeth Brushing'],
    'vet': ['Vaccination', 'Health Checkup', 'Surgery', 'Dental Care', 'Emergency', 'Microchipping', 'Spay/Neuter', 'X-Ray', 'Blood Test'],
    'boarding': ['Day Care', 'Overnight Boarding', 'Long Stay', 'Play Area', 'Webcam Monitoring', 'Special Diet', 'Grooming'],
    'pet_store': ['Pet Food', 'Accessories', 'Toys', 'Crates & Carriers', 'Health Supplements', 'Clothing'],
  };

  @override
  void initState() {
    super.initState();
    final state = context.read<ShopDashboardCubit>().state;
    if (state is ShopDashboardLoaded) {
      _populateFields(state.shop);
    }
  }

  void _populateFields(ShopModel shop) {
    _shop = shop;
    _nameController.text = shop.name;
    _addressController.text = shop.address;
    _phoneController.text = shop.phone;
    _emailController.text = shop.email;
    _openingHoursController.text = shop.openingHours;
    _descriptionController.text = shop.description;
    _selectedCategory = shop.category;
    _selectedServices.clear();
    _selectedServices.addAll(shop.services);
    _selectedLocation = LatLng(shop.latitude, shop.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _openingHoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopDashboardCubit, ShopDashboardState>(
      listener: (context, state) {
        if (state is ShopDashboardLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shop updated!'), backgroundColor: Colors.green),
          );
          context.pop();
        } else if (state is ShopDashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Shop'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<ShopDashboardCubit, ShopDashboardState>(
              builder: (context, state) {
                if (state is ShopDashboardUpdating) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveShop,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Shop Name',
                prefixIcon: const Icon(Icons.storefront),
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'grooming', label: Text('Grooming'), icon: Icon(Icons.content_cut)),
                  ButtonSegment(value: 'vet', label: Text('Vet'), icon: Icon(Icons.local_hospital)),
                  ButtonSegment(value: 'boarding', label: Text('Boarding'), icon: Icon(Icons.hotel)),
                  ButtonSegment(value: 'pet_store', label: Text('Store'), icon: Icon(Icons.shopping_bag)),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (s) => setState(() {
                  _selectedCategory = s.first;
                  _selectedServices.clear();
                }),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                label: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Location (tap to change)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 14,
                      onTap: (_, latLng) => setState(() => _selectedLocation = latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.kilatpet.app_shop',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation,
                            width: 40, height: 40,
                            child: const Icon(Icons.storefront, color: Colors.deepOrange, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: 'Phone',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _openingHoursController,
                label: 'Opening Hours',
                prefixIcon: const Icon(Icons.schedule),
              ),
              const SizedBox(height: 16),
              const Text('Services', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_allServices[_selectedCategory] ?? []).map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices.remove(service);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                prefixIcon: const Icon(Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveShop() {
    if (_shop == null) return;
    context.read<ShopDashboardCubit>().updateShop(_shop!.id, {
      'name': _nameController.text,
      'address': _addressController.text,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'category': _selectedCategory,
      'services': _selectedServices,
      'opening_hours': _openingHoursController.text,
      'description': _descriptionController.text,
    });
  }
}
