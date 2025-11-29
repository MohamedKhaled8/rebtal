import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/feature/owner/logic/cubit/add_chalet_cubit.dart';
import 'package:rebtal/core/utils/constants/app_constants.dart';

class AddChaletScreen extends StatelessWidget {
  const AddChaletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddChaletCubit>(),
      child: const _AddChaletView(),
    );
  }
}

class _AddChaletView extends StatefulWidget {
  const _AddChaletView();

  @override
  State<_AddChaletView> createState() => _AddChaletViewState();
}

class _AddChaletViewState extends State<_AddChaletView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final List<String> _selectedFeatures = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Chalet")),
      body: BlocListener<AddChaletCubit, AddChaletState>(
        listener: (context, state) {
          if (state is AddChaletSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Chalet added successfully! Pending approval."),
              ),
            );
            Navigator.pop(context);
          } else if (state is AddChaletFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(context),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Chalet Name"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: "Price per Night",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Text(
                  "Features",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.chaletCategories.map((category) {
                    final value = category['value'] as String;
                    final label = category['label'] as String;
                    final isSelected = _selectedFeatures.contains(value);
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeatures.add(value);
                          } else {
                            _selectedFeatures.remove(value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _featuresController,
                  decoration: const InputDecoration(
                    labelText: "Additional Features (comma separated)",
                    hintText: "WiFi, BBQ, etc.",
                  ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<AddChaletCubit, AddChaletState>(
                  builder: (context, state) {
                    if (state is AddChaletLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final additionalFeatures = _featuresController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            final features = [
                              ..._selectedFeatures,
                              ...additionalFeatures,
                            ];

                            context.read<AddChaletCubit>().submitChalet(
                              name: _nameController.text,
                              description: _descriptionController.text,
                              price:
                                  double.tryParse(_priceController.text) ?? 0.0,
                              location: _locationController.text,
                              features: features,
                              ownerId:
                                  "CURRENT_USER_ID", // Replace with actual user ID
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Submit Chalet"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return BlocBuilder<AddChaletCubit, AddChaletState>(
      builder: (context, state) {
        final images = context.read<AddChaletCubit>().selectedImages;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Images (${images.length})",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return InkWell(
                    onTap: () => context.read<AddChaletCubit>().pickImages(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(images[index], fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () =>
                            context.read<AddChaletCubit>().removeImage(index),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
