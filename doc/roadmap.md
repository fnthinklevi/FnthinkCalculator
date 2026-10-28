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
| T2 | 设计系统与三标签壳 | 已完成 | 建立 `theme/tokens.dart`、`app_theme.dart`；实现顶部“计算 / 换算 / 多功能”三标签、右上菜单、深色模式、响应式壳；替换默认页 | 3 个 shell widget 测试；模拟器走查三标签与菜单，无 FATAL | `b256c3a` |
| T3 | 数值层与表达式引擎 | 已完成 | 实现有理数 + double 数值层、Lexer、递归下降解析、AST、求值器、格式化器；落实小米百分比口径、错误模型、自动补右括号 | 39 项测试（含引擎/格式化/模糊）；format/analyze/test/build 全绿；模拟器回归无 FATAL | `915dbb5` |
| T4 | 标准计算页 | 已完成 | 显示区、键位、光标编辑、实时预览、C/AC、退格、复制/大写；连接引擎与内存历史；错误态恢复 | 66 项测试（含控制器/页面/大写）；模拟器实测 `1+2=3`、除零恢复、科学面板，无 FATAL | `0e9cfb4` |
| T5 | 历史与设置持久化 | 已完成 | `shared_preferences` 存储历史与设置；历史弹层复用/删除/清空；设置页主题、震动、角度单位；损坏数据自动重置 | 73 项测试（含仓库/控制器重载）；模拟器切深色、重启后主题和历史均保留 | `0444a53` |
| T6 | 科学计算 | 已完成 | 科学函数、2nd、DEG/RAD；竖屏功能条 + 标准键盘；横屏左侧显示/右侧键盘；定义域错误处理 | 79 项测试；模拟器竖屏科学条与横屏左右布局走查，无溢出/崩溃 | `4796d38` |
| T7 | 单位换算（7 类） | 已完成 | 长度、面积、体积、温度、速度、时间、重量；BigRational 换算表、单位互换、温度仿射；首页网格 + 详情页 + 单位选择器 | 91 项测试（含已知值/往返）；模拟器长度 `1m=100cm`、交换、单位选择器走查 | 本次提交 |
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

### T2 设计系统与三标签壳

- 日期：2026-10-28
- 提交：`b256c3a`
- 完成内容：
  - 新增 `lib/theme/tokens.dart`：亮/暗色板、间距、圆角、字号、等宽数字。
  - 新增 `lib/theme/app_theme.dart`：Material 3 亮/暗主题、橙色主色、菜单/SnackBar/选择主题。
  - 新增 `lib/app/settings_controller.dart`、`app_scope.dart`：主题模式、触感、角度单位的内存状态。
  - 新增 `lib/app/shell.dart`：顶部“计算 / 换算 / 多功能”三标签、右上菜单（跟随系统/浅色/深色/关于）、IndexedStack 保活、状态栏适配。
  - `lib/app/app.dart` 接入中文本地化、亮/暗主题与三标签壳；`lib/main.dart` 替换默认计数器入口。
  - 新增计算/换算/多功能三个页面占位，供后续任务替换。
  - 删除 Flutter 默认计数器测试，新增 `test/app/shell_test.dart`。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：3/3 通过。
  - `flutter build apk --debug`：成功（53.7s）。
- 冒烟结果：
  - 模拟器安装成功，冷启动 `TotalTime: 2767`。
  - 三标签可切换，右上菜单可打开，深色模式正常。
  - `logcat` 无 `FATAL EXCEPTION`、无 `E/flutter`。
- 备注：当前三个页面仍是占位内容，T4/T7/T8 会替换为真实页面。

### T3 数值层与表达式引擎

