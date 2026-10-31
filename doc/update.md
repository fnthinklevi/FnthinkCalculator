# 幻念计算器 · 版本变更记录

> 用途：记录每个版本/构建批次对用户可见的改动、验证结果与提交号。
> 维护规则：
> - 每次发版或交付安装包必须新增一条记录；只记录已完成并验证的改动。
> - 版本号以 `pubspec.yaml` 的 `version` 为准；开发中的连续构建用日期批次区分。
> - 不写密码、keystore 路径、签名口令等敏感信息。
> - 技术事实写入 [base.md](base.md)，任务状态/闸门写入 [roadmap.md](roadmap.md)，UI/交互标准见 [xiaomi-reference.md](xiaomi-reference.md)。

## 版本规则

- 正式版本：`A.B.CC+BUILD`；补丁位 `CC` 固定两位（如 `0.2.01+5`），不得写 `0.2.1`。
- 内部构建：在当前版本下按日期/批次记录，例如 `0.2.01+5 · 2026-10-31`。
- 已发布的 `0.2.0+4` 是规则生效前的历史版本，tag 不移动；下一版本从 `0.2.01+5` 开始。
- 同一版本多次构建时，记录最新构建的 APK 大小、SHA-256 与签名状态。
- 只写用户可感知的变化；纯重构、文档更新可归入“维护”小节。

---

## 0.2.01+5（2026-10-31 发布，tag `v0.2.01`）

当前构建：

- 平台：Android，纯 arm64-v8a。
- APK：`build/release/FnthinkCalculator_0.2.01.apk`（构建输出：`build/app/outputs/flutter-apk/app-release.apk`），19.7MB。
- SHA-256：`a30ce9cf295d6f9992827b9f1845b5a060241044888c2f10b99c0a9aee2dc748`
- 签名：真实 keystore（`CN=fnthinklevi`），非 debug。
- 测试：225 项全绿；`tool/check_apk_purity.sh` 通过。

### 2026-10-31 发布 0.2.01+5

- 提交：`f69e2a6`（版本准备）
- 版本：按新规则 `A.B.CC+BUILD` 发布 `0.2.01+5`；补丁位固定两位，设置页显示同步为 `0.2.01`。应用功能与 0.2.0+4 一致。
- 规则：`0.2.0+4` 作为规则生效前的历史构建保留，tag `v0.2.0` 不移动；`tool/release.sh` 与 `release-check` workflow 已强制 `A.B.CC`。
- 闸门：格式检查、`flutter analyze`、225 项测试通过；签名纯 arm64 19.7MB；SHA-256 `a30ce9cf295d6f9992827b9f1845b5a060241044888c2f10b99c0a9aee2dc748`；`PURITY CHECK PASSED`。
- 模拟器：`ci_api34_pixel6` integration smoke 通过；发行 APK 安装成功，`versionName=0.2.01`、`versionCode=5`；模拟器已关闭，真机未安装。
- GitHub Release：`v0.2.01` 发布并上传 `FnthinkCalculator_0.2.01.apk`（此前 0.2.0+4 无 GitHub Release）。

---

## 0.2.0+4（历史构建，tag `v0.2.0`）

历史构建：

- 平台：Android，纯 arm64-v8a。
- APK：`build/release/FnthinkCalculator_0.2.0.apk`（构建输出：`build/app/outputs/flutter-apk/app-release.apk`），19.7MB。
- SHA-256：`76baa08f615114a0e5c76cc0f3ce8d65fc366a42f0b55fa887b8f53c73b15fd2`
- 签名：真实 keystore（`CN=fnthinklevi`），非 debug。
- 测试：225 项全绿；`tool/check_apk_purity.sh` 通过。

### 2026-10-31 发布 0.2.0+4

