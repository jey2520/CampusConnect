import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).userModel;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authProvider).userModel;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        uid: user.uid,
        fullName: _nameController.text.trim(),
        email: user.email,
        phoneNumber: _phoneController.text.trim(),
        college: user.college,
        department: user.department,
        year: user.year,
        profilePhoto: user.profilePhoto,
        bio: _bioController.text.trim(),
        createdAt: user.createdAt,
        lastLogin: DateTime.now(),
        authenticationProvider: user.authenticationProvider,
        role: user.role,
        status: user.status,
      );

      final success = await ref.read(authProvider.notifier).updateProfile(updatedUser);
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final user = authState.userModel;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
                onPressed: () => context.go('/home'),
              )
            : null,
        title: Text(
          'Student Profile',
          style: TextStyle(fontWeight: FontWeight.extrabold, color: theme.colorScheme.onBackground),
        ),
        centerTitle: true,
        actions: [
          if (user != null) ...[
            if (!_isEditing)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                onPressed: () => setState(() => _isEditing = true),
              )
            else
              IconButton(
                icon: const Icon(Icons.check_rounded, color: Colors.green),
                onPressed: _saveProfile,
              ),
          ]
        ],
      ),
      body: user == null
          ? const Center(child: Text('User profile loading failed.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: user.profilePhoto.isNotEmpty
                                ? NetworkImage(user.profilePhoto)
                                : null,
                            child: user.profilePhoto.isEmpty
                                ? Text(
                                    user.initials,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.black,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          if (!_isEditing) ...[
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.extrabold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.department.isNotEmpty ? '${user.department} Department • ' : ''}${user.year}',
                              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5), fontSize: 13),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Enter Full Name',
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bio & Phone edits
                    if (_isEditing) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                           hintText: 'Contact Phone Number',
                           prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Tell other students about yourself...',
                          prefixIcon: Icon(Icons.info_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Settings Group Card
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          // 1. Order Tracking Link
                          _buildSettingItem(
                            context,
                            icon: Icons.local_shipping_outlined,
                            iconColor: Colors.green,
                            title: 'Track Active Order',
                            onTap: () => context.push('/tracking'),
                          ),
                          const Divider(height: 1),
                          // 2. My Listings
                          _buildSettingItem(
                            context,
                            icon: Icons.list_alt_rounded,
                            iconColor: theme.colorScheme.primary,
                            title: 'My Listings',
                            onTap: () => context.push('/my-listings'),
                          ),
                          const Divider(height: 1),
                          // 3. Wishlist
                          _buildSettingItem(
                            context,
                            icon: Icons.favorite_border_rounded,
                            iconColor: Colors.redAccent,
                            title: 'Wishlist',
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Wishlist metrics updated!'), behavior: SnackBarBehavior.floating),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Log Out & Delete Card
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            context,
                            icon: Icons.logout_rounded,
                            iconColor: Colors.red,
                            title: 'Logout',
                            onTap: () async {
                              await ref.read(authProvider.notifier).logout();
                              if (mounted) {
                                context.go('/login');
                              }
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingItem(
                            context,
                            icon: Icons.delete_forever_rounded,
                            iconColor: Colors.red,
                            title: 'Delete Account',
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: const Text('Are you sure you want to permanently delete your student account?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await ref.read(authProvider.notifier).deleteAccount();
                                if (success && mounted) {
                                  context.go('/login');
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onBackground.withOpacity(0.3)),
      onTap: onTap,
    );
  }
}
