# Medallion App 开发历程

## 项目概述
这是一个基于 Flutter 开发的移动应用，主要功能包括蓝牙连接、位置服务和二维码扫描等。项目参考了两个代码库：
1. [casa0015-mobilesysterm](https://github.com/wudaozhiying1/casa0015-mobilesysterm.git)
2. [casa0015-Good-Friend-Medallion](git@github.com:UCLcaozhiyu/casa0015-Good-Friend-Medallion.git)

## 开发历程

### 初始尝试
1. 首次创建项目时遇到 Flutter 版本问题
2. 尝试在 Windows 和 Android 平台上运行
3. 遇到 Android SDK 版本兼容性问题

### 依赖配置
项目使用了以下主要依赖：
- flutter_blue_plus: ^1.31.13 (蓝牙功能)
- geolocator: ^10.1.0 (位置服务)
- flutter_spinkit: ^5.2.0 (UI 组件)
- provider: ^6.1.1 (状态管理)
- shared_preferences: ^2.2.2 (本地存储)

### 遇到的问题

1. **环境配置问题**
   - Flutter 版本兼容性问题
   - Android SDK 版本要求冲突
   - 设备连接问题

2. **代码实现问题**
   - 蓝牙服务实现
   - 位置服务权限
   - 二维码扫描功能
   - 状态管理架构

3. **项目结构问题**
   - 目录组织
   - 代码复用
   - 模块化设计

### 尝试的解决方案

1. **环境配置**
   - 更新 Flutter SDK
   - 调整 Android SDK 版本
   - 修改 build.gradle 配置

2. **代码重构**
   - 重新组织项目结构
   - 分离核心功能模块
   - 优化状态管理

3. **功能实现**
   - 分步实现各个功能模块
   - 每步进行测试验证
   - 参考现有代码库

## 当前状态
项目处于重构阶段，正在：
1. 重新组织项目结构
2. 分步实现核心功能
3. 确保每个步骤可运行

## 下一步计划
1. 完成基础项目结构
2. 实现核心功能模块
3. 添加必要的测试
4. 优化用户体验

## 注意事项
1. 确保 Flutter 环境配置正确
2. 注意 Android SDK 版本兼容性
3. 测试时注意设备连接状态
4. 关注权限管理问题

## 参考资源
1. [Flutter 官方文档](https://flutter.dev/docs)
2. [flutter_blue_plus 文档](https://pub.dev/packages/flutter_blue_plus)
3. [geolocator 文档](https://pub.dev/packages/geolocator) 