- 提交：`b1af9fc`（版本准备）
- 版本：`0.1.1+3 → 0.2.0+4`；设置页版本显示同步为 `0.2.0`。
- 新增/改进：时间计算与时差计算拆为两个独立页，时间计算入口位于换算首页首行靠前位置（共 20 个入口）；时间键盘第一行改为 `C / 00 / ± / ⌫`，0 跨两格、冒号单格、等号跨第 4–5 行；新增首启隐私弹窗、完整隐私政策页与设置页底部入口，删除“数据保存”条目。
- 修复：时长连续公式与结果后续算；计算器重复等号重复写历史；单位换算中间运算符误报“算式格式不正确”。
- 工程：新增计算链闸门、模拟器 integration smoke、GitHub `ci.yml` / `smoke.yml` / `release-check.yml`；debug 保留 x86_64，release 保持纯 arm64。
- 闸门：格式检查、`flutter analyze`、225 项测试通过；签名纯 arm64 19.7MB；SHA-256 `76baa08f615114a0e5c76cc0f3ce8d65fc366a42f0b55fa887b8f53c73b15fd2`；`PURITY CHECK PASSED`。
- 模拟器：`ci_api34_pixel6`（API 34 / x86_64）integration smoke 通过；发行 APK 安装成功，`versionName=0.2.0`、`versionCode=4`；首启隐私弹窗显示，同意后重启不再弹；模拟器已关闭，真机未安装。
- 未覆盖：语音实际声音、离线汇率缓存、完整个税/房贷结果、系统软键盘（AVD 硬件键盘）、折叠铰链；完整人工冒烟清单未逐项重跑。

---

## 0.1.1+3（2026-10-31 已发布，tag `v0.1.1`）

历史构建：

- 平台：Android，纯 arm64-v8a。
- APK：`build/release/FnthinkCalculator_0.1.1.apk`（构建输出：`build/app/outputs/flutter-apk/app-release.apk`），19.7MB。
- SHA-256：`6803e2d5d989fc4fd184ba86351947815cda79a5f522e19d522ee022dbf7efc7`
- 签名：真实 keystore（`CN=fnthinklevi`），非 debug。
- 测试：212 项全绿；`tool/check_apk_purity.sh` 通过。

### 2026-10-31 发布 0.1.1+3

- 提交：`5150ae3`（版本准备）
- 版本：`0.1.0+2 → 0.1.1+3`；设置页版本显示同步为 `0.1.1`。应用功能与 0.1.0+2 一致，本批次为发版流程与格式整理后的重新构建。
- 维护：新增 [release.md](release.md) 标准发版流程与 `tool/release.sh`，标准冒烟改为 Android 模拟器（`58d1d15`、`b332540`、`9ccc4be`、`e4cf737`）。
- 闸门：格式检查、`flutter analyze`、212 项测试通过；签名纯 arm64 19.7MB；SHA-256 `6803e2d5d989fc4fd184ba86351947815cda79a5f522e19d522ee022dbf7efc7`；`PURITY CHECK PASSED`。
- 模拟器核心冒烟：AVD `ci_api34_pixel6`（API 34 / x86_64 / 1080×2400 / 420dpi）；arm64 包安装成功，`versionName=0.1.1`、`versionCode=3`；冷启动、`1+2=3`、换算联动、汇率联网、大写/进制、时长退格去重、日期差、历史、深色、横屏分栏、1000×800 平板 6 列与 900dp 上限通过；logcat 无 FATAL/ANR。
- 未覆盖：语音实际声音、离线汇率缓存、完整个税/房贷结果、系统软键盘（AVD 硬件键盘模式）、其余时间页与折叠铰链。真机未安装。
- 备注：模拟器已关闭；真机仍为 `0.1.0+2`。`v0.1.1` tag 已创建并推送。

---

## 0.1.0+2（2026-10-31 已发布，tag `v0.1.0`）

历史构建：

- 平台：Android，纯 arm64-v8a。
- APK：`build/app/outputs/flutter-apk/app-release.apk`，19.7MB。
- SHA-256：`cc0f787e63810d93b3122a2f2d5a7e6084981ce3813e1e3f0899b7c88bf15241`
- 签名：真实 keystore（`CN=fnthinklevi`），非 debug。
- 测试：212 项全绿；`tool/check_apk_purity.sh` 通过。

### 2026-10-29 基础版本

- 提交：`d56d1e7`、`abd146f`
- 内容：T0–T11 基线，标准/科学计算、历史、设置、7 类单位换算、时间计算、人民币大写、汇率（缓存/断网降级）、房贷计算、内置数字键盘。

### 2026-10-30 小米 17.3.9 复刻 R1–R4

