# 幻念多功能计算器 · 技术基线

> 最后更新：2026-10-30
> 维护规则：稳定技术事实写入本文档；任务状态、闸门/冒烟/提交记录写入 [roadmap.md](roadmap.md)。

## 1. 软件信息

| 项目 | 值 |
|---|---|
| 软件名 | 幻念多功能计算器 |
| 包名 / applicationId / namespace | `com.fnthink.FnthinkCalculator` |
| 当前版本 | `1.0.0+1` |
| 平台 | Android（首版）；Flutter 代码保持跨平台 |
| 语言 | 简体中文 |
| 最低系统 | Android 8.0（API 28） |
| 目标系统 | API 37 |
| 编译 SDK | API 37 |
| 屏幕 | 竖屏为主；科学模式支持横屏；适配平板最大宽度 |
| 主题 | 亮色 + 深色，跟随系统并可手动切换 |
| 网络 | 汇率换算需 INTERNET（release 已声明）；其余功能离线可用 |
| 广告 / 统计 | 无广告、无统计、无多余权限 |
| 设计参考 | 小米计算器 17.3.9 的布局、配色与交互；唯一标准见 [xiaomi-reference.md](xiaomi-reference.md)；不使用小米商标、图标、字体等素材 |

当前状态：T0–T15、T12.1、T15.1 与 R1–R4 已完成（2026-10-30，T14 `9552af9`、T12.1 `d25b57e`、T15 `160e1c1`、T15.1 `6f8e2da`）；两标签壳、整宽子页标题栏、16 个换算入口、三行汇率与 109 币种、单位全表、进制/BMI/称呼/个税（31 省社保基数）/比例、房贷清单、时间计算、系统中文 TTS 均已落地；计算器/换算用内置键盘，表单页用系统数字键盘；206 项测试与 UI 标准守卫全绿。

## 2. 技术栈

| 层 | 版本 / 选择 |
|---|---|
| Flutter | 3.47.7 stable |
| Dart | 3.13.5 |
| Gradle | 9.8.2（wrapper 走腾讯云镜像） |
| Android Gradle Plugin | 9.4.1 |
| Kotlin 编译 | AGP 9 内置 Kotlin（`android.builtInKotlin=true`） |
| Kotlin 版本来源 | `settings.gradle.kts` 中 `org.jetbrains.kotlin.android` 2.4.21，仅 classpath，`apply false` |
| JVM / 字节码 | JDK 21；`sourceCompatibility`/`targetCompatibility` = 21；`jvmTarget` = 21 |
| Android SDK | Platform 37、build-tools 37.0.0 |
| 状态管理 | `ChangeNotifier` + `ListenableBuilder`，不引入重型状态库 |
| 本地存储 | `shared_preferences` ^2.5.3（已接入） |
| 格式化 | `intl`（由 flutter_localizations 提供，直接使用待 T7/T8） |
| 网络 | `http` 1.5.0（汇率接口，release 声明 INTERNET） |
| 测试 | `flutter_test`、`integration_test`（后续需要时加入） |

### 2.1 Kotlin 编译决策

- Android 源码由 **AGP 9 内置 Kotlin** 编译，不通过 `org.jetbrains.kotlin.android` 插件 apply。
- KGP 2.4.21 只作为 classpath 依赖放在 `settings.gradle.kts`，由 Gradle 冲突解析把 AGP 自带的 KGP 抬到 2.4.21。
- AGP 9.4.1 自带 KGP 为 2.2.10；AGP 对内置 Kotlin 只设下限 2.1.0、不设上限。
- 不要把 `apply false` 改成 `apply true`，否则会重新触发 KGP 弃用警告。
- 字节码目标 21 已用 `javap -verbose` 验证，`major version: 65`。
- `android.newDsl=false` 仍保留，因为 Flutter Gradle 插件仍在使用旧 variant API；AGP 会给出弃用警告，属于已知警告。

## 3. 仓库与镜像

### 3.1 Gradle 发行包

文件：`android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-9.8.2-all.zip
```

### 3.2 Android 仓库地址

两个文件都配置同一套仓库，顺序为“阿里云优先 + 上游兜底”：

1. `android/settings.gradle.kts`：`pluginManagement.repositories`
2. `android/build.gradle.kts`：`allprojects.repositories`

顺序：

1. 当 `useUpstreamFirst=true`：`google()`、`mavenCentral()`、`gradlePluginPortal()`
2. 阿里云：
   - `https://maven.aliyun.com/repository/releases`
   - `https://maven.aliyun.com/repository/google`
   - `https://maven.aliyun.com/repository/central`
   - `https://maven.aliyun.com/repository/gradle-plugin`
   - `https://maven.aliyun.com/repository/public`
   - `https://maven.aliyun.com/repository/snapshots`
