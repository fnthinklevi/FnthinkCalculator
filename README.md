# 幻念多功能计算器

Flutter Android 计算器，UI 与交互参考小米计算器。首版包含标准计算、科学计算、7 类单位换算和新增的时间计算（日期差、日期推算、时长加减、年龄计算）。

## 文档

- [技术基线](doc/base.md)：软件信息、技术栈、构建命令、目录架构、质量规则
- [Roadmap](doc/roadmap.md)：任务状态、实现方式、闸门/冒烟/提交记录

## 快速命令

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

APK 输出：`build/app/outputs/flutter-apk/app-debug.apk`

## 工程信息

- 包名：`com.fnthink.FnthinkCalculator`
- 软件名：幻念多功能计算器
- compileSdk / targetSdk：37
- minSdk：28
- 构建：Gradle 9.8.2、AGP 9.4.1、AGP 内置 Kotlin、Java/Kotlin 目标 21
