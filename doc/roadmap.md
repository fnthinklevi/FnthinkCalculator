# 幻念多功能计算器 · Roadmap

> 最后更新：2026-10-28
> 执行规则：每个任务按“实现 → 闸门测试 → 冒烟测试 → 本地提交”顺序执行；上一任务全绿并提交后，才允许开始下一任务。
> 技术基线见 [base.md](base.md)。

## 1. 范围

### 首版（T2–T9）

- 标准计算：四则、括号、百分比、实时预览、算式编辑、错误恢复。
- 科学计算：三角/反三角、对数、幂/根、阶乘、π/e、DEG/RAD、2nd。
- 历史记录：自动保存、复用、删除、清空、复制。
- 结果复制与人民币大写。
- 单位换算：长度、面积、体积、温度、速度、时间、重量。
- 时间计算：日期差、日期推算、时长加减、年龄计算。
- 设置：深色模式、按键震动、角度单位、清除历史。
- 质量收口：fuzz、golden、无障碍、模拟器走查、APK。

### 第二批（P1）

- 汇率换算、房贷计算、个税计算、亲戚称呼、比例计算。
- 第二批不砍功能，只排在首版之后。

## 2. 闸门与冒烟

### 2.1 闸门测试

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

通过标准：format 退出码 0、analyze 无 issue、测试全绿、APK 构建成功。

### 2.2 冒烟测试

```bash
flutter emulators --launch ci_api34_pixel6
adb -s emulator-5554 wait-for-device
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5554 shell am start -W -n com.fnthink.FnthinkCalculator/.MainActivity
```

通过标准：安装成功、冷启动成功、本任务主路径可走通、`logcat` 无 `FATAL EXCEPTION`、无未捕获异常。冒烟结束执行：

```bash
adb -s emulator-5554 emu kill
```

### 2.3 提交

- 一个任务一个本地 commit；不 push、不 tag、不部署。
- `git add` 指定文件，不使用 `git add -A`。
- 构建产物、`.dart_tool/`、`.idea/`、`local.properties`、keystore 不入库。
- 提交信息用临时 `.txt` + `git commit -F`。

## 3. 任务总表

状态说明：`已完成` / `进行中` / `待开始`。每个任务必须完成闸门、冒烟、提交后才能进入下一项。

| ID | 任务 | 状态 | 如何完成 | 闸门 / 冒烟 | 提交 |
|---|---|---|---|---|---|
| T0 | 工程初始化与构建基线 | 已完成 | Flutter Android 工程；包名、应用名、SDK 参数；Gradle 9.8.2 / AGP 9.4.1 / 内置 Kotlin / KGP 2.4.21 classpath；Java 21；腾讯 + 阿里云镜像；计算器自适应图标 | format/analyze/test/build 全绿；模拟器安装冷启动，无 FATAL | `149dae7` |
| T1 | 文档体系 | 已完成 | 新建 `doc/base.md`、`doc/roadmap.md`；写入技术栈、软件信息、目录架构、任务状态与执行规则；更新 README 指向文档 | format/analyze/test/build 全绿；模拟器重装冷启动，无 FATAL | `ac10ecf` |
| T2 | 设计系统与三标签壳 | 待开始 | 建立 `theme/tokens.dart`、`app_theme.dart`；实现顶部“计算 / 换算 / 多功能”三标签、右上菜单、深色模式、响应式壳；替换默认页 | 新增标签切换/主题 widget 测试；模拟器走查三标签 | 待记录 |
| T3 | 数值层与表达式引擎 | 待开始 | 实现有理数 + double 数值层、Lexer、递归下降解析、AST、求值器、格式化器；落实小米百分比口径、错误模型、自动补右括号 | 100+ 引擎单元测试；format/analyze/test/build；模拟器启动回归 | 待记录 |
| T4 | 标准计算页 | 待开始 | 显示区、键位、光标编辑、实时预览、C/AC、退格、复制/大写；连接引擎与内存历史；错误态恢复 | 标准计算关键路径 widget 测试；模拟器输入 `1+2=3`、百分比、除零、长数字 | 待记录 |
| T5 | 历史与设置持久化 | 待开始 | `shared_preferences` 存储历史与设置；历史弹层复用/删除/清空；设置页主题、震动、角度单位；损坏数据自动重置 | 持久化/损坏数据单元测试；模拟器重启后历史仍在 | 待记录 |
| T6 | 科学计算 | 待开始 | 科学函数、2nd、DEG/RAD；竖屏功能条 + 标准键盘；横屏完整面板；定义域错误处理 | 函数/角度/定义域测试；模拟器竖屏与横屏走查 | 待记录 |
| T7 | 单位换算（7 类） | 待开始 | 长度、面积、体积、温度、速度、时间、重量；换算表、单位互换、精度与格式；温度仿射换算 | 每类已知值与往返测试；模拟器逐类走查 | 待记录 |
| T8 | 多功能页与时间计算 | 待开始 | 多功能页首卡“时间计算”；日期差、日期推算、时长加减、年龄计算；DateOnly/UTC 天差、月末夹取、工作日仅排周末 | 闰年/月末/跨年/反向/负数边界测试；模拟器四页走查 | 待记录 |
| T9 | 首版质量收口与 APK | 待开始 | fuzz 随机按键序列、golden 亮/暗、无障碍语义、错误恢复清单、release APK、完整模拟器走查 | 全量闸门 + fuzz + 走查清单；release 构建成功 | 待记录 |
| T10 | 汇率换算（P1） | 待开始 | 无 key 汇率 API + 本地缓存 + 失败降级；币种搜索、互换、更新时间提示 | 换算正确性/缓存/断网测试；模拟器走查 | 待记录 |
| T11 | 房贷计算（P1） | 待开始 | 商业/公积金/组合；等额本息/本金；每期到分、末期调平；明细表 | 本金求和等于贷款额、零利率、边界期限；已知案例比对 | 待记录 |
| T12 | 个税计算（P1） | 待开始 | 月度七级税率；五险一金按金额输入；专项附加扣除；税后收入 | 税率分界点/零税/负数输入测试；免责声明 | 待记录 |
| T13 | 亲戚称呼（P1） | 待开始 | 关系链解析与称呼映射；常见父系/母系/姻亲路径；输入校验 | 常见关系用例表；模拟器走查 | 待记录 |
| T14 | 比例计算（P1） | 待开始 | 比例/按比例分配求解；输入校验与结果解释 | 比例边界与除零测试；模拟器走查 | 待记录 |

