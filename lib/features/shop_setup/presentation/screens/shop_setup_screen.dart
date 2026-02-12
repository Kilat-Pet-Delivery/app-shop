import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/shop_setup_cubit.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCategory = 'grooming';

  // Step 2: Location
  final _addressController = TextEditingController();
  LatLng _selectedLocation = const LatLng(3.1390, 101.6869); // KL center
  final _mapController = MapController();

  // Step 3: Details
  final _openingHoursController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedServices = [];

  final _allServices = {
    'grooming': ['Bath & Blow Dry', 'Full Grooming', 'Nail Trimming', 'Ear Cleaning', 'De-shedding', 'Flea Treatment', 'Creative Styling', 'Teeth Brushing'],
    'vet': ['Vaccination', 'Health Checkup', 'Surgery', 'Dental Care', 'Emergency', 'Microchipping', 'Spay/Neuter', 'X-Ray', 'Blood Test'],
    'boarding': ['Day Care', 'Overnight Boarding', 'Long Stay', 'Play Area', 'Webcam Monitoring', 'Special Diet', 'Grooming'],
    'pet_store': ['Pet Food', 'Accessories', 'Toys', 'Crates & Carriers', 'Health Supplements', 'Clothing'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _openingHoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopSetupCubit, ShopSetupState>(
      listener: (context, state) {
        if (state is ShopSetupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shop created successfully!'), backgroundColor: Colors.green),
          );
          context.go('/home');
        } else if (state is ShopSetupAlreadyHasShop) {
          context.go('/home');
        } else if (state is ShopSetupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Up Your Shop'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ShopSetupCubit, ShopSetupState>(
          builder: (context, state) {
            if (state is ShopSetupLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_currentStep == 2 ? 'Create Shop' : 'Next'),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Basic Info'),
                    subtitle: const Text('Name, contact & category'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: _buildBasicInfoStep(),
                  ),
                  Step(
                    title: const Text('Location'),
                    subtitle: const Text('Address & map pin'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: _buildLocationStep(),
                  ),
                  Step(
                    title: const Text('Details'),
                    subtitle: const Text('Hours, services & description'),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    content: _buildDetailsStep(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        AppTextField(
          controller: _nameController,
          label: 'Shop Name',
          hint: 'e.g. Happy Paws Grooming',
          prefixIcon: const Icon(Icons.storefront),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+60123456789',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _emailController,
          label: 'Shop Email',
          hint: 'shop@example.com',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'grooming', label: Text('Grooming'), icon: Icon(Icons.content_cut)),
            ButtonSegment(value: 'vet', label: Text('Vet'), icon: Icon(Icons.local_hospital)),
            ButtonSegment(value: 'boarding', label: Text('Boarding'), icon: Icon(Icons.hotel)),
            ButtonSegment(value: 'pet_store', label: Text('Store'), icon: Icon(Icons.shopping_bag)),
          ],
          selected: {_selectedCategory},
          onSelectionChanged: (selected) {
            setState(() {
              _selectedCategory = selected.first;
              _selectedServices.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        AppTextField(
          controller: _addressController,
          label: 'Full Address',
          hint: '123 Jalan Bukit Bintang, 55100 KL',
          prefixIcon: const Icon(Icons.location_on),
          maxLines: 2,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Tap on the map to set your shop location', style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 14,
                onTap: (tapPosition, latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
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
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.storefront, color: Colors.deepOrange, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    final availableServices = _allServices[_selectedCategory] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _openingHoursController,
          label: 'Opening Hours',
          hint: 'e.g. 9:00 AM - 7:00 PM',
          prefixIcon: const Icon(Icons.schedule),
        ),
        const SizedBox(height: 16),
        const Text('Services Offered', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableServices.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
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
          hint: 'Tell customers about your shop...',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Submit
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in shop name'), backgroundColor: Colors.red),
        );
        setState(() => _currentStep = 0);
        return;
      }
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in address'), backgroundColor: Colors.red),
        );
        setState(() => _currentStep = 1);
        return;
      }

      context.read<ShopSetupCubit>().createShop(
        name: _nameController.text,
        address: _addressController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        phone: _phoneController.text,
        email: _emailController.text,
        category: _selectedCategory,
        services: _selectedServices,
        openingHours: _openingHoursController.text,
        description: _descriptionController.text,
      );
    }
  }
}
