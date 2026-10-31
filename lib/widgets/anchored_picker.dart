import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class AnchoredPickerItem<T> {
  const AnchoredPickerItem({
    required this.id,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final T value;
}

Future<T?> showAnchoredPicker<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<AnchoredPickerItem<T>> items,
  required T? selected,
  required String keyPrefix,
  double width = 176,
  double maxHeight = 480,
}) {
  final anchorContext = anchorKey.currentContext;
  final renderBox = anchorContext?.findRenderObject() as RenderBox?;
  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (renderBox == null || overlayBox == null) return Future.value();

  final origin = renderBox.localToGlobal(Offset.zero);
  final overlayOrigin = overlayBox.localToGlobal(Offset.zero);
  final anchor = origin - overlayOrigin;
  final screen = overlayBox.size;
  final itemHeight = 48.0;
  final height = math.min(items.length * itemHeight + 16, maxHeight);
  var left = anchor.dx;
  if (left + width > screen.width - 8) {
    left = screen.width - width - 8;
  }
  left = math.max(8.0, left);
  var top = anchor.dy + renderBox.size.height + 6;
  if (top + height > screen.height - 8) {
    top = math.max(8.0, anchor.dy - height - 6);
  }

  final selectedIndex = items.indexWhere((item) => item.value == selected);
  final controller = ScrollController(
    initialScrollOffset: selectedIndex <= 1
        ? 0
        : (selectedIndex - 1) * itemHeight,
  );

  return showDialog<T>(
    context: context,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (dialogContext) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: Container(
                constraints: BoxConstraints(maxHeight: height),
                decoration: BoxDecoration(
                  color: CalcColors.keyBackground(dialogContext),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == selected;
                    return InkWell(
                      key: Key('$keyPrefix-${item.id}'),
                      onTap: () => Navigator.of(dialogContext).pop(item.value),
                      child: SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: [
                            const SizedBox(width: 18),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: isSelected
                                            ? CalcColors.orange
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                      ),
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        item.subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CalcColors.secondaryText(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: CalcColors.orange,
                              ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
