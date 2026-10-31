# 幻念多功能计算器 · Roadmap

> 最后更新：2026-10-30
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

- 汇率换算（T10）、房贷计算（T11）已完成。
- 小米 17.3.9 标准复刻 R1–R4 已完成：两标签、圆键、历史/设置、15 入口、三行汇率、单位全表、进制/BMI/称呼/个税、房贷清单；标准见 [xiaomi-reference.md](xiaomi-reference.md)。
- T12–T14 全部完成；第二批不砍功能。

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
| T7 | 单位换算（7 类） | 已完成 | 长度、面积、体积、温度、速度、时间、重量；BigRational 换算表、单位互换、温度仿射；首页网格 + 详情页 + 单位选择器 | 91 项测试（含已知值/往返）；模拟器长度 `1m=100cm`、交换、单位选择器走查 | `8e846b9` |
| T8 | 多功能页与时间计算 | 已完成 | 多功能页首卡“时间计算”；日期差、日期推算、时长加减/两时刻差、年龄；DateOnly/UTC 天差、月末夹取、工作日仅排周末；大写数字工具 | 106 项测试（含日期/时长边界）；模拟器四页走查 | 本次提交 |
| T8.1 | 时分秒计算器键盘与进位开关 | 已完成 | 单行 H:MM:SS 显示 + 内置数字键盘；数字从右向左按 60 进制分组；加减/等号/正负/退格/清空；结果可选“进到日/累计小时” | 全量测试；模拟器输入 `1:30:00 + 0:45:00`、25 小时进位/累计切换 | `dba4cb7` |
| T8.2 | 全应用内置数字键盘 | 已完成 | 新增共享 `NumericKeypad` 与 `applyNumericKey`；换算/大写数字使用内联键盘；日期推算数量使用内置键盘弹层；CalcKey 支持禁用态 | 119 项测试；模拟器换算输入、大写页、数量弹层走查；`lib` 内无 TextField | `72ebd96` |
| T9 | 首版质量收口与 APK | 已完成 | fuzz 随机按键序列、golden 亮/暗、无障碍语义、错误恢复清单、release APK、完整模拟器走查 | 119 项测试；release 通用包 54.0MB / arm64 19.4MB；release 冷启动 1.2s、`1+2=3` | `00b5eb0` |
| T9.1 | 内置键盘左下角撤回 | 已完成 | 主计算器、通用数字键盘、时分秒键盘左下角增加撤回键，每次删除一位、可连续；主键盘科学切换移到顶行，数字键盘重排 | 121 项测试；release 重建；主键盘 `32+25→32+` 设备走查；数字/时长撤回由 widget 测试覆盖 | `bd0fca9` |
| T9.2 | 时分秒分段编辑与冒号键 | 已完成 | 时长输入改为时/分/秒芯片分段编辑，点击切换当前段；数字键改当前段并按 60 进制即时归一化；新增冒号键切换时→分→秒；支持直接输入 96 小时、`96:52`，`96:64` 自动变 `97:04` | 122 项测试（含分段/冒号/归一化用例）；analyze 无问题；release 重建 | `1f7a4c4` |
| T10 | 汇率换算（P1） | 已完成 | 双公开接口 + 本地缓存 + 失败降级；31 币种分组选择、互换、更新时间/离线提示；未做文字搜索，避免系统键盘 | 143 项测试（含解析/缓存/断网/重试）；release 联网、断网缓存与交换走查 | `9f80b27` |
| T11 | 房贷计算（P1） | 已完成 | 商业/公积金/组合；等额本息/本金；整数分计算、末期调平；汇总 + 逐期明细 | 168 项测试（本金求和、零利率、1/30 年边界、已知案例）；release 组合贷/明细走查 | `d56d1e7` |
| T12 | 个税计算（P1） | 已完成（并入 R3） | 月薪/年终奖；七级税率；缴纳期数 1–12；专项附加扣除 7 项；五险一金合计；31 省 2025 社保基数静态表（省级，不伪造城市数据）；结果页 | 税率分界点/零税/扣除/年终奖/省份估算测试；模拟器表单走查 | `4e8ca3a`、`d25b57e` |
| T13 | 亲戚称呼（P1） | 已完成（并入 R3） | 关系链实时预览；互查；常见父系/母系/姻亲映射；未知路径提示；8 层上限 | 父母/祖辈/伯父/互查/未知路径测试；模拟器走查 | `4e8ca3a` |
| T14 | 比例计算（P1） | 已完成 | 按比例分配 + a:b=c:x 求值；系统数字键盘；校验/结果说明 | 比例分配/求值/零比例测试；模拟器走查 | `9552af9` |
| T12.1 | 个税省级社保基数 | 已完成 | 31 省 2025 平均工资/基数上下限；个人费率 10.5% 估算五险一金；标注来源/年度/不含公积金 | 31 项数据/北京数值/估算测试；省市选择走查 | `d25b57e` |
| R1 | 视觉底座与计算器复刻 | 已完成 | 两标签胶囊、圆键键盘、显示区层级、长按菜单、历史页、设置页、百分数双口径 | 198 项测试含 history/settings/守卫；模拟器亮暗走查 | `4e8ca3a` |
| R2 | 换算与汇率复刻 | 已完成 | 换算首页 15 入口；单位多行联动 + 锚定选择器；温度专用键盘；汇率三行 + 109 币种 + 来源行 | 单位/汇率/守卫测试；模拟器走查 | `4e8ca3a` |
| R3 | 新工具（进制/BMI/称呼/个税） | 已完成 | 进制键禁用与 2/8/10/16；BMI 表单/刻度结果；称呼互查；个税月薪/年终奖 | 各工具单元 + widget 测试；模拟器走查 | `4e8ca3a` |
| R4 | 房贷清单与收尾 | 已完成 | 房贷 40 年/LPR/基点/首期日期/组合贷不同年限；房贷清单英雄卡 + 年度明细；golden 重生成 | 房贷控制器/页面测试；198 项测试；debug APK；亮暗走查 | `4e8ca3a` |

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
- 提交：`8e846b9`
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

