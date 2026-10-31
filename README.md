<div align="center">

<img src="assets/icon/app_icon_512.png" width="128" alt="幻念计算器">

# 幻念计算器

按小米计算器 17.3.9 的界面与交互标准复刻的 Flutter Android 计算器。两标签壳、19 个功能入口、109 种货币、完整单位表、时间四页，以及完全离线的按键与结果语音播报。

[![Flutter](https://badgen.net/badge/Flutter/3.47.7/02569B?icon=flutter)](https://flutter.dev/)
[![AGP](https://badgen.net/badge/AGP/9.4.1/3DDC84?icon=android)](https://developer.android.com/build/releases/gradle-plugin)
[![Gradle](https://badgen.net/badge/Gradle/9.8.2/02303A?icon=gradle)](https://gradle.org/)
[![Platform](https://badgen.net/badge/Platform/Android%208.0%2B/3DDC84?icon=android)](#技术栈)
[![Version](https://badgen.net/badge/Version/1.0.0%2B1/007AFF?icon=android)](#版本与变更)
[![Tests](https://badgen.net/badge/Tests/208%20passed/green)](#质量保障)
[![ABI](https://badgen.net/badge/ABI/arm64-v8a/3DDC84?icon=android)](#构建与签名)

</div>

## 目录

- [简介](#简介)
- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [权限说明](#权限说明)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [构建与签名](#构建与签名)
- [质量保障](#质量保障)
- [数据与隐私](#数据与隐私)
- [已知限制](#已知限制)
- [版本与变更](#版本与变更)

---

## 简介

幻念计算器是一款离线优先的 Android 计算器，用 Flutter 重做小米计算器 17.3.9 的界面与交互。界面尺寸、配色、键盘布局、表单键盘口径都以 [小米计算器复刻开发标准](doc/xiaomi-reference.md) 为准，不使用小米商标、图标、字体等素材。

应用只有两个顶层标签：

- **计算** —— 标准/科学计算、历史记录、结果复制与大写转换
- **换算** —— 汇率、7 类单位、进制、时间四页，以及个税、房贷、BMI、称呼、比例、大写数字等工具

除汇率刷新外，所有计算、历史、设置和语音都在本机完成；没有账号、广告、统计或云同步。

---

## 功能特性

### 计算

- **标准 / 科学双模式** —— 标准键盘 5×4、科学键盘 7×5，正圆按键与橙色强调色；支持 `+ − × ÷`、括号、百分号、正负号、退格与清空
- **科学函数** —— 三角函数与反三角函数、`ln` / `lg`、`10ˣ` / `eˣ`、平方根 / 平方、乘方、阶乘、倒数、`π` / `e`；第二功能键切换反函数与逆运算，支持角度 / 弧度
- **精确运算核心** —— 有理数与表达式解析/求值/格式化分层，整数与常见小数尽量保持精确；无法整除时按显示规则取近似值
- **完整显示区** —— 最近一条历史、当前表达式、实时预览、主结果与大写行；长按结果可复制或转换为大写数字
- **历史记录** —— 本地持久化，全页列表，多选复制/删除，一键清空
- **百分数两种口径** —— 设置页可选「按数值计算」与「按比例计算」，后者用于折扣等场景
- **按键与结果语音** —— 默认关闭，开关持久化；48 个离线 MP3（合计 157.5 KiB），逐键顺序播放，不依赖系统 TTS、不联网
- **使用偏好** —— 按键震动、浅色/深色/跟随系统主题

### 换算

- **7 类 104 个单位** —— 长度 27、面积 19、体积 14、重量 21、温度 5、速度 9、时间 9；多行联动换算，锚定选择器直接切换单位
- **汇率** —— 109 种货币，默认 CNY / USD / EUR 三行联动；显示汇率来源与更新时间；成功拉取后本地缓存，断网时回退缓存并在界面标明
- **进制** —— 二 / 八 / 十 / 十六进制实时互转，内置数字键盘
- **内置键盘** —— 计算器与换算页使用自绘圆键键盘；个税、房贷、BMI、比例等表单页按小米口径使用系统数字键盘

### 时间

- **日期差** —— 公历天数与工作日差；工作日口径只排除周六日，不含法定节假日
- **日期推算** —— 按年 / 月 / 日前后推算；月末自动夹取到目标月份最后一天
- **时长计算** —— 时长加减与两时刻差；支持进到日 / 累计小时口径，两时刻差按 24 小时制
- **年龄计算** —— 周岁 / 虚岁 / 天数，并给出下次生日倒计时
- 日期选择使用系统日历，数量与时分秒使用内置键盘

### 生活工具

- **个税计算** —— 月薪与年终奖两种模式；支持专项附加扣除；选择 31 个省级地区后，按当地 2025 社保年度平均工资与个人费率 10.5% 估算五险一金（不含公积金），金额可手动修改；结果给出应纳税所得额、适用税率、速算扣除数与税后收入
- **房贷计算** —— 商业贷款 / 公积金贷款 / 组合贷款；等额本息与等额本金；期限 1–40 年；LPR + 基点或基准利率；首次还款日期；结果页给出月供、总利息与逐年还款明细
- **BMI 计算** —— 身高体重输入、BMI 结果、偏瘦 / 正常 / 超重 / 肥胖分级、渐变刻度与建议体重
- **称呼计算** —— 最长 8 段关系链，支持正向称呼与「TA 称呼我」互查
- **比例计算** —— 按 `A : B` 分配总额，或求解 `a : b = c : x`；结果保留最多 6 位小数
- **大写数字** —— 人民币大写，支持万 / 亿 / 万亿、角 / 分；超出范围给出明确提示

### 界面与交互

- 两标签胶囊导航；子页统一整宽标题栏，返回键固定在左侧
- 换算首页 3 列网格（宽屏 4 列），共 19 个固定顺序入口
- 小米口径配色：`#FF6900` 强调色、浅色 `#F3F3F3` 背景、深色模式纯黑
- 长按显示区弹出复制 / 大写菜单；长按历史条目进入多选
- 计算器/换算内置键盘与表单系统键盘的边界由 UI 标准守卫锁定

---

## 技术栈

| 模块 | 技术 |
|------|------|
| 前端 | Flutter 3.47.7（Dart 3.13.5） |
| 状态管理 | `ChangeNotifier` + `InheritedNotifier`（`AppScope`），不引入第三方状态框架 |
| 本地存储 | `shared_preferences`（历史、设置、汇率缓存） |
| 网络 | `http` 1.5.0，仅用于汇率请求；来源 `open.er-api.com`，失败回退 `api.frankfurter.dev` |
| 音频 | `audioplayers` 6.8.1 + 内置 MP3 短音；构建期由 Edge TTS 生成 |
| 计算核心 | 自研有理数、词法、解析、AST、求值、格式化与引擎 |
| 原生侧 | Android Kotlin（Flutter 默认 `FlutterActivity`，无自建原生服务） |
| 构建 | Gradle 9.8.2 + AGP 9.4.1（内置 Kotlin）+ JDK 21 |
| Android SDK | minSdk 28 / compileSdk 37 / targetSdk 37 |
| 测试 | `flutter_test`：单元、widget、golden、无障碍、fuzz、UI 标准守卫 |
| 打包 | 纯 arm64-v8a release APK，本地 keystore 签名 + 纯净度检查 |
| 图标生成 | `tool/make_icons.py`（Pillow，白底圆角 + 符号 + 橙色等号键） |
| 语音生成 | `tool/generate_voice_clips.py`（edge-tts + imageio-ffmpeg，`zh-CN-XiaoxiaoNeural`） |
| 界面语言 | 简体中文（Material 组件 `zh_CN` 本地化） |
| CI | 无；静态检查、测试、打包与纯净检查均在本地执行 |

---

## 权限说明

| 权限 | 用途 |
|------|------|
| `INTERNET` | 拉取公开汇率数据；不用于统计、账号或上传用户内容 |

应用不申请存储、定位、通讯录、相机、通知等权限；历史记录与设置只写入应用私有存储。

---

## 项目结构

```text
FnthinkCalculator/
├── lib/                              # Flutter 源码（69 个 Dart 文件）
│   ├── main.dart                     # 加载 prefs，创建应用级控制器
│   ├── app/                          # AppScope、SettingsController、两标签壳
│   ├── theme/                        # 颜色 token 与 Material 3 主题
│   ├── widgets/                      # PageHeader、NumberFormField、圆键键盘等
│   ├── core/
│   │   ├── math/                     # 有理数、词法、解析、AST、求值、格式化、引擎
│   │   ├── utils/                    # 人民币大写、日期、时长、房贷、个税、社保、称呼
│   │   └── voice/                    # 语音片段映射与离线播放服务
│   └── features/
│       ├── calculator/               # 控制器、页面、显示/键盘/历史
│       ├── converter/                # 单位、汇率、进制、换算首页
│       ├── multifunction/            # 时间四页、个税、房贷、BMI、称呼、比例、大写
│       └── settings/                 # 百分数算法、角度、语音、震动、主题
├── android/                          # Android 工程、签名读取、自适应图标
├── assets/
│   ├── icon/                         # 图标源图与 512 图
│   └── voice/                        # 48 个离线 MP3
├── doc/
│   ├── base.md                       # 技术基线
│   ├── xiaomi-reference.md           # 小米 17.3.9 UI/交互/验收标准
│   ├── roadmap.md                    # 任务状态与闸门记录
│   └── update.md                     # 版本变更记录
├── test/                             # 38 个测试文件
├── tool/
│   ├── build_release_arm64.sh        # 签名 release 打包 + 纯净检查
│   ├── check_apk_purity.sh           # ABI/密钥/模型/测试资源检查
│   ├── generate_voice_clips.py       # 构建期生成离线语音
│   └── make_icons.py                 # 生成启动图标与自适应图标
├── pubspec.yaml                      # version: 1.0.0+1
└── README.md
```

---

## 快速开始

### 环境要求

| 工具 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.47.7 | 项目按 3.47.7 开发与验证 |
| Dart | 3.13.5 | 随 Flutter 自带，`pubspec.yaml` 声明 `sdk: ^3.13.5` |
| JDK | 21 | AGP 9.x 要求 |
| Gradle | 9.8.2 | 项目已配置 wrapper |
| AGP | 9.4.1 | 项目已配置 |
| Android SDK | API 37 | compileSdk / targetSdk；最低运行 API 28 |
| Python 3 + Pillow | 可选 | 仅重新生成图标时需要 |
| edge-tts + imageio-ffmpeg | 可选 | 仅重新生成语音片段时需要，构建期联网，运行期不需要 |

### 常用命令

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

调试包输出：`build/app/outputs/flutter-apk/app-debug.apk`。

### 重新生成资源

```bash
# 启动图标（assets/icon + android/app/src/main/res/mipmap-*）
python tool/make_icons.py

# 离线语音（需要联网，产物已提交到 assets/voice/）
python tool/generate_voice_clips.py
```

---

## 构建与签名

发布包统一走脚本：

```bash
bash tool/build_release_arm64.sh
```

脚本会执行 `flutter build apk --release --target-platform android-arm64`，随后调用 `tool/check_apk_purity.sh` 检查 ABI、密钥/模型/测试残留与证书类型。

单独检查已有 APK：

```bash
bash tool/check_apk_purity.sh build/app/outputs/flutter-apk/app-release.apk
```

签名约定：

- Gradle 从 `android/key.properties` 读取签名配置，`storeFile` 指向仓库外的 keystore
- `android/key.properties`、`*.jks`、`*.keystore` 已加入 `.gitignore`，**禁止提交或上传**
- 缺少 `key.properties` 时回退 debug 签名，仅用于本机开发；发布包必须通过纯净检查
- 当前构建：`1.0.0+1`，纯 arm64-v8a，约 19.7MB；每次构建的大小与 SHA-256 见 [doc/update.md](doc/update.md)

纯净检查通过时输出 `PURITY CHECK PASSED`，并打印 APK 大小与 SHA-256。

---

## 质量保障

当前读数（2026-10-31）：

| 读数 | 值 |
|------|----|
| `flutter test` | 208 例全绿 |
| 测试文件 | 38 个 |
| Dart 源码 | 69 个文件 / 约 1.43 万行 |
| 测试代码 | 约 4,074 行 |
| `flutter analyze` | 无问题 |
| release APK | 纯 arm64-v8a / 19.7MB / 非 debug 签名 |

测试覆盖：

- **数学核心** —— 有理数、词法、解析、求值、格式化、引擎边界
- **计算器** —— 控制器、科学函数、历史持久化、页面交互、无障碍、golden、一万条随机按键 fuzz
- **换算** —— 单位数据规模、页面联动、汇率缓存/降级、进制转换
- **工具** —— 时间四页、个税、房贷控制器、BMI、称呼、比例、大写
- **语音** —— 片段映射、资源数量与大小（<1MB）
- **UI 标准守卫** —— 两标签、19 入口固定顺序、104 个单位/109 币种规模、系统输入框白名单、深色纯黑、不冒充数据来源

发布前闸门：

```bash
flutter analyze
flutter test
bash tool/build_release_arm64.sh   # 打包 + 纯净检查
```

本项目没有配置 CI；以上命令就是发布前的完整本地闸门。

---

## 数据与隐私

- **不上传用户数据** —— 无账号、无广告、无统计 SDK、无云同步
- **本地存储** —— 历史记录、设置、汇率缓存只保存在应用私有存储
- **汇率** —— 仅向公开汇率接口发送货币代码请求；成功后缓存，断网时使用缓存并提示数据时间；界面显示来源与更新时间
- **语音** —— 音频在构建期生成并随包分发，运行时不调用系统 TTS、不联网
- **个税数据** —— 31 个省级地区的社保基数为 2025 社保年度公开汇总的静态表；五险一金按个人费率 10.5% 估算（不含公积金），结果可手动修正，仅作参考
- **签名** —— keystore 与 `key.properties` 均不入库，仓库只保留读取逻辑

---

## 已知限制

- 仅发布 Android 包；Flutter 代码保持跨平台，但未提供 iOS / Web / 桌面发布物
- 汇率最新值需要联网；离线时只能使用上次成功缓存
- 个税社保基数为省级年度静态估算，不代表具体城市的最新政策；不含公积金，实际金额以当地社保口径为准
- 语音为固定中文短音，不支持自定义音色或朗读任意文本
- 计算器与换算页使用内置键盘；个税、房贷、BMI、比例等表单页按小米口径使用系统数字键盘
- 界面复刻小米计算器 17.3.9 的布局与交互，但不包含其商标、图标、字体等素材

---

## 版本与变更

- 当前版本：`1.0.0+1`
- 版本变更记录：[doc/update.md](doc/update.md)
- 技术基线：[doc/base.md](doc/base.md)
- UI/交互标准：[doc/xiaomi-reference.md](doc/xiaomi-reference.md)
- 任务与闸门记录：[doc/roadmap.md](doc/roadmap.md)