3. `https://jitpack.io`
4. `$flutterStorageBaseUrl/download.flutter.io`
5. 当 `useUpstreamFirst=false`：`google()`、`mavenCentral()`、`gradlePluginPortal()` 兜底

开关：`android/gradle.properties` 中 `useUpstreamFirst=false`。两个构建脚本都会先读 `gradle.properties`，再读 `local.properties`，因此两边行为一致。

`flutterStorageBaseUrl` 默认 `https://storage.flutter-io.cn`；可在 `android/local.properties` 覆盖 `flutter.storage.base.url`。

### 3.3 Gradle 缓存

本机 `GRADLE_USER_HOME=D:\gradle`。Gradle 9.8.2、AGP 9.4.1、Kotlin 2.4.21 已在该缓存中。

## 4. 构建、运行与测试

在项目根目录执行：

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

APK 路径：

```text
build/app/outputs/flutter-apk/app-debug.apk       # 调试
build/app/outputs/flutter-apk/app-release.apk     # 通用 release（54.0MB）
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  # arm64（19.4MB）
```

release 构建：

```bash
flutter build apk --release
flutter build apk --release --split-per-abi
```

当前 release 使用模板默认 debug 签名；正式签名需提供 keystore。

模拟器：

```bash
flutter emulators --launch ci_api34_pixel6
adb -s emulator-5556 wait-for-device
adb -s emulator-5556 shell getprop sys.boot_completed
adb -s emulator-5556 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5556 shell am start -W -n com.fnthink.FnthinkCalculator/.MainActivity
adb -s emulator-5556 exec-out screencap -p > smoke.png
adb -s emulator-5556 emu kill
```

设备约定：

- 本机模拟器为 `ci_api34_pixel6`，API 34，1080×2400，density 420。
- 所有 adb 命令必须带 `-s emulator-<n>`（本次会话为 `emulator-5554`），禁止裸 adb 指向真机。
- 冒烟结束用 `adb -s emulator-5554 emu kill` 关闭模拟器。

## 5. 目录架构

### 5.1 现有结构（T8 时点）

```text
FnthinkCalculator/
├── android/                     # Android 工程、Gradle 配置、图标资源
├── assets/icon/                 # 图标源图、512 图、自适应前景图
├── doc/
│   ├── base.md                  # 本文档
│   ├── xiaomi-reference.md      # 小米 17.3.9 UI/交互/验收标准
│   └── roadmap.md               # 任务、状态、闸门/冒烟/提交记录
├── lib/
│   ├── main.dart                # 加载 prefs，创建应用级控制器
│   ├── app/                     # app、app_scope、settings_controller、settings_repository、shell
│   ├── theme/                   # tokens、app_theme
│   ├── widgets/                 # numeric_keypad 共享数字键盘
│   ├── core/
│   │   ├── math/                # 有理数、词法、解析、AST、求值、格式化、引擎
│   │   └── utils/               # 人民币大写、日期、时长、房贷
│   └── features/
│       ├── calculator/          # 控制器、页面、历史仓库、显示/键盘/科学面板/历史弹层
│       ├── converter/           # 7 类单位、汇率币种/仓库/控制器/页面、首页与详情页
│       ├── multifunction/       # 多功能首页、大写数字、time/ 四个时间子页、mortgage/ 房贷
│       └── settings/            # 设置页
├── test/
│   ├── app/                     # 壳与设置仓库
│   ├── core/math/               # 引擎/格式化/有理数
│   ├── core/utils/              # 人民币大写、日期、时长
│   ├── features/                # 计算/换算/多功能/持久化/历史仓库
│   ├── widgets/                 # 数字键盘/规则
│   └── golden/                  # 亮/暗布局 golden
├── tool/make_icons.py           # 图标生成脚本
├── pubspec.yaml
└── analysis_options.yaml
```

### 5.2 计划结构

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp、主题、路由
│   └── shell.dart               # 顶部三标签与菜单壳
├── theme/
│   ├── app_theme.dart           # ThemeData
│   └── tokens.dart              # 颜色、圆角、间距、字号
├── core/
│   ├── math/
│   │   ├── value.dart           # 有理数 + double 数值层
│   │   ├── token.dart
│   │   ├── lexer.dart
│   │   ├── ast.dart
│   │   ├── parser.dart
│   │   ├── evaluator.dart
│   │   └── formatter.dart       # 千分位、科学计数法、≈
│   ├── storage/
│   │   ├── history_repository.dart
│   │   └── settings_repository.dart
│   └── utils/
│       ├── date_only.dart
│       ├── date_calc.dart
│       ├── duration_calc.dart
│       └── chinese_upper.dart
├── features/
│   ├── calculator/              # 标准/科学计算页与控制器
│   ├── converter/               # 7 类单位换算
│   ├── multifunction/           # 多功能页 + 时间计算
│   └── settings/                # 设置/关于
└── l10n/                        # 中文本地化资源（后续按需）

