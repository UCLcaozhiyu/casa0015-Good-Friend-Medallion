import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassWidget extends StatelessWidget {
  final double bearing;
  final double distance;
  final bool isBluetoothMode;

  const CompassWidget({
    Key? key,
    required this.bearing,
    required this.distance,
    required this.isBluetoothMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 方向指示器
              Transform.rotate(
                angle: bearing * (math.pi / 180),
                child: const Icon(
                  Icons.arrow_upward,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              // 距离显示
              Positioned(
                bottom: 20,
                child: Text(
                  '${(distance / 1000).toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 模式指示器
              Positioned(
                top: 20,
                child: Text(
                  isBluetoothMode ? '蓝牙模式' : 'GPS模式',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isBluetoothMode
              ? '已连接到好友设备'
              : '正在使用GPS定位好友位置',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
} 