import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/calculator/calculator_controller.dart';
import '../features/calculator/calculator_page.dart';
import '../features/converter/converter_home_page.dart';
import '../features/multifunction/multifunction_page.dart';
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
  late final List<Widget> _pages;

  static const _tabs = ['计算', '换算', '多功能'];
  static const _tabKeys = [
    Key('tab-calculator'),
    Key('tab-converter'),
    Key('tab-multifunction'),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      CalculatorPage(controller: widget.calculatorController),
      const ConverterHomePage(),
      const MultifunctionPage(),
    ];
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
    if (value == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsPage(settings: settings),
        ),
      );
      return;
    }
    if (value == 'about') {
      showAboutDialog(
        context: context,
        applicationName: '幻念多功能计算器',
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(
          Icons.calculate_outlined,
          size: 36,
          color: CalcColors.orange,
        ),
        children: const [
          SizedBox(height: 8),
          Text('参考小米计算器交互，首版包含标准计算、科学计算、单位换算与时间计算。'),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? CalcColors.darkBg : CalcColors.lightBg;
    final inactive = CalcColors.secondaryText(context);

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
                height: CalcSpacing.topBarHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_tabs.length, (index) {
                        final active = index == _index;
                        return Semantics(
                          button: true,
                          selected: active,
                          label: '${_tabs[index]}标签',
                          child: GestureDetector(
                            key: _tabKeys[index],
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectTab(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.2,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active
                                      ? Theme.of(context).colorScheme.onSurface
                                      : inactive,
                                ),
                                child: Text(_tabs[index]),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Positioned(
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        tooltip: '菜单',
                        onSelected: _handleMenu,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'settings', child: Text('设置')),
                          PopupMenuDivider(),
                          PopupMenuItem(value: 'about', child: Text('关于')),
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
