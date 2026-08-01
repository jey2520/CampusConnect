import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/home_view.dart';
import '../views/categories_view.dart';
import '../views/search_view.dart';
import '../views/product_details_view.dart';
import '../views/add_listing_view.dart';
import '../views/chats_view.dart';
import '../views/chat_screen_view.dart';
import '../views/my_listings_view.dart';
import '../views/profile_view.dart';
import '../views/checkout_view.dart';
import '../views/tracking_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.userModel != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/';

      if (authState.isLoading) return null;

      if (!isLoggedIn) {
        if (!isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
          return '/login';
        }
      } else {
        if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesView(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: '/product-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailsView(productId: id);
        },
      ),
      GoRoute(
        path: '/add-listing',
        builder: (context, state) => const AddListingView(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsView(),
      ),
      GoRoute(
        path: '/chat-screen/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          return ChatScreenView(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const MyListingsView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/checkout/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckoutView(productId: id);
        },
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingView(),
      ),
    ],
  );
});