- 提交：`4e8ca3a`、`aec3587`
- 界面：两标签胶囊（计算/换算）、正圆键、标准/科学键盘重排、显示区历史带/表达式/预览/结果/大写行、历史全页多选、设置页百分数算法、深色模式纯黑。
- 换算：3 列图标网格；单位多行联动与锚定选择器；汇率三行联动、109 币种、来源/更新时间。
- 工具：新增进制、BMI、称呼（互查）、个税（月薪/年终奖）、房贷清单结果页；房贷支持 40 年、LPR/基点、组合贷。
- 验证：198 项测试 + UI 标准守卫。

### 2026-10-30 T14 比例计算与表单键盘

- 提交：`9552af9`、`4f13831`
- 新增「比例计算」：按比例分配、`a:b=c:x` 求值。
- 换算首页增至 16 入口。
- 个税/房贷/BMI/比例表单改用系统数字键盘，与小米表单一致。
- 验证：201 项测试。

### 2026-10-31 T12.1 个税省级社保基数

- 提交：`d25b57e`、`2c036e8`
- 内置 31 省 2025 社保基数/平均工资静态表；选择省份后按平均工资 × 10.5% 估算五险一金，可手动修改。
- 明确标注省级、数据年度、不含公积金。
- 验证：203 项测试。

### 2026-10-31 语音播报与标题栏修复

- 提交：`160e1c1`、`6f8e2da`、`879106c`、`95d7eff`、`bf60d5c`
- 语音：最终使用 Microsoft Edge TTS `zh-CN-XiaoxiaoNeural` 构建期生成 48 个单音 MP3（约 157.5 KiB），随包离线播放；不依赖系统 TTS/MVS，不内置模型。
- 标题栏：修复所有子页标题栏被标题收缩、返回键被覆盖的问题；返回键固定在左侧，标题居中。
- 验证：真机安装；208 项测试；语音开关持久化，按键/结果播报。

### 2026-10-31 T16 签名与纯 arm64 包

- 提交：`1e71501`、`45301c7`
- release 使用仓库外 keystore 本地签名；`android/key.properties` 与 keystore 已 gitignore，禁止上传。
- Gradle 过滤非 arm64 原生库；新增 `tool/build_release_arm64.sh` 与 `tool/check_apk_purity.sh`。
- 纯净检查：仅 arm64-v8a；无 armeabi-v7a/x86/x86_64、密钥、模型、裸 WAV、诊断/测试资源；证书非 debug。
- 验证：`PURITY CHECK PASSED`；包体 20.0MB。

### 2026-10-31 T17 时间计算拆四页

- 提交：`bf60d5c`、`dbb23e6`
- 移除「时间计算」聚合页，拆为日期差、日期推算、时长计算、年龄计算四个独立页。
- 换算首页共 19 个入口；四页统一 PageHeader、字号/边距/卡片样式；日期选择用系统日历，数量/时分秒用内置键盘。
- 验证：原日期差/推算/时长/年龄测试逐页通过；19 入口顺序守卫通过。

### 2026-10-31 应用改名与启动图标

- 提交：`e68b6c5`
- 名称：软件名由「幻念多功能计算器」改为「幻念计算器」；桌面名称、应用标题、README 与文档标题同步；包名 `com.fnthink.FnthinkCalculator` 不变。
- 图标：白色圆角底、黑色 `+ − ×`、橙色等号键；同步自适应图标（白色背景层、前景缩入安全区）与各密度 legacy / round / foreground。
- 工具：`tool/make_icons.py` 可复现生成。
- 验证：`flutter analyze` 无问题；208 项测试全绿；签名纯 arm64 包 19.7MB、SHA-256 `d822cad62abb6f38c2b60cf803bb8f9f48776ce195694a9240c78535dfef0296`、`PURITY CHECK PASSED`；真机 2410DPN6CC 安装并启动正常。
- 备注：若桌面仍显示旧图标，为启动器图标缓存；APK 内已确认是新图标，重启桌面或手机后刷新。

### 2026-10-31 时长键盘去重