- 日期：2026-10-28
- 提交：`915dbb5`
- 完成内容：
  - `lib/core/math/rational.dart`：BigInt 有理数，四则、幂、比较、十进制/指数解析、精确约分。
  - `lib/core/math/calc_value.dart`：有理数 + double 混合数值层，四则、幂、阶乘、百分比、绝对值。
  - `lib/core/math/lexer.dart`、`parser.dart`、`ast.dart`：词法、递归下降解析、AST；支持函数、常量、括号、后缀 `!`/`%`、右结合幂、一元负号。
  - `lib/core/math/evaluator.dart`：小米百分比口径、DEG/RAD、三角/反三角/对数/根、定义域与溢出错误。
  - `lib/core/math/formatter.dart`：精确小数、12 位有效数字、`≈` 标记、千分位、科学计数法。
  - `lib/core/math/calculator_engine.dart`：统一入口，自动补右括号，异常转中文错误。
  - `AngleUnit` 移到 `core/math`，设置控制器改为引用核心枚举。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：39/39 通过（含 36 项引擎/格式化/模糊测试）。
  - `flutter build apk --debug`：成功（25.2s）。
- 冒烟结果：
  - 模拟器 `emulator-5554` 重装成功，冷启动 `TotalTime: 9026`。
  - `logcat` 无 `FATAL EXCEPTION`、无 `E/flutter`。
- 口径确认：
  - `10%+10%=0.11`、`100+10%=110`、`100−10%=90`、`100×10%=10`、`100÷10%=1,000`。
  - `0.1+0.2=0.3` 精确；`1÷3` 显示 `≈0.333333333333`；`1÷8=0.125`。
  - 不支持隐式乘法；表达式 `2(3)` 直接报格式错误。
  - 1000! 可算，按科学计数法显示。

### T4 标准计算页

- 日期：2026-10-28
- 提交：`0e9cfb4`
- 完成内容：
  - `lib/features/calculator/calculator_controller.dart`：输入/结果/错误三态，实时预览、自动补括号、运算符合并、前导零/小数点校验、光标插入、历史复用、错误恢复。
  - `lib/features/calculator/history_entry.dart`：历史条目模型与 JSON 序列化，供 T5 持久化复用。
  - `lib/features/calculator/widgets/calc_display.dart`：历史行、光标自绘显示、结果自适应缩放、`≈` 标记、复制/大写/历史入口。
  - `lib/features/calculator/widgets/calc_keypad.dart`：4×5 键盘、白色圆角键、橙色运算符、橙色实心等号、按压动画、触感、长按清空。
  - `lib/features/calculator/widgets/scientific_panel.dart`：基础科学函数条（sin/cos/tan/ln/log/√/x²/xʸ/!/π/e/括号）。
  - `lib/features/calculator/widgets/history_sheet.dart`：历史弹层、复用、删除、长按复制。
  - `lib/core/utils/chinese_upper.dart`：人民币大写，支持角分、零、负数、科学计数法输入与范围错误。
  - 修复：数字后输入数字被误判为“接操作数”，曾插入 `×`；已在提交前修复并加测试覆盖。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：66/66 通过。
  - `flutter build apk --debug`：成功（35.1s）。
- 冒烟结果：
  - 同一 `ci_api34_pixel6` AVD（当前串口 `emulator-5556`）安装成功，冷启动正常。
  - 实测 `1+2=3`，显示表达式与结果；科学面板展开正常；`logcat` 无 `FATAL EXCEPTION`。
  - 首次截图确认空表达式的光标已修正到 `0` 右侧。
- 备注：换算页与多功能页仍是占位，T7/T8 替换。

### T5 历史与设置持久化

- 日期：2026-10-28
- 提交：`0444a53`
- 完成内容：
  - `lib/app/settings_repository.dart`：主题、触感、角度单位的 SharedPreferences 读写。
  - `lib/features/calculator/history_repository.dart`：历史 JSON 读写、200 条上限、损坏数据返回空。
  - `SettingsController` 接入仓库：启动时加载，修改时异步写回。
  - `CalculatorController` 接入 `HistoryStore`：启动加载历史，新增/删除/清空时落盘。
  - 新增 `lib/features/settings/settings_page.dart`：主题模式、按键震动、角度单位、版本与数据说明。
  - 菜单改为“设置 / 关于”；`main` 启动时加载 prefs，并把应用级 `CalculatorController` 注入壳。
  - 修复空表达式光标被右边缘裁掉；统一底部弹层与对话框底色。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：73/73 通过。
  - `flutter build apk --debug`：成功（19.4s）。