test/
├── math/
├── features/
├── utils/
└── widget/

integration_test/                # 后续需要时加入
```

## 6. 核心实现约束

### 6.1 表达式引擎

- 自研 Lexer → 递归下降解析 → AST → 求值，不引入通用表达式求值库。
- 支持：`+ - × ÷`、括号、一元负号、`^`、后缀 `!`、后缀 `%`、函数、常量 π/e。
- 按 `=` 时自动补齐未闭合的右括号；括号不匹配、非法字符返回错误对象，不抛未捕获异常。
- 键盘在需要时自动补乘号，表达式内部保持显式运算符，避免隐式乘法歧义。
- 错误类型至少包括：除以零、定义域错误、溢出、非法表达式、结果过大。

### 6.2 数值与显示

- 数值层采用“有理数 + double 超越函数”的混合方案：
  - 四则运算、百分比、整数幂用精确有理数。
  - 三角、对数、开方等用 double，显示前按有效数字收敛。
- 目标：`0.1 + 0.2 = 0.3`，不出现浮点尾数。
- 有限小数精确显示；无限小数保留 12 位有效数字并标记 `≈`；超大/超小用科学计数法。
- 负数零归一为 0；大数字千分位；显示区自适应字号并可横向滚动。
- 阶乘只接受非负整数并设上限；`0! = 1`；`0^0`、`tan(90°)` 等边界规则在实现时固定并写测试。

### 6.3 百分比口径（按小米）

| 表达式 | 结果 |
|---|---|
| `10% + 10%` | `0.11` |
| `100 + 10%` | `110` |
| `100 - 10%` | `90` |
| `100 × 10%` | `10` |
| `100 ÷ 10%` | `1000` |

规则：`A ± B% = A ± A×B%`；乘除时 `%` 按 `/100` 处理。所有边界写测试，不能按“普通数学百分比”实现。

### 6.4 日期与时间计算（T8 已实现）

- 实现文件：`lib/core/utils/date_calc.dart`、`duration_calc.dart`；页面在 `lib/features/multifunction/time/`。
- 日期用 `DateOnly` 语义，天数差用 UTC 日期计算，避免夏令时。
- 月末夹取：`1/31 + 1 月 = 2/28 或 2/29`；`2/29 + 1 年 = 2/28`。
- 日期差：按“整年 → 整月 → 剩余天数”递推，避免月末差额为负；支持含起始日开关。
- 工作日只排除周六日，界面注明不含法定节假日。
- 日期推算支持年/月/周/天、之前/之后、0–9999 数量与快捷预设。
- 时长加减使用内置计算器键盘与分段编辑：显示区下方 时/分/秒 三枚芯片可点击切换当前段，当前段橙色高亮；数字键只修改当前段，默认在“时”，可直接输入 96 小时。
- 冒号键按 时→分→秒→时 循环切换当前段；每输入一位即按 60 进制归一化，`96:52` 显示为 `96:52:00`，`96:64` 自动变为 `97:04:00`。
- 分/秒段最多 2 位、时段最多 5 位；支持加减、正负、退格/撤回、清空、双零。
- 结果格式可切换“进到日”（`1天 01:00:00`）或“累计小时”（`25:00:00`）；输入显示始终累计小时。
- 两时刻差采用 24 小时制；结束早于开始时按次日计算。
- 年龄：周岁按满年、虚岁按年份口径；2 月 29 日在非闰年按 2 月 28 日处理。
- 首批时间计算页四个子页：日期差、日期推算、时长、年龄。

### 6.5 UI

- 视觉参考小米 HyperOS 计算器：浅灰页面、白色大圆角按键、橙色运算符、橙色实心等号、顶部文字标签、右对齐大显示区。
- 亮色 tokens：主橙 `#FF6A00`，页面 `#F5F5F5`，按键 `#FFFFFF`，主文字 `#111111`，次要文字 `#8C8C8C`。
- 键盘：4 列 × 5 行，16dp 外边距、8dp 间距、圆角 22、键高约 72–76dp。
- 显示：字号 24–72sp 自适应，千分位，历史 2 行 + 历史弹层，预览行 `= ...`。
- 科学：竖屏功能条 + 标准键盘；横屏完整科学面板；`2nd`、`DEG/RAD`。
- 交互：按键缩放 + 触感；长按退格清当前，长按 C 清历史（确认），长按结果复制；错误态可一键恢复。
- 适配 360–430dp 手机、横屏、平板最大宽度、字体缩放 1.3、深色模式。

