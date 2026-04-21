import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class NavShell extends StatelessWidget {
  final Widget child;
  const NavShell({super.key, required this.child});

  static const _tabs = <_TabDef>[
    _TabDef('/home', 'assets/icons/nav/home.svg', 'Home'),
    _TabDef('/feed', 'assets/icons/nav/feed.svg', 'Feed'),
    _TabDef('/jobs', 'assets/icons/nav/jobs.svg', 'Jobs'),
    _TabDef('/booking', 'assets/icons/nav/booking.svg', 'Booking'),
    _TabDef('/profile', 'assets/icons/nav/profile.svg', 'Profile'),
  ];

  int _indexOf(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path || location.startsWith('${_tabs[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final current = _indexOf(loc);
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        current: current,
        onTap: (i) {
          if (i == current) return;
          context.go(_tabs[i].path);
        },
      ),
    );
  }
}

class _TabDef {
  final String path;
  final String icon;
  final String label;
  const _TabDef(this.path, this.icon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  static const _activeColor = Color(0xFF2C4E84);
  static const _inactiveColor = Color(0xFF93949A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < NavShell._tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: NavShell._tabs[i].icon,
                    label: NavShell._tabs[i].label,
                    active: i == current,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _BottomNav._activeColor : _BottomNav._inactiveColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.048,
            ),
          ),
        ],
      ),
    );
  }
}