- 冒烟结果：
  - 设置页切换深色，应用主题即时更新。
  - 计算 `1+2=3` 后 `am force-stop` 再冷启动，主题仍为深色，历史仍显示 `1+2 = 3`。
  - `run-as` 读取 `FlutterSharedPreferences.xml`，确认 `history.v1` 与 `settings.themeMode.v1=dark` 已落盘。
  - `logcat` 无 `FATAL EXCEPTION`。

### T6 科学计算

- 日期：2026-10-28
- 提交：`4796d38`
- 完成内容：
  - 科学面板补齐：2nd、DEG/RAD、sin/cos/tan 与反三角、ln/eˣ、log/10ˣ、√/∛、x²/x³、xʸ、|x|、!、π、e、括号。
  - 2nd 选中态高亮；DEG/RAD 同时写入设置与计算控制器，设置页保持同步。
  - 控制器新增 `inputPower(3)`、`inputTenPower()`、`inputExpPower()`。
  - 横屏改为左侧显示 + 右侧键盘 + 底部科学条；竖屏维持显示/科学条/键盘三段式。
  - 科学条由懒加载 ListView 改为 SingleChildScrollView + Row，避免离屏键找不到。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：79/79 通过。
  - `flutter build apk --debug`：成功（42.5s）。
- 冒烟结果：
  - 竖屏科学条显示 2nd/DEG/sin/cos/tan/ln，可横向滚动。
  - 横屏 `2400×1080` 显示左右布局，无 RenderFlex 溢出。
  - 日志无 `FATAL EXCEPTION`；冒烟后已恢复竖屏。

### T7 单位换算（7 类）

- 日期：2026-10-28
- 提交：本次提交
- 完成内容：
  - `lib/features/converter/unit_data.dart`：长度/面积/体积/温度/速度/时间/重量 7 类，BigRational 换算因子，温度使用仿射换算。
  - `ConverterController`：输入解析、换算、单位互换、结果格式化与失效输入提示。
  - 换算首页：7 类卡片网格，显示单位数量。
  - 换算详情：从/到单位选择、实时输入、结果与单位、复制、交换按钮；单位选择器为底部弹层。
  - 时间类别明确标注 `1 月 = 30 天、1 年 = 365 天`；面积标注亩的定义。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：91/91 通过。
  - `flutter build apk --debug`：成功（42.3s）。
- 冒烟结果：
  - 换算首页 7 类卡片正常显示。
  - 长度详情默认 `1 米 = 100 厘米`；交换后 `1 厘米 = 0.01 米`。
  - 单位选择器底部弹层可打开，当前单位有勾选。
  - `logcat` 无 `FATAL EXCEPTION`、无 RenderFlex 溢出。

## 5. 当前风险与注意事项

1. 百分比语义容易按普通数学实现，必须按 `A ± B% = A ± A×B%` 的口径写测试。
2. 表达式编辑 + 实时预览是状态机，需用 fuzz 防崩溃；任何错误态必须可恢复。
3. 日期月末夹取、闰年、反向区间是时间计算的主要 bug 源。
4. 贷款/个税在第二批，未完成前不要在 UI 中放空入口。
5. 模拟器与真机必须区分；所有 adb 命令带 `-s emulator-5554`，不操作真机。
6. 换算页与多功能页仍是占位内容，T7/T8 才会替换；在此之前不要把这些占位当成最终 UI。

## 6. 更新规则

- 每完成一个任务：更新本文件的任务状态、闸门/冒烟结果、提交号。
- 技术事实变化：同步更新 `base.md`。
- 被推翻的结论保留原句并标注，不静默删除。
- 文档更新本身也走闸门/冒烟/提交，不单独跳过。
