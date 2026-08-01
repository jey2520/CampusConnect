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
  final List<File> _imageFiles = [];

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

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Add Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close_rounded, color: Colors.red),
                title: const Text('Cancel', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can upload up to 5 images only.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final int sizeInBytes = await file.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);
      
      // Check file size (max 10MB)
      if (sizeInMb > 10.0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size exceeds the 10 MB limit.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Check extensions (JPG, JPEG, PNG, WebP)
      final ext = pickedFile.name.split('.').last.toLowerCase();
      const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!validExtensions.contains(ext)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only JPG, JPEG, PNG, and WebP are allowed.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _imageFiles.add(file);
      });
    }
  }

  Future<void> _publishListing() async {
    final user = ref.read(authProvider).userModel;
    if (user == null) return;

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or upload at least one product photo.'),
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
            imageFiles: _imageFiles,
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
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'Sell an Item',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Upload Widget
              if (_imageFiles.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length + (_imageFiles.length < 5 ? 1 : 0),
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex >= _imageFiles.length || newIndex > _imageFiles.length) {
                        return;
                      }
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final File item = _imageFiles.removeAt(oldIndex);
                        _imageFiles.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      if (index == _imageFiles.length) {
                        return GestureDetector(
                          key: const ValueKey('add_more_btn'),
                          onTap: _showImagePickerOptions,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.onBackground.withOpacity(0.08),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 28, color: theme.colorScheme.primary),
                                const SizedBox(height: 8),
                                const Text('Add More', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }

                      final file = _imageFiles[index];
                      return Container(
                        key: ValueKey(file.path),
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb 
                                  ? Image.network(file.path, fit: BoxFit.cover)
                                  : Image.file(file, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imageFiles.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  index == 0 ? 'Cover' : '${index + 1}',
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                GestureDetector(
                  onTap: _showImagePickerOptions,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Product Photos',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PNG, JPG, JPEG, WebP up to 10MB (Max 5)',
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
              if (productState.isLoading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: productState.uploadProgress,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Uploading images: ${(productState.uploadProgress * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                    ? const Text(
                        'Uploading & Publishing...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