### T8 多功能页与时间计算

- 日期：2026-10-28
- 提交：本次提交
- 完成内容：
  - `lib/core/utils/date_calc.dart`：UTC 天差、月末夹取、日历差值（整年/整月递推）、工作日、周岁/虚岁、下次生日。
  - `lib/core/utils/duration_calc.dart`：秒级归一化、正负时长格式化、时分秒校验。
  - 多功能首页：时间计算主卡 + 大写数字工具；第二批功能仅文字说明，不放入口。
  - 时间计算页四个子页：日期差（含起始日/工作日/反向提示）、日期推算（方向/数量/年周月天/预设）、时长加减与两时刻差、年龄（周岁/虚岁/已出生/下次生日）。
  - 大写数字工具页：人民币大写、复制、非法输入提示。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：106/106 通过。
  - `flutter build apk --debug`：成功（44.2s）。
- 冒烟结果：
  - 多功能页时间计算主卡正常进入。
  - 日期差默认同一天显示 0 天；日期推算默认 `2026-10-28 → 2026-10-29`。
  - 时长页两段输入与 00:00:00 结果正常；年龄页默认 20 周岁/虚岁 21/已出生 7,305 天。
  - `logcat` 无 `FATAL EXCEPTION`、无 RenderFlex 溢出。

### T8.1 时分秒计算器键盘与进位开关

- 日期：2026-10-28
- 提交：`dba4cb7`
- 完成内容：
  - 时长“加减”子页改为计算器键盘：单行 `H:MM:SS` 显示 + 数字/00/正负/退格/清空/加减/等号。
  - 数字从右向左按 秒/分/时 分组（如 `13000` → `01:30:00`），自动按 60 进制归一化。
  - 新增“进到日 / 累计小时”开关：结果可显示 `1天 01:00:00` 或 `25:00:00`；输入显示始终累计小时，便于继续输入。
  - 复用主计算器 `CalcKey`，键盘样式与首页一致。
  - 控制器新增 `formatDurationAccumulated`、`secondsFromTimeDigits`。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：113/113 通过（含一万条随机按键 fuzz）。
  - `flutter build apk --debug`：成功（17.4s）。
- 冒烟结果：
  - 模拟器进入时长页，内置键盘输入 `1:30:00 + 0:45:00`，结果 `02:15:00`，总秒数 `8,100`。
  - 25 小时结果可在“进到日（1天 01:00:00）/累计小时（25:00:00）”间切换，已由 widget 测试覆盖。
  - `logcat` 无 `FATAL EXCEPTION`、无 RenderFlex 溢出。
- 备注：只改了“时长加减”子页；“两时刻差”保持原样。

### T8.2 全应用内置数字键盘