## 4. 完成记录

### T0 工程初始化与构建基线

- 日期：2026-10-28
- 提交：`149dae7`（chore: 初始化幻念多功能计算器 Android 工程）
- 完成内容：
  - Flutter 3.47.7 / Dart 3.13.5 工程。
  - 包名/namespace `com.fnthink.FnthinkCalculator`；应用名 `幻念多功能计算器`。
  - compileSdk 37 / targetSdk 37 / minSdk 28。
  - Gradle 9.8.2（腾讯云镜像）、AGP 9.4.1、AGP 内置 Kotlin、KGP 2.4.21 仅 classpath。
  - Java/Kotlin 字节码目标 21。
  - 阿里云仓库 + 上游兜底 + Flutter 存储仓库，两处配置。
  - 计算器图标、各密度与自适应图标。
- 闸门结果：
  - `dart format`：0 changed，退出码 0。
  - `flutter analyze`：No issues found。
  - `flutter test`：1/1 通过（默认计数器测试）。
  - `flutter build apk --debug`：成功。
  - `javap -verbose`：MainActivity `major version: 65`（Java 21）。
  - 临时任务实测：`AGP=9.4.1`、`KOTLIN=2.4.21`。
- 冒烟结果：
  - 模拟器 `ci_api34_pixel6`（API 34，1080×2400，420dpi）启动成功。
  - APK 安装成功，冷启动 `TotalTime: 6257`，`topResumedActivity` 为 `com.fnthink.FnthinkCalculator/.MainActivity`。
  - `logcat` 无 `FATAL EXCEPTION`、无 `E/flutter`。
  - 截图确认默认 Flutter 计数器页正常渲染。
- 备注：`android.newDsl=false` 仍有弃用警告；Flutter 插件仍用旧 variant API，暂保留。

### T1 文档体系

- 日期：2026-10-28
- 提交：`ac10ecf`（本次文档提交）
- 完成内容：
  - 新建 `doc/base.md`：软件信息、技术栈、构建命令、仓库镜像、目录架构、核心实现约束、质量规则、已知警告、范围。
  - 新建 `doc/roadmap.md`：范围、闸门/冒烟/提交规则、T0–T14 任务表、完成记录。
  - 更新 README 指向两份文档。
- 闸门结果：
  - `dart format`：0 changed，退出码 0。
  - `flutter analyze`：No issues found。
  - `flutter test`：1/1 通过。
  - `flutter build apk --debug`：成功（23.2s）。
- 冒烟结果：
  - APK 重装成功，冷启动 `TotalTime: 6833`。
  - `topResumedActivity` 为 `com.fnthink.FnthinkCalculator/.MainActivity`。
  - `logcat` 无 `FATAL EXCEPTION`、无 `E/flutter`。

## 5. 当前风险与注意事项

1. 百分比语义容易按普通数学实现，必须按 `A ± B% = A ± A×B%` 的口径写测试。
2. 表达式编辑 + 实时预览是状态机，需用 fuzz 防崩溃；任何错误态必须可恢复。
3. 日期月末夹取、闰年、反向区间是时间计算的主要 bug 源。
4. 贷款/个税在第二批，未完成前不要在 UI 中放空入口。
5. 模拟器与真机必须区分；所有 adb 命令带 `-s emulator-5554`，不操作真机。
6. 当前默认页仍是 Flutter 计数器，T4 才替换为计算器主界面。

## 6. 更新规则

- 每完成一个任务：更新本文件的任务状态、闸门/冒烟结果、提交号。
- 技术事实变化：同步更新 `base.md`。
- 被推翻的结论保留原句并标注，不静默删除。
- 文档更新本身也走闸门/冒烟/提交，不单独跳过。