- 提交：`a8cf830`
- 修复：时长计算键盘同时存在顶部退格键与左下角「撤回」键，两者调用同一删除逻辑；移除左下角重复键，保留顶部标准位置，0 键恢复为跨 3 列。
- 验证：`flutter analyze` 无问题；208 项测试全绿（新增「只有一个退格键」断言）；签名纯 arm64 包 19.7MB、SHA-256 `3e931529e0830b73051a9a4910fbc2bdb774d421095a1deab78b0b54b71800cf`、`PURITY CHECK PASSED`；真机 2410DPN6CC 覆盖安装成功（lastUpdateTime 2026-10-31 12:03:45）。

### 2026-10-31 依赖维护

- 提交：`4491673`
- 维护：`cupertino_icons` 由 1.0.9 升级到 2.0.0（`pubspec.yaml` 约束 `^2.0.0`）；当前代码未直接使用 `CupertinoIcons`，无用户可见变化。
- 验证：`flutter analyze` 无问题；208 项测试全绿。
- 备注：本次仅更新依赖，未重新打包；随后由版本号订正批次重新构建。

### 2026-10-31 版本号订正

- 提交：`3df9b59`
- 版本：`pubspec.yaml` 由 `1.0.0+1` 订正为 `0.1.0+2`；设置页版本显示同步为 `0.1.0`。
- 构建：签名纯 arm64 APK 19.7MB、SHA-256 `945f9a0d4b0466ea530519e5bf439b4d0be8750318b2438e4eee41e0b3f4b9d1`、`PURITY CHECK PASSED`；`versionName=0.1.0`、`versionCode=2`；真机 2410DPN6CC 覆盖安装成功（lastUpdateTime 2026-10-31 12:15:54）。
- 验证：`flutter analyze` 无问题；208 项测试全绿。

### 2026-10-31 大屏与折叠屏适配

- 提交：`a86b583`
- 适配：应用级 900dp 内容上限，超宽屏整体居中并保留主题背景；换算首页按 560/760/880dp 断点切换 3/4/5/6 列；折叠内屏 835dp 仍全宽；计算器保留竖屏 600dp、横屏左右分栏。
- 验证尺寸：405×940（外屏级）、800×1280（8/10 英寸）、835×938（内屏）、938×835（内屏横屏）、1200×1920（11 英寸）、1280×800（平板横屏）；展开/折叠保留计算输入，12 个主要页面无溢出。
- 备注：以上为逻辑 dp 代表尺寸，未持有对应实体机，最终以真机走查补充。
- 构建：签名纯 arm64 APK 19.7MB、SHA-256 `cc0f787e63810d93b3122a2f2d5a7e6084981ce3813e1e3f0899b7c88bf15241`、`PURITY CHECK PASSED`；真机 2410DPN6CC 覆盖安装成功（lastUpdateTime 2026-10-31 12:59:39）。
- 验证：`flutter analyze` 无问题；212 项测试全绿。

### 2026-10-31 键盘比例修复

- 提交：`23b913f`、`d2a92ff`
- 修复：大写数字键盘分配高度 1→2、进制键盘 1→3；在 384dp 宽设备上圆键由 61.0/44.8dp 放大到 74.5dp，与换算键盘基准一致；大写页跨行 C/⌫ 保持标准比例。
- 审计：换算 74.5dp、温度换算 74.5dp、称呼 74.5dp、计算器 71dp、时长约 70dp，均纳入新增 `test/guards/keypad_size_guard_test.dart`。
- 反证：分别回退两处 flex，守卫均红并点名「大写数字」「进制转换」。
- 构建：签名纯 arm64 APK 19.7MB、SHA-256 `a964b1da4db596fa7cfb933a6d3f017ec0883168d7be6f8b157eba494d34120e`、`PURITY CHECK PASSED`；真机 2410DPN6CC 覆盖安装成功（lastUpdateTime 2026-10-31 12:48:23）。
- 验证：`flutter analyze` 无问题；209 项测试全绿。

---

## 模板（后续版本复制使用）

```markdown
### YYYY-MM-DD 版本 X.Y.Z+N（正式/内部）

- 提交：`<hash>`
- 新增：
- 改进：
- 修复：
- 移除：
- 验证：测试数/analyze/冒烟/纯净检查
- 备注：已知限制、数据源、签名与安装要求
```
