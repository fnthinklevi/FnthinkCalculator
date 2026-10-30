import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/calculator/calculator_controller.dart';
import '../features/calculator/calculator_page.dart';
import '../features/calculator/history_page.dart';
import '../features/converter/converter_home_page.dart';
import '../features/settings/settings_page.dart';
import '../theme/tokens.dart';
import 'app_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.calculatorController});

  final CalculatorController? calculatorController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final CalculatorController _controller;
  late final bool _ownsController;
  late final List<Widget> _pages;

  static const _tabs = ['计算', '换算'];
  static const _tabKeys = [Key('tab-calculator'), Key('tab-converter')];

  @override
  void initState() {
    super.initState();
    _controller = widget.calculatorController ?? CalculatorController();
    _ownsController = widget.calculatorController == null;
    _pages = [
      CalculatorPage(controller: _controller),
      const ConverterHomePage(),
    ];
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _index) return;
    final settings = AppScope.of(context);
    if (settings.haptics) {
      HapticFeedback.selectionClick();
    }
    setState(() => _index = index);
  }

  void _handleMenu(String value) {
    final settings = AppScope.of(context);
    if (value == 'history') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HistoryPage(controller: _controller),
        ),
      );
      return;
    }
    if (value == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsPage(settings: settings),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? CalcColors.darkBg : CalcColors.lightBg;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: CalcSpacing.topBarHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _TabPill(
                      tabs: _tabs,
                      keys: _tabKeys,
                      selectedIndex: _index,
                      onSelected: _selectTab,
                    ),
                    Positioned(
                      right: 4,
                      child: PopupMenuButton<String>(
                        key: const Key('app-menu'),
                        icon: Icon(
                          Icons.more_vert,
                          color: CalcColors.secondaryText(context),
                          size: 22,
                        ),
                        tooltip: '更多',
                        onSelected: _handleMenu,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            key: Key('menu-history'),
                            value: 'history',
                            child: Text('历史记录'),
                          ),
                          PopupMenuItem(
                            key: Key('menu-settings'),
                            value: 'settings',
                            child: Text('设置'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(index: _index, children: _pages),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.tabs,
    required this.keys,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final List<Key> keys;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = CalcColors.trackSelected(context);
    return Container(
      height: 42,
      width: 158,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CalcColors.track(context),
        borderRadius: BorderRadius.circular(CalcRadius.pill),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: GestureDetector(
                key: keys[index],
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: index == selectedIndex
                        ? selectedColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(CalcRadius.pill),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: index == selectedIndex
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: Text(tabs[index]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
