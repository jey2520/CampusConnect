import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class AddListingView extends ConsumerStatefulWidget {
  const AddListingView({super.key});

  @override
  ConsumerState<AddListingView> createState() => _AddListingViewState();
}

class _AddListingViewState extends ConsumerState<AddListingView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  
  bool _negotiable = false;
  String _selectedCondition = 'Gently Used';
  String _selectedCategory = 'Books';
  File? _imageFile;

  final List<String> _categories = [
    'Books', 'Electronics', 'Cycles', 'Calculators', 'Furniture', 
    'Lab Equipment', 'Sports', 'Fashion', 'Accessories', 'Hostel', 'Miscellaneous'
  ];

  final List<String> _conditions = [
    'Brand New', 'Like New', 'Gently Used', 'Heavily Used'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Basic compression
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _publishListing() async {
    final user = ref.read(authProvider).userModel;
    if (user == null) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or upload a product photo.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      final success = await ref.read(productProvider.notifier).createProduct(
            title: _titleController.text.trim(),
            price: double.parse(_priceController.text.trim()),
            negotiable: _negotiable,
            condition: _selectedCondition,
            category: _selectedCategory,
            college: user.college,
            description: _descController.text.trim(),
            imageFile: _imageFile!,
            sellerName: user.name,
            sellerInitials: user.initials,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing published successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home');
      } else {
        final errorMsg = ref.read(productProvider).error ?? 'Publishing failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sell an Item',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Upload Widget
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.onBackground.withOpacity(0.08),
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: _imageFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: kIsWeb 
                                ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                                : Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            const Text(
                              'Upload Product Photo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PNG, JPG up to 10MB',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Listing Title',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a listing title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Row of Price & Negotiable Switch
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Price (₹)',
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Neg.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Switch(
                            value: _negotiable,
                            onChanged: (val) => setState(() => _negotiable = val),
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  hintText: 'Category',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              // Condition Selector
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  hintText: 'Condition',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCondition = val!),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your item (e.g. usage history, pickup preferences)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Publish Button
              ElevatedButton(
                onPressed: productState.isLoading ? null : _publishListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: productState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Publish Listing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
