import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'premium_screen.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';

// Root shell shown after login. Starts the live Firestore listeners and
// shows a bottom nav bar. Admins get an extra "Admin" tab; residents get
// a "Premium" tab instead - this is the role-based navigation split.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Start listening to news/alerts/tips as soon as we land here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<NewsProvider>().startListening(uid: auth.currentUser?.id);
    });
  }

  Future<void> logout(BuildContext context) async {
    context.read<NewsProvider>().stopListening();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    final screens = <Widget>[
      HomeScreen(onLogout: () => logout(context)),
      const AlertsScreen(),
      if (isAdmin)
        AdminDashboardScreen(onLogout: () => logout(context))
      else
        const PremiumScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning), label: 'Alerts'),
      if (isAdmin)
        const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin')
      else
        const NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), selectedIcon: Icon(Icons.workspace_premium), label: 'Premium'),
    ];

    // Keep the selected index valid if the role-dependent tab count changes.
    final safeIndex = _index < screens.length ? _index : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
