import 'package:flutter/material.dart';

import 'features/converter/converter_page.dart';
import 'features/converter/unit_data.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      home: ConverterPage(category: UnitData.length),
    ),
  );
}
