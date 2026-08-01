import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'auth_provider.dart';
import '../models/product_model.dart';

class ProductFilter {
  final String searchQuery;
  final String category;
  final double minPrice;
  final double maxPrice;
  final String condition;
  final String college;
  final String sortBy; // newest, oldest, low_price, high_price

  ProductFilter({
    this.searchQuery = '',
    this.category = 'All',
    this.minPrice = 0.0,
    this.maxPrice = 100000.0,
    this.condition = 'All',
    this.college = 'All',
    this.sortBy = 'newest',
  });

  ProductFilter copyWith({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? college,
    String? sortBy,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      college: college ?? this.college,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final List<String> favoriteIds;
  final ProductFilter filter;
  final bool isLoading;
  final String? error;

  ProductState({
    required this.products,
    required this.filteredProducts,
    required this.favoriteIds,
    required this.filter,
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    List<String>? favoriteIds,
    ProductFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String? _currentUid;

  ProductNotifier(this._firestore, this._storage, this._currentUid)
      : super(ProductState(
          products: [],
          filteredProducts: [],
          favoriteIds: [],
          filter: ProductFilter(),
        )) {
    fetchProducts();
    if (_currentUid != null) {
      fetchFavorites();
    }
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      _firestore.collection('items').snapshots().listen((snapshot) {
        final products = snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.data(), doc.id);
        }).toList();
        
        state = state.copyWith(products: products, isLoading: false);
        applyFilter(state.filter);
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchFavorites() async {
    if (_currentUid == null) return;
    try {
      _firestore
          .collection('favorites')
          .where('userUid', isEqualTo: _currentUid)
          .snapshots()
          .listen((snapshot) {
        final favIds = snapshot.docs.map((doc) => doc.data()['itemUid'] as String).toList();
        state = state.copyWith(favoriteIds: favIds);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void updateFilter(ProductFilter filter) {
    state = state.copyWith(filter: filter);
    applyFilter(filter);
  }

  void applyFilter(ProductFilter filter) {
    List<ProductModel> list = List.from(state.products);

    // Apply search query
    if (filter.searchQuery.isNotEmpty) {
      list = list.where((p) => p.title.toLowerCase().contains(filter.searchQuery.toLowerCase()) || p.description.toLowerCase().contains(filter.searchQuery.toLowerCase())).toList();
    }

    // Apply category
    if (filter.category != 'All') {
      list = list.where((p) => p.category.toLowerCase() == filter.category.toLowerCase()).toList();
    }

    // Apply price
    list = list.where((p) => p.price >= filter.minPrice && p.price <= filter.maxPrice).toList();

    // Apply condition
    if (filter.condition != 'All') {
      list = list.where((p) => p.condition == filter.condition).toList();
    }

    // Apply college
    if (filter.college != 'All') {
      list = list.where((p) => p.college == filter.college).toList();
    }

    // Apply sorting
    if (filter.sortBy == 'newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (filter.sortBy == 'oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (filter.sortBy == 'low_price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (filter.sortBy == 'high_price') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }

    state = state.copyWith(filteredProducts: list);
  }

  Future<bool> createProduct({
    required String title,
    required double price,
    required bool negotiable,
    required String condition,
    required String category,
    required String college,
    required String description,
    required File imageFile,
    required String sellerName,
    required String sellerInitials,
  }) async {
    if (_currentUid == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final itemId = const Uuid().v4();
      
      // Upload image
      final ref = _storage.ref().child('items').child(itemId).child('primary.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final newProduct = ProductModel(
        id: itemId,
        title: title,
        price: price,
        negotiable: negotiable,
        condition: condition,
        category: category,
        college: college,
        description: description,
        image: downloadUrl,
        images: [downloadUrl],
        sellerUid: _currentUid!,
        sellerName: sellerName,
        sellerRating: '5.0',
        sellerInitials: sellerInitials,
        status: 'active',
        views: 0,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('items').doc(itemId).set(newProduct.toMap());
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateProductStatus(String id, String status) async {
    try {
      await _firestore.collection('items').doc(id).update({'status': status});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('items').doc(id).delete();
      // Remove files
      await _storage.ref().child('items').child(id).delete();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFavorite(String itemUid) async {
    if (_currentUid == null) return;
    final docId = '${_currentUid}_$itemUid';
    try {
      final doc = await _firestore.collection('favorites').doc(docId).get();
      if (doc.exists) {
        await _firestore.collection('favorites').doc(docId).delete();
      } else {
        await _firestore.collection('favorites').doc(docId).set({
          'userUid': _currentUid!,
          'itemUid': itemUid,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> incrementViews(String id, int currentViews) async {
    try {
      await _firestore.collection('items').doc(id).update({'views': currentViews + 1});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = Provider((ref) => FirebaseStorage.instance).read(ref);
  final authState = ref.watch(authProvider);
  final uid = authState.userModel?.uid;
  return ProductNotifier(firestore, storage, uid);
});
