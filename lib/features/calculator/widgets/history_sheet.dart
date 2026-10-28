import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/tokens.dart';
import '../calculator_controller.dart';
import '../history_entry.dart';

class HistorySheet extends StatelessWidget {
  const HistorySheet({
    super.key,
    required this.controller,
    required this.onClearHistory,
  });

  final CalculatorController controller;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.history;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
              child: Row(
                children: [
                  const Text(
                    '历史记录',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: entries.isEmpty ? null : onClearHistory,
                    child: const Text('清空'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        '暂无历史记录',
                        style: TextStyle(
                          color: CalcColors.secondaryText(context),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _HistoryRow(
                          entry: entry,
                          index: index,
                          onTap: () {
                            controller.useHistory(entry);
                            Navigator.of(context).pop();
                          },
                          onDelete: () => controller.removeHistory(entry),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            key: Key('history-entry-$index'),
            onTap: onTap,
            onLongPress: () async {
              await Clipboard.setData(ClipboardData(text: entry.resultText));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('已复制结果')));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.expression,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondary,
                      fontFeatures: CalcText.tabular,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.approximate ? '≈' : '='} ${entry.resultText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFeatures: CalcText.tabular,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          key: Key('history-delete-$index'),
          tooltip: '删除',
          onPressed: onDelete,
          icon: Icon(Icons.close, size: 18, color: secondary),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