- 日期：2026-10-28
- 提交：`72ebd96`
- 完成内容：
  - 新增 `lib/widgets/numeric_keypad.dart`：共享数字键盘、`applyNumericKey`、禁用的 ±/小数点、完成键、底部弹层。
  - 换算详情：去掉 TextField，输入改为只读显示 + 常驻内置键盘，结果实时更新。
  - 大写数字：去掉 TextField，改为只读显示 + 常驻内置键盘。
  - 日期推算数量：去掉 TextField，改为可点数量 + 内置键盘弹层（仅非负整数）。
  - `CalcKey` 支持禁用态；按键语义改为显式容器，读屏可识别。
  - `lib/` 内已无任何 `TextField`；日期/时间选择器仍使用系统选择器，但不弹系统键盘。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：119/119 通过。
  - `flutter build apk --debug`：成功（11.3s）。
- 冒烟结果：
  - 换算页内置键盘输入 `100` 米 → `10,000` 厘米，无系统键盘。
  - 大写数字页内置键盘显示 `1234.56 → 壹仟贰佰叁拾肆元伍角陆分`。
  - 日期推算数量弹层为内置键盘，白键在浅灰弹层上对比正常，完成键可回填数量。
  - `logcat` 无 `FATAL EXCEPTION`、无 RenderFlex 溢出。

### T9 首版质量收口与 APK

- 日期：2026-10-28
- 提交：`00b5eb0`
- 完成内容：
  - 控制器 fuzz：10,000 条随机按键序列，不崩溃且结束后可恢复；引擎另保留 3,000 条 fuzz。
  - 常见错误恢复测试：除零、定义域、阶乘非整数、tan 无定义，错误后输入数字可恢复。
  - 无障碍：按键具备显式语义（读屏可识别数字/加/科学计算）；1.3 倍字体下仍可计算且无溢出。
  - golden：浅色/深色计算器布局基线各一张（仅证布局，测试字体下中文可能为占位字形）。
  - 代码扫描：`lib/` 内无 `TextField`，数值输入均走内置键盘。
  - release 构建与安装：通用包与按 ABI 分包。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：119/119 通过（含 10k fuzz 与 golden）。
  - `flutter build apk --debug`：成功（11.3s）。
  - `flutter build apk --release`：成功，通用包 54.0MB；split 后 arm64 19.4MB、armeabi-v7a 17.0MB、x86_64 20.7MB。
- release 冒烟结果：
  - 安装 release 包到 `emulator-5556`，冷启动 `TotalTime: 1209`。
  - `1+2=3` 正常，无 debug 横幅；`aapt2` 确认包名/应用名/min 28/target 37/compile 37。
  - release 包无 `INTERNET` 权限（首版离线）。
  - `logcat` 无 `FATAL EXCEPTION`、无 RenderFlex 溢出。
  - 首版其余页面此前已在 debug 包逐页走查：科学/横屏、换算、时间计算四页、设置与持久化、内置键盘输入。
- 备注：release 仍使用 debug 签名（模板默认），正式签名/上架所需 keystore 尚未提供；未 push、未部署。

### T9.1 内置键盘左下角撤回

- 日期：2026-10-28
- 提交：`bd0fca9`
- 完成内容：
  - 主计算器：撤回键移到左下角，每次删除一位；科学计算切换移到顶行原退格位置。
  - 通用数字键盘：撤回键放左下角；重排为 `789± / 456C / 123. / 撤回 0 00|完成`，所有原有键保留。
  - 时分秒键盘：左下角新增撤回键；原顶部退格保留，0 键改为跨 3 列。
  - 撤回语义统一为“撤回”，逐次删除，可连续点击；示例 `32+25 → 32+2 → 32+`。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：121/121 通过。
  - `flutter build apk --release`：成功，通用包 54.0MB；arm64 19.4MB。
  - golden 已按新主键盘重生成；测试字体下图标为占位方形，布局未变，故 golden 字节未变。
- 冒烟结果：
  - release 主键盘实测 `32+25 → 32+2 → 32+`。
  - 通用数字键盘、时长键盘的撤回键由 widget 测试逐次删除覆盖。
  - 模拟器在后续走查时被另一个带 DEBUG 横幅的应用占用，未继续注入、未关闭共享模拟器，避免干扰他人。
- 备注：release 仍为 debug 签名。

### T9.2 时分秒分段编辑与冒号键

