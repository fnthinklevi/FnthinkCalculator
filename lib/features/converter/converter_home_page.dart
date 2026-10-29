import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'converter_page.dart';
import 'currency_page.dart';
import 'exchange_rate_repository.dart';
import 'unit_data.dart';

class ConverterHomePage extends StatelessWidget {
  const ConverterHomePage({super.key, this.currencyRepository});

  final ExchangeRateRepository? currencyRepository;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return SafeArea(
      top: false,
      child: Column(
        key: const Key('converter-page'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              '单位换算',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '选择类别',
              style: TextStyle(fontSize: 13, color: secondary),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: UnitData.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _EntryCard(
                        keyId: 'converter-category-currency',
                        icon: Icons.currency_exchange,
                        title: '汇率',
                        subtitle: '实时汇率 · 离线缓存',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CurrencyConverterPage(
                                repository: currencyRepository,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    final category = UnitData.categories[index - 1];
                    return _EntryCard(
                      keyId: 'converter-category-${category.id}',
                      icon: category.icon,
                      title: category.name,
                      subtitle: '${category.units.length} 个单位',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ConverterPage(category: category),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.keyId,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String keyId;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Material(
      color: CalcColors.keyBackground(context),
      borderRadius: BorderRadius.circular(CalcRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key(keyId),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CalcColors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: CalcColors.orange, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: secondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
