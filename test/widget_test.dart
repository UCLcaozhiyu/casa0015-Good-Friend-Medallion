// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_good_friend_medallion/main.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  testWidgets('Initial UI elements render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // 测试位置文字是否存在
    expect(find.text('📍 Your Location:'), findsOneWidget);

    // 测试 BLE 状态初始显示
    expect(find.text('Not Scanning'), findsOneWidget);

    // 测试按钮是否存在
    expect(find.widgetWithText(ElevatedButton, '🔍 Scan for Friend'), findsOneWidget);
  });
}