- 日期：2026-10-29
- 提交：`1f7a4c4`
- 完成内容：
  - 时长输入从“整串数字右对齐分组”改为分段编辑：显示区下方新增 时/分/秒 三枚芯片，点击切换当前段，当前段橙色高亮；数字键只修改当前段。
  - 默认当前段为“时”，可直接输入 5 位小时数（如 `96` 小时），解决原先无法输入大于 23 小时的问题。
  - 新增冒号键：按 时→分→秒→时 循环切换当前段，可用于输入 `96:52`；每输入一位都按 60 进制归一化，输入 `96:64` 自动变为 `97:04:00`，芯片同步显示 `97 / 04 / 00`。
  - 分/秒段限 2 位，时段限 5 位；结果仍支持“进到日/累计小时”切换。
  - 撤回键删除当前段最后一位并重新归一化；加减、正负、清空、双零行为保持不变。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：122/122 通过（新增分段点击、冒号输入、96:64 归一化用例）。
  - `flutter build apk --release`：成功，通用包 54.0MB；split 后 arm64 19.4MB、armeabi-v7a 17.0MB、x86_64 20.7MB。
- 冒烟结果：
  - 分段与冒号输入由 7 项时间页 widget 测试覆盖（`96→96:00:00`、`96:52`、`96:52:30`、`100:52:30`、`96:64→97:04:00`）。
  - 共享模拟器仍被带 DEBUG 横幅的其他应用占用，未继续注入、未关闭模拟器；设备走查未执行。
- 备注：release 仍为 debug 签名；撤回作用于归一化后的当前段显示值，不回溯进位前的原始按键序列。

### T10 汇率换算（P1）

- 日期：2026-10-29
- 提交：`9f80b27`
- 完成内容：
  - 换算首页首卡新增“汇率”，进入独立汇率换算页；沿用只读显示 + 内置 NumericKeypad，无 TextField。
  - 数据源：`open.er-api.com/v6/latest/CNY` 优先，失败回退 `api.frankfurter.dev/v1/latest?from=CNY`，单次超时 8 秒；解析时只保留 31 种已收录币种。
  - 缓存：`shared_preferences` 键 `fx.rates.v1` 保存汇率与更新时间；12 小时内直接读缓存，手动刷新始终联网。
  - 失败降级：刷新失败保留缓存并提示“网络不可用，使用缓存”；无缓存显示错误与重试，不崩溃。
  - 交互：默认 CNY→USD；金额用内置键盘输入；支持交换、复制、手动刷新、更新时间与数据来源；31 币种按常用/其他分组选择。
  - release 声明 `INTERNET` 权限；只请求公开汇率，无统计。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：143/143 通过（新增 16 项汇率单测 + 5 项页面测试）。
  - `flutter build apk --release`：成功，通用包 55.1MB；split 后 arm64 19.7MB、armeabi-v7a 17.4MB、x86_64 21.1MB。
- 冒烟结果：
  - 自建 `emulator-5560`（API 36）安装 release：实时汇率 `1 CNY = 0.14969 USD`；输入 `100` 得 `14.969 USD`；交换后 `100 USD ≈ 668.047297749 CNY`；切换 EUR 得 `≈ 89.8243035607 EUR`。
  - 手动刷新后状态变为“已更新 · 10-29 00:02 · open.er-api.com”。
  - 飞行模式下重启仍可读取缓存并换算；刷新失败提示“网络不可用，使用缓存”，结果保留。
  - 最终包日志无 `FATAL EXCEPTION`、无 RenderFlex 溢出；模拟器已关闭。
- 备注：release 仍为 debug 签名；首次使用需联网，之后可离线；未提供文字搜索（避免系统键盘），币种选择为常用/其他分组。

### T11 房贷计算（P1）

- 日期：2026-10-29
- 提交：`d56d1e7`
- 完成内容：
  - 多功能页新增房贷入口；支持商业贷款、公积金、组合贷，等额本息与等额本金。
  - 金额、利率、期限均用内置键盘（金额/利率支持小数，期限为整数）；期限 1–30 年并带 10/20/30 年预设。
  - 纯计算以“分”为单位：等额本息按年金公式求月供、逐期计息；等额本金每期本金四舍五入到分；末期用剩余本金调平，本金求和精确等于贷款额。
  - 汇总月供或首月月供、每月递减、贷款总额、总利息、总还款；明细表弹层逐期显示月供/本金/利息/剩余。
  - 校验金额 > 0、年利率 0–100%、期限 1–30 年、组合贷两部分金额均 > 0；错误时禁用明细入口。
- 闸门结果：
  - `dart format`：0 changed。
  - `flutter analyze`：No issues found。
  - `flutter test`：168/168 通过（新增 9 项核心 + 8 项控制器 + 8 项页面测试）。
  - `flutter build apk --release`：成功，通用包 55.1MB；split 后 arm64 19.7MB、armeabi-v7a 17.4MB、x86_64 21.1MB。