### 6.6 存储（T5 已实现）

- 使用 `shared_preferences`，键：
  - `history.v1`
  - `settings.themeMode.v1`
  - `settings.haptics.v1`
  - `settings.angleUnit.v1`
- `HistoryRepository`（`lib/features/calculator/history_repository.dart`）：JSON 序列化、200 条上限、损坏数据返回空列表。
- `SettingsRepository`（`lib/app/settings_repository.dart`）：主题模式/触感/角度单位读写。
- 应用启动时 `main` 加载 prefs，创建应用级 `CalculatorController` 并注入壳；历史不再只存在页面内存里。
- 写入为异步 fire-and-forget，UI 不被磁盘阻塞。
- 不在首版采集任何个人数据。

### 6.7 输入与键盘（T8.1/T8.2 已实现）

- 所有数值输入使用内置数字键盘，`lib/` 内不再有 `TextField`；不弹系统键盘。
- 所有内置键盘左下角提供“撤回”键：每次删除一位，可连续点击；示例 `32+25 → 32+2 → 32+`。
- 主计算器/科学计算：4×5 计算器键盘；撤回在左下角，科学切换在顶行。
- 时分秒加减：H:MM:SS 显示 + 内置键盘；时/分/秒芯片可点击单独修改，冒号键切换分段，输入按 60 进制即时归一化；左下角撤回。
- 换算详情、大写数字：只读数值显示 + 常驻 `NumericKeypad`。
- 日期推算数量：可点数量 + `showNumericKeypad` 内置键盘弹层。
- `NumericKeypad` 支持 `allowDecimal`、`allowNegative`、`showDone`；不允许的小数/正负键以禁用态显示。
- 日期/时间选择仍使用系统选择器（日历/时钟），不使用系统键盘输入。
- 共享键盘位于 `lib/widgets/numeric_keypad.dart`，复用主计算器的 `CalcKey` 样式。

### 6.8 单位换算（T7 已实现）

- 7 类：长度、面积、体积、温度、速度、时间、重量。
- 线性单位使用 BigRational 因子；温度以摄氏度为基，华氏/开尔文/兰氏度为仿射变换。
- 结果复用 `NumberFormatter`：有限小数精确显示，非终止结果标 `≈`，千分位与科学计数法一致。
- 时间明确按 `1 月 = 30 天、1 年 = 365 天`；面积标注亩按 `2000/3 m²`。
- 单位选择器为底部弹层；详情页支持实时输入、交换、复制。
- 未做输入持久化；离开页面后输入不保留。

### 6.9 汇率换算（T10 已实现）

- 入口：换算首页首卡“汇率”；实现文件在 `lib/features/converter/currency_page.dart`、`currency_controller.dart`、`exchange_rate_repository.dart`、`currency_data.dart`。
- 数据源：先请求 `open.er-api.com/v6/latest/CNY`，失败回退 `api.frankfurter.dev/v1/latest?from=CNY`；单次超时 8 秒。
- 缓存：`shared_preferences` 键 `fx.rates.v1`，保存 CNY 基准汇率、接口更新时间与获取时间；12 小时内直接读缓存，过期后刷新。
- 降级：刷新失败时保留缓存并提示“网络不可用，使用缓存”；无缓存时显示错误与重试入口，不影响其他页面。
- 币种：31 种常用币种；选择器按“常用/其他币种”分组，未做文字搜索，避免弹出系统键盘。
- 换算：金额与汇率均走 BigRational；结果复用 `NumberFormatter`；支持交换、复制、手动刷新，并显示更新时间与数据来源。
- 权限：release 声明 `INTERNET`，仅用于请求公开汇率；无统计、不上传用户数据。

### 6.10 房贷计算（T11 已实现）

- 入口：多功能页“房贷计算”；页面在 `lib/features/multifunction/mortgage/`，纯计算在 `lib/core/utils/mortgage_calc.dart`。
- 类型：商业贷款、公积金、组合贷；组合贷共用期限，分别输入商贷与公积金的金额、年利率。
- 方式：等额本息、等额本金；金额与利率用内置键盘弹层输入，期限支持 1–30 年与 10/20/30 年预设。
- 计算：全部以“分”为整数单位；等额本息按年金公式求月供并四舍五入到分，逐期计息；等额本金每期本金四舍五入到分；末期用剩余本金调平，保证本金求和等于贷款额。
- 结果：月供（等额本息）或首月月供与每月递减（等额本金）、贷款总额、总利息、总还款；明细表在底部弹层，逐期显示月供/本金/利息/剩余。
- 校验：金额 > 0、年利率 0–100%、期限 1–30 年；组合贷两部分金额均需 > 0；错误时禁用明细入口。
- 口径：不含提前还款、利率调整、LPR 浮动与手续费；结果仅供参考。

