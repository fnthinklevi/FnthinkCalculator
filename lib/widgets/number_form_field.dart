import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

class NumberFormField extends StatelessWidget {
  const NumberFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.allowDecimal = true,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool allowDecimal;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final secondary = CalcColors.secondaryText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: secondary)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: allowDecimal,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(allowDecimal ? r'[0-9.]' : r'[0-9]'),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 22,
                    fontFeatures: CalcText.tabular,
                  ),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(fontSize: 22, color: secondary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              if (suffix != null)
                Text(suffix!, style: TextStyle(fontSize: 17, color: secondary)),
            ],
          ),
          Divider(height: 1, color: CalcColors.divider(context)),
        ],
      ),
    );
  }
}