- 冒烟结果：
  - 自建 emulator-5560 安装 release：默认 100 万/3.1%/30 年等额本息月供 `4,270.16 元`；切等额本金首月 `5,361.11 元`、每月递减约 `7.17 元`。
  - 组合贷 100 万商贷 + 60 万公积金（3.1%/2.6%）等额本金首月 `8,327.78 元`；明细首期本金 `4,444.45`、利息 `3,883.33`、剩余 `1,595,555.55`。
  - 金额键盘为内置键盘，提示“支持小数，不能为负”；明细弹层可滚动查看多期。
  - 最终包日志无 `FATAL EXCEPTION`、无溢出；模拟器已关闭。
- 备注：release 仍为 debug 签名；不含提前还款、利率调整、LPR 浮动与手续费；已知案例 100 万/4.9%/30 年等额本息月供 `5,307.27 元`、总利息 `910,615.12 元` 由核心测试锁定。

## 5. 当前风险与注意事项

1. 百分比有“按数值/按比例”两种口径（默认按数值）；改动时两条都要测，不能只保留旧的按比例断言。
2. 表达式编辑 + 实时预览是状态机，需用 fuzz 防崩溃；任何错误态必须可恢复。
3. 日期月末夹取、闰年、反向区间是时间计算的主要 bug 源。
4. T12–T14 与 T12.1 已全部完成；新增入口必须同时具备实现、测试与标准记录。
5. 模拟器与真机必须区分；所有 adb 命令带 `-s emulator-<n>`（本次冒烟为 `emulator-5556`），不操作真机。
6. T0–T14、T12.1 与 R1–R4 已完成。release 仍为 debug 签名，正式发布前需提供 keystore 并重新构建。

## 6. 更新规则

- 每完成一个任务：更新本文件的任务状态、闸门/冒烟结果、提交号。
- 技术事实变化：同步更新 `base.md`。
- 被推翻的结论保留原句并标注，不静默删除。
- 文档更新本身也走闸门/冒烟/提交，不单独跳过。

### R1–R4 小米 17.3.9 标准复刻

- 日期：2026-10-30
- 范围：两标签壳、圆键键盘、显示区/长按菜单、历史页、设置页、换算首页 15 入口、单位全表、三行汇率与 109 币种、大写数字、进制、温度、BMI、称呼、个税、房贷清单、时间计算视觉统一、深色模式。
- 闸门：`dart format` 通过；`flutter analyze` 无问题；`flutter test` 198 项全绿；`flutter build apk --debug` 成功。
- 守卫：`test/guards/ui_standard_guard_test.dart` 锁定无系统输入框、两标签、15 入口顺序、单位/币种规模、不冒充数据源、深色纯黑。
- 冒烟：模拟器 `emulator-5554`（1080×2400）亮/暗走查；计算器、科学、历史多选、设置、换算网格、长度/单位浮层、汇率、大写、进制、称呼、BMI、个税、房贷表单与清单。
- 提交：`4e8ca3a`。
- 备注：语音播报与比例计算仍暂缓；个税城市数据不接入；表单使用内置键盘而非小米的系统键盘。

### T14 比例计算

- 日期：2026-10-30
- 范围：换算首页第 6 行第 1 列「比例计算」；按比例分配与 `a:b=c:x` 求值；表单使用系统数字键盘。
- 闸门：`dart format` 通过；`flutter analyze` 无问题；`flutter test` 201 项全绿；守卫更新为“仅表单页允许 TextField”。
- 冒烟：模拟器 1080×2400 走查比例分配 1:2/100、求值 2:3=4:x。
- 提交：`9552af9`。
- 备注：比例结果为最多 6 位小数；输入校验覆盖 A+B=0、a=0、负数。

### T12.1 个税省级社保基数

- 日期：2026-10-30
- 范围：内置 31 省 2025 社保年度平均工资/基数上下限（人社通公开汇总）；个税所在地选择省份后按平均工资 × 个人费率 10.5% 估算五险一金，可手动修改；提示不含公积金。
- 闸门：`dart format` 通过；`flutter analyze` 无问题；`flutter test` 203 项全绿。
- 冒烟：模拟器选择北京，五险一金自动填入 `1253.39`，提示基数 `7,162–35,811`。
- 提交：`d25b57e`。
- 备注：只到省级，不冒充城市级；数据需随年度政策更新。