### 6.11 图标

- 设计：橙色底、白色计算器机身、深色屏幕、灰色按键、橙色等号键；48px 下仍可辨认。
- 源图：`assets/icon/app_icon_source.png`。
- 生成脚本：`tool/make_icons.py`。
- 输出：mdpi～xxxhdpi 的 `ic_launcher.png`、`ic_launcher_round.png`、`ic_launcher_foreground.png`，以及 `mipmap-anydpi-v26` 自适应图标。
- 自适应背景色：`#FD6500`。

## 7. 闸门、冒烟与提交

### 7.1 闸门测试

每个任务完成后至少执行：

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

要求：

- format 无改动、退出码 0。
- analyze 无 issue。
- 单元/组件测试全部通过。
- debug APK 构建成功。

涉及 Android/Gradle 配置时额外核对：

```bash
adb -s emulator-5556 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5556 shell am start -W -n com.fnthink.FnthinkCalculator/.MainActivity
```

### 7.2 冒烟测试

- 启动模拟器 `ci_api34_pixel6`，安装 debug APK，冷启动。
- 走查本任务新增的主路径；截图留证（临时目录即可，不入库）。
- 检查 `logcat` 无 `FATAL EXCEPTION`、无未捕获异常。
- 涉及持久化、日期、贷款、个税的任务，额外手工输入至少 3 组边界值。
- 冒烟结束关闭模拟器：`adb -s emulator-5556 emu kill`。

### 7.3 提交

- 每个任务一个本地 commit；只在本地提交，**不 push、不 tag、不部署**。
- 提交前 `git status` 检查，`git add` 指定文件，不使用 `git add -A`。
- 构建产物、`.dart_tool/`、`.idea/`、`local.properties`、keystore 不入库。
- 中文提交信息通过临时 `.txt` + `git commit -F`，避免编码问题。
- 提交后再开始下一个任务。

## 8. 已知警告与决策

1. `android.newDsl=false` 会触发 AGP 弃用警告；Flutter Gradle 插件仍依赖旧 variant API，暂时保留。等 Flutter 支持新 DSL 后再移除。
2. `android.builtInKotlin=true`，KGP 不 apply；`settings.gradle.kts` 的 2.4.21 仅用于抬高 classpath 版本。
3. 不要将 `org.jetbrains.kotlin.android` 改为 apply true；会重新触发 KGP 弃用警告。
4. Java/Kotlin 字节码目标 21 已验证；不要再改回 17，除非明确要求。
5. release 已声明 `INTERNET`（T10 汇率）；仅用于请求公开汇率接口，不做统计或上传用户数据。
6. T11 房贷、T12 个税、T13 称呼、T14 比例均已完成（个税/称呼并入 R3 复刻）。release 使用模板默认 debug 签名，正式发布前需提供 keystore 并重新构建。

## 9. 范围与非目标

### 首版（T2–T9）

- 标准计算、科学计算、历史记录、复制/大写、7 类单位换算、设置/深色模式。
- 时间计算：日期差、日期推算、时长加减、年龄计算。
- 质量收口：fuzz、golden、无障碍、模拟器走查、APK。

### 第二批（P1）

- 汇率换算（T10）、房贷计算（T11）已完成。
- 小米 17.3.9 复刻批次 R1–R4 已完成：两标签、换算首页 16 入口、单位/汇率、大写、进制、BMI、称呼、个税、比例、房贷清单；标准见 [xiaomi-reference.md](xiaomi-reference.md)。
- T12–T14 与 T12.1（省级社保基数）全部完成；计算器/换算保留内置键盘，表单页（个税/房贷/BMI/比例）使用系统数字键盘。

### 非目标

- 首版不做 iOS/Web/Windows 发布包。
- 不做账号、云同步、广告、统计。
- 不使用小米商标、图标、字体素材。

## 10. 文档维护

- 每个任务完成后更新 [roadmap.md](roadmap.md)：状态、实现方式、闸门/冒烟结果、提交号。
- 技术事实变化时同步更新本文档；被推翻的旧结论保留原句并标注。
- 文档不写真实域名、密钥、签名信息；签名与发布信息后续单独管理。
