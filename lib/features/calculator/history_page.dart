import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';
import 'calculator_controller.dart';
import 'history_entry.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});

  final CalculatorController controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Set<HistoryEntry> _selected = {};

  bool get _selectionMode => _selected.isNotEmpty;

  void _toggle(HistoryEntry entry) {
    setState(() {
      if (!_selected.add(entry)) {
        _selected.remove(entry);
      }
    });
  }

  void _selectAll() {
    final all = widget.controller.history;
    setState(() {
      if (_selected.length == all.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(all);
      }
    });
  }

  void _exitSelection() => setState(_selected.clear);

  Future<void> _confirmClear() async {
    if (widget.controller.history.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('清空历史记录'),
          content: const Text('确定要清空全部历史记录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('history-clear-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      widget.controller.clearHistory();
      if (mounted) setState(_selected.clear);
    }
  }

  void _recalculate() {
    if (_selected.isEmpty) return;
    final entry = _selected.first;
    widget.controller.useHistory(entry);
    Navigator.of(context).pop();
  }

  Future<void> _copy() async {
    if (_selected.isEmpty) return;
    final text = _selected
        .map(
          (entry) =>
              '${entry.expression} ${entry.approximate ? '≈' : '='} ${entry.resultText}',
        )
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }

  void _deleteSelected() {
    for (final entry in _selected.toList()) {
      widget.controller.removeHistory(entry);
    }
    setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final entries = widget.controller.history;
        return Scaffold(
          key: const Key('history-page'),
          backgroundColor: CalcColors.displayBackground(context),
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  selectionMode: _selectionMode,
                  selectedCount: _selected.length,
                  onBack: () {
                    if (_selectionMode) {
                      _exitSelection();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  onSelectAll: _selectAll,
                  onClear: _confirmClear,
                  hasEntries: entries.isNotEmpty,
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            '暂无历史记录',
                            style: TextStyle(
                              fontSize: 15,
                              color: CalcColors.secondaryText(context),
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 96),
                          children: _buildGroups(context, entries),
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _selectionMode
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 8, 40, 16),
                    child: _ActionBar(
                      onRecalculate: _recalculate,
                      onCopy: _copy,
                      onDelete: _deleteSelected,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  List<Widget> _buildGroups(BuildContext context, List<HistoryEntry> entries) {
    final children = <Widget>[];
    String? currentDate;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final date = _dateLabel(entry.createdAt);
      if (date != currentDate) {
        currentDate = date;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
            child: Text(
              date,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: CalcColors.secondaryText(context),
              ),
            ),
          ),
        );
      }
      children.add(
        _HistoryRow(
          key: Key('history-entry-$index'),
          entry: entry,
          index: index,
          selected: _selected.contains(entry),
          selectionMode: _selectionMode,
          onTap: () {
            if (_selectionMode) {
              _toggle(entry);
            } else {
              widget.controller.useHistory(entry);
              Navigator.of(context).pop();
            }
          },
          onLongPress: () => _toggle(entry),
        ),
      );
    }
    return children;
  }

  String _dateLabel(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}.$month.$day';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectionMode,
    required this.selectedCount,
    required this.onBack,
    required this.onSelectAll,
    required this.onClear,
    required this.hasEntries,
  });

  final bool selectionMode;
  final int selectedCount;
  final VoidCallback onBack;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final bool hasEntries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: IconButton(
              key: const Key('history-back'),
              onPressed: onBack,
              icon: Icon(
                selectionMode ? Icons.close : Icons.arrow_back_ios_new,
                size: selectionMode ? 24 : 20,
              ),
            ),
          ),
          Text(
            selectionMode ? '已选择$selectedCount项' : '历史记录',
            key: const Key('history-title'),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
          ),
          Positioned(
            right: 4,
            child: selectionMode
                ? IconButton(
                    key: const Key('history-select-all'),
                    tooltip: '全选',
                    onPressed: onSelectAll,
                    icon: const Icon(Icons.checklist, size: 24),
                  )
                : IconButton(
                    key: const Key('history-clear'),
                    tooltip: '清空',
                    onPressed: hasEntries ? onClear : null,
                    icon: const Icon(Icons.delete_outline, size: 24),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final HistoryEntry entry;
  final int index;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Material(
      color: selected ? CalcColors.keyPressed(context) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${entry.expression} ${entry.approximate ? '≈' : '='} ',
                        style: TextStyle(fontSize: 19, color: secondary),
                      ),
                      TextSpan(
                        text: entry.resultText,
                        style: TextStyle(
                          fontSize: 21,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (selectionMode) ...[
                const SizedBox(width: 12),
                Container(
                  key: Key('history-checkbox-$index'),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? CalcColors.orange : Colors.transparent,
                    border: selected
                        ? null
                        : Border.all(color: CalcColors.secondaryText(context)),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onRecalculate,
    required this.onCopy,
    required this.onDelete,
  });

  final VoidCallback onRecalculate;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.pill),
      ),
      child: Row(
        children: [
          _Action(
            keyId: 'history-action-recalculate',
            icon: Icons.replay,
            label: '重新计算',
            onTap: onRecalculate,
          ),
          _Action(
            keyId: 'history-action-copy',
            icon: Icons.copy_rounded,
            label: '复制',
            onTap: onCopy,
          ),
          _Action(
            keyId: 'history-action-delete',
            icon: Icons.delete_outline,
            label: '删除',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.keyId,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String keyId;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: InkWell(
        key: Key(keyId),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}
