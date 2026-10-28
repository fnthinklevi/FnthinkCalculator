import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';
import 'converter_controller.dart';
import 'unit_data.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key, required this.category});

  final UnitCategory category;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late final ConverterController _controller;
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _controller = ConverterController(widget.category);
    _inputController = TextEditingController(text: _controller.input);
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    final text = _controller.copyText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已复制')));
  }

  Future<void> _pickUnit({required bool isFrom}) async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<UnitDef>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                child: Row(
                  children: [
                    const Text(
                      '选择单位',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.category.units.length,
                  itemBuilder: (context, index) {
                    final unit = widget.category.units[index];
                    final current = isFrom ? _controller.from : _controller.to;
                    return ListTile(
                      key: Key('unit-option-${unit.id}'),
                      title: Text(unit.name),
                      subtitle: Text(unit.symbol),
                      trailing: current == unit
                          ? const Icon(
                              Icons.check,
                              color: CalcColors.orange,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(unit),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    if (isFrom) {
      _controller.setFrom(selected);
    } else {
      _controller.setTo(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: const Key('converter-detail-page'),
          appBar: AppBar(
            title: Text('${widget.category.name}换算'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _buildCard(context, isFrom: true),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: IconButton.filled(
                      key: const Key('converter-swap'),
                      tooltip: '交换单位',
                      onPressed: _controller.swap,
                      style: IconButton.styleFrom(
                        backgroundColor: CalcColors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.swap_vert),
                    ),
                  ),
                ),
                _buildCard(context, isFrom: false),
                if (widget.category.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      widget.category.note!,
                      style: TextStyle(fontSize: 13, color: secondary),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, {required bool isFrom}) {
    final unit = isFrom ? _controller.from : _controller.to;
    final secondary = CalcColors.secondaryText(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalcColors.keyBackground(context),
        borderRadius: BorderRadius.circular(CalcRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                isFrom ? '从' : '到',
                style: TextStyle(fontSize: 13, color: secondary),
              ),
              const Spacer(),
              Flexible(
                child: _UnitPickerField(
                  key: Key(isFrom ? 'unit-from-picker' : 'unit-to-picker'),
                  unit: unit,
                  onTap: () => _pickUnit(isFrom: isFrom),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isFrom)
            TextField(
              key: const Key('converter-input'),
              controller: _inputController,
              onChanged: _controller.setInput,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 34,
                fontFeatures: CalcText.tabular,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '0',
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _controller.result == null
                          ? '—'
                          : '${_controller.approximate ? '≈ ' : ''}${_controller.resultText}',
                      key: const Key('converter-result'),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 34,
                        fontFeatures: CalcText.tabular,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  unit.symbol,
                  style: TextStyle(fontSize: 14, color: secondary),
                ),
                IconButton(
                  key: const Key('converter-copy'),
                  tooltip: '复制结果',
                  onPressed: _controller.result == null ? null : _copy,
                  icon: Icon(Icons.copy_outlined, size: 18, color: secondary),
                ),
              ],
            ),
          if (isFrom && _controller.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _controller.error!,
                style: const TextStyle(fontSize: 13, color: CalcColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitPickerField extends StatelessWidget {
  const _UnitPickerField({super.key, required this.unit, required this.onTap});

  final UnitDef unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: CalcColors.divider(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${unit.name} (${unit.symbol})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 18, color: secondary),
          ],
        ),
      ),
    );
  }
}
