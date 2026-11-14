import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/calculator/calculator_controller.dart';
import '../features/calculator/calculator_page.dart';
import '../features/calculator/history_page.dart';
import '../features/converter/converter_home_page.dart';
import '../features/settings/settings_page.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'app_scope.dart';
import 'app_shortcuts.dart';
import 'settings_controller.dart';

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
  late final PageController _pageController;
  SettingsController? _settings;
  AppShortcut? _pendingShortcut;

  static const _tabs = ['计算', '换算'];
  static const _tabKeys = [Key('tab-calculator'), Key('tab-converter')];

  @override
  void initState() {
    super.initState();
    _controller = widget.calculatorController ?? CalculatorController();
    _ownsController = widget.calculatorController == null;
    _pageController = PageController();
    _pages = [
      CalculatorPage(controller: _controller),
      const ConverterHomePage(),
    ];
    _pageController.addListener(_onPageChanged);
    AppShortcuts.listen(_handleShortcut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _readInitialShortcut());
  }

  void _onPageChanged() {
    final page = _pageController.page;
    if (page == null) return;
    final rounded = page.round();
    if (rounded != _index) {
      setState(() => _index = rounded);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = AppScope.of(context);
    if (!identical(settings, _settings)) {
      _settings?.removeListener(_onSettingsChanged);
      _settings = settings;
      settings.addListener(_onSettingsChanged);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _settings?.removeListener(_onSettingsChanged);
    AppShortcuts.stopListening();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _readInitialShortcut() async {
    final shortcut = await AppShortcuts.initialShortcut();
    if (shortcut != null && mounted) {
      _handleShortcut(shortcut);
    }
  }

  void _handleShortcut(AppShortcut? shortcut) {
    if (shortcut == null || !mounted) return;
    if (_settings?.privacyAccepted != true) {
      _pendingShortcut = shortcut;
      return;
    }
    AppShortcuts.open(context, shortcut);
  }

  void _onSettingsChanged() {
    final pending = _pendingShortcut;
    if (pending == null || _settings?.privacyAccepted != true) return;
    _pendingShortcut = null;
    AppShortcuts.open(context, pending);
  }

  void _selectTab(int index) {
    if (index == _index) return;
    final settings = AppScope.of(context);
    if (settings.haptics) {
      HapticFeedback.selectionClick();
    }
    _pageController.animateToPage(
      index,
      duration: CalcMotion.standard,
      curve: Curves.easeOut,
    );
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
                      controller: _pageController,
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
                child: PageView(controller: _pageController, children: _pages),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatefulWidget {
  const _TabPill({
    required this.tabs,
    required this.keys,
    required this.controller,
    required this.onSelected,
  });

  final List<String> tabs;
  final List<Key> keys;
  final PageController controller;
  final ValueChanged<int> onSelected;

  @override
  State<_TabPill> createState() => _TabPillState();
}

class _TabPillState extends State<_TabPill> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant _TabPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final selectedColor = CalcColors.trackSelected(context);
    final page =
        widget.controller.page ?? widget.controller.initialPage.toDouble();
    return Container(
      height: 42,
      width: 158,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CalcColors.track(context),
        borderRadius: BorderRadius.circular(CalcRadius.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / widget.tabs.length;
          return Stack(
            children: [
              Positioned(
                left: page * segmentWidth,
                top: 0,
                width: segmentWidth,
                height: constraints.maxHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(CalcRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var index = 0; index < widget.tabs.length; index++)
                    Expanded(
                      child: GestureDetector(
                        key: widget.keys[index],
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onSelected(index),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 160),
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.1,
                              fontWeight: (page - index).abs() < 0.5
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: (page - index).abs() < 0.5
                                  ? Theme.of(context).colorScheme.onSurface
                                  : CalcColors.secondaryText(context),
                            ),
                            child: Text(widget.tabs[index]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
