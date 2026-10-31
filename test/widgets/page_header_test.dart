import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/widgets/page_header.dart';

void main() {
  testWidgets('子页面返回键在左侧且不与标题重叠', (tester) async {
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 3.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [PageHeader(title: '重量转换', onBack: () {})],
          ),
        ),
      ),
    );

    final back = tester.getRect(find.byKey(const Key('page-back')));
    final title = tester.getRect(find.text('重量转换'));
    expect(back.left, lessThan(20));
    expect(back.right, lessThan(title.left));
    expect((title.left + title.right) / 2, closeTo(192, 2));
  });
}
