# 幻念计算器 · 标准发版流程

> 适用范围：所有对外安装包（手机、平板、折叠屏尺寸，分发给他人）的构建与发布。
> 一句话：**先提交版本准备 → 跑 `tool/release.sh` → 模拟器冒烟 → 更新记录 → 再打 tag**；脚本不代替安装、提交、打 tag 或 push。

## 1. 角色与授权

- **开发者（AI/维护者）**：准备版本、跑闸门、构建、启动模拟器、安装并冒烟、整理产物、更新文档、提交本地改动。
- **发布负责人（用户）**：决定版本号、确认最终发版、授权 push/tag/GitHub Release。
- 模拟器冒烟由开发者执行，但不影响用户设备；所有针对设备的 adb 命令必须带 `-s emulator-<端口>`。
- 以下动作每次都需要明确授权，不能沿用上一次：
  - 安装/卸载真机或任何用户设备（标准流程不使用真机）
  - `git push`、推送 tag、创建 GitHub Release
  - 上传 APK 到任何外部平台
  - 部署服务器或修改发布配置

## 2. 版本规则

版本号只在 `pubspec.yaml` 的 `version: MAJOR.MINOR.PATCH+BUILD` 中提升：

| 改动 | 版本 | 例子 |
|---|---|---|
| 修 bug / 文档 / 无行为变化 | PATCH + BUILD | `0.1.0+2 → 0.1.1+3` |
| 新增用户可见功能 | MINOR + BUILD | `0.1.1+3 → 0.2.0+4` |
| 破坏性变更 / 数据迁移 | MAJOR + BUILD | `0.2.0+4 → 1.0.0+5` |

- 每次产生新 APK，BUILD 必须递增；不能复用已发布的 BUILD。
- `settings_page.dart` 的「版本」显示必须与版本名一致；`tool/release.sh --preflight` 会检查。
- 一个版本名只打一个 tag（`vX.Y.Z`）；同一版本号不重复发版。补构建请提升 BUILD 并确认是否属于同一次发布。
- 对外 APK 固定命名为 `FnthinkCalculator_<版本名>.apk`（如 `FnthinkCalculator_0.1.1.apk`），不带 `v` 前缀、构建号或 ABI；构建号写入 `update.md`。
- 已推送的 tag 不移动、不删除、不覆盖。

## 3. 发版流程

### 步骤 1：冻结范围并提交版本准备

1. 确认本批次所有功能/修复已完成，工作区没有无关改动。
2. 按第 2 节提升 `pubspec.yaml` 版本，并同步设置页版本显示。
3. 依赖有变化时执行 `flutter pub get`。
4. 提交版本准备（例如 `chore: 发布 0.1.1+3`），确保之后从干净工作区构建。
5. 记录本批次要写入发版说明的改动。

### 步骤 2：快速预检

```bash
bash tool/release.sh --preflight
```

检查：版本格式、设置页版本一致、签名配置存在、工作区干净、tag 状态。输出 `Preflight OK` 才能继续。

### 步骤 3：完整发版闸门

```bash
bash tool/release.sh
```

脚本依次执行：

1. `dart format --output=none --set-exit-if-changed lib test`
2. `flutter analyze`
3. `flutter test`（全量）
4. `bash tool/build_release_arm64.sh`（签名纯 arm64 构建 + 纯净检查）
5. 复制 APK 到 `build/release/`，生成 SHA-256 校验文件

通过后记录脚本输出的三项读数：**版本、测试例数、SHA-256**。闸门通过后不要再改源码；改了就必须重新跑。

### 步骤 4：模拟器冒烟

产物：

```text
build/release/FnthinkCalculator_<版本名>.apk
build/release/FnthinkCalculator_<版本名>.apk.sha256
```

#### 启动模拟器

在独立终端启动 AVD（示例 AVD：`ci_api34_pixel6`，API 34 / 1080×2400 / 420dpi）：

```bash
emulator -list-avds
emulator -avd <AVD_NAME> -no-snapshot -no-boot-anim
adb -s emulator-<端口> wait-for-device
adb -s emulator-<端口> shell getprop sys.boot_completed   # 输出 1 表示已启动
```

- 先用 `adb devices` 确认模拟器端口；之后所有针对设备的 adb 命令都必须带 `-s emulator-<端口>`。
- 命令行启动被后台回收时，用系统方式分离启动，例如 Windows Git Bash：`cmd //c start "" emulator -avd <AVD_NAME>`；不要改用真机。
- 标准流程只使用模拟器，不安装到真机。

#### 安装与版本确认

```bash
adb -s emulator-<端口> install -r build/release/FnthinkCalculator_<版本名>.apk
adb -s emulator-<端口> shell dumpsys package com.fnthink.FnthinkCalculator | grep -E "versionName|versionCode"
```

- 模拟器签名冲突时，可在模拟器卸载后重装（模拟器数据可丢弃）：
  `adb -s emulator-<端口> uninstall com.fnthink.FnthinkCalculator`
- 真机安装不属于标准流程；如确需真机验证，由用户单独确认并提供串号。

#### 冒烟清单（至少一遍亮色 + 一遍深色）

- [ ] 冷启动进入计算页，无崩溃、无布局溢出
- [ ] 标准/科学切换；四则、百分号、括号、退格、长按清空历史
- [ ] 结果复制、转换为大写数字
- [ ] 历史页打开、多选、复制/删除、清空
- [ ] 设置页切换百分数算法、角度、震动、主题；语音开关持久化
- [ ] 语音播报：按键与结果有声；关闭后静音
- [ ] 汇率：联网刷新；断网使用缓存并显示来源/更新时间
- [ ] 单位换算、进制、大写数字、称呼、BMI、比例、时间四页各做一次输入/结果
- [ ] 个税、房贷表单：系统数字键盘、校验、结果页、返回
- [ ] 旋转屏幕；大屏/折叠适配以 responsive 测试为准；如使用平板/折叠 AVD 或 `wm size` 变更，检查 900dp 上限、网格列数与键盘不裁剪
- [ ] 同签名覆盖安装保留历史与设置；签名冲突只在模拟器卸载重装

可选取证：关键页面截图保存到 `build/release/smoke/`，命令同样必须带 `-s emulator-<端口>`。

#### 关闭模拟器

```bash
adb -s emulator-<端口> emu kill
```

冒烟结束必须关闭模拟器；失败也要先关闭并记录，再修复重跑。

任何一项失败：停止发版，修复后提升 BUILD，回到步骤 2。

### 步骤 5：更新文档并提交

按顺序更新：

1. `doc/update.md`
   - 顶部「当前构建」：版本、APK 大小、SHA-256、测试例数、签名状态
   - 本批次新增一条：提交号、用户可见改动、验证结果、构建/模拟器冒烟信息（AVD、API、分辨率）、已知限制
2. `doc/base.md`：当前版本、当前构建 SHA、测试例数、状态描述
3. `README.md`：版本徽章、当前版本、测试读数；行为或界面变化时同步功能说明
4. `doc/xiaomi-reference.md`：只有 UI/交互标准变化时才更新

提交前确认：文档里的 SHA 与 `.apk.sha256` 一致；测试例数与闸门输出一致；版本名与 `pubspec.yaml` 一致；安装包文件名为 `FnthinkCalculator_<版本名>.apk`。

```bash
git status
git diff --stat
git add <指定文件>
git commit -F <提交信息文件>
```

### 步骤 6：最终检查并打 tag

```bash
git status                 # 必须干净
git log --oneline -3       # 确认提交内容
git rev-parse HEAD         # 记录发版提交
git tag -l "v<版本名>"     # 本地不应已有
```

本地与远端都不存在该 tag 后，创建附注 tag：

```bash
git tag -a v<版本名> -F <tag 说明文件>
git rev-list -n 1 v<版本名>
```

tag 必须指向最终文档提交（即上面的 HEAD），不是构建前的中间提交。

### 步骤 7：推送（需明确授权）

```bash
git push <remote> main
git push <remote> v<版本名>
```

- 只有用户明确说「push / 推送 / 发版」时才执行。
- 不 force push，不推送全部 tag，不移动已推送的 tag。
- 需要 GitHub Release 时，另行确认后上传 `build/release/` 下的 APK 与 SHA-256；不上传 keystore、`key.properties`、密码或调试包。

### 步骤 8：归档与回滚

- 保留 `build/release/` 下的 APK 与校验文件至少一个版本周期；它们不进 Git。
- 发现线上问题时：修复 → 提升 PATCH/BUILD → 重新走流程；**不要覆盖旧 tag 或旧安装包**。
- 需要退回上一版时，直接分发上一版已归档 APK；先确认签名一致，并告知用户数据兼容性。

## 4. 失败处理

| 失败点 | 处理 |
|---|---|
| 格式检查失败 | `dart format lib test`，提交格式修改，重新跑 |
| analyze / 测试失败 | 修复并提交；禁止跳过测试发版 |
| 纯净检查失败 | 查非 arm64 `.so`、密钥/模型/裸音频/测试资源；修复后重跑，禁止分发 |
| 证书是 debug | 检查 `android/key.properties` 与仓库外 keystore；修好后重跑 |
| tag 已存在 | 说明该版本已发布；提升版本号，不要重复打 tag |
| 模拟器启动失败 | 换可用 AVD 或修复模拟器环境；禁止改用真机绕过 |
| 安装签名冲突 | 在模拟器卸载后重装（数据可丢弃）；真机需用户单独授权，标准流程不涉及 |
| 冒烟失败 | 修复 + 提升 BUILD，回到步骤 2；不 tag、不推送 |
| 文档与产物不一致 | 以 `.apk.sha256`/构建输出为准修正文档；tag 前必须干净 |
| 安装包文件名不符合规范 | 按 `FnthinkCalculator_<版本名>.apk` 重命名并重新生成 `.sha256`，GitHub Release 只上传该文件 |

## 5. 禁止事项

- 禁止把 keystore、`android/key.properties`、签名口令写入仓库、日志、文档或聊天记录。
- 禁止跳过 `tool/release.sh` 直接用 debug 签名包对外分发。
- 禁止在闸门通过后修改源码却沿用旧 SHA / 旧测试读数。
- 禁止用真机替代标准模拟器冒烟；真机安装/卸载必须由用户单独授权。
- 禁止对设备执行裸 adb 命令：除 `adb devices` 外，必须带 `-s emulator-<端口>`。
- 禁止未经确认 push、打 tag、发布 Release 或部署。
- 禁止提交 APK、AAB、`build/`、`.jks`、`.keystore`。
- 禁止对已发布 tag 执行 force push 或重打。

## 6. 快速命令

```bash
# 版本准备提交后
bash tool/release.sh --preflight
bash tool/release.sh

# 模拟器冒烟（端口以 adb devices 为准；每条都必须带 -s）
emulator -avd <AVD_NAME> -no-snapshot -no-boot-anim
adb -s emulator-<端口> wait-for-device
adb -s emulator-<端口> shell getprop sys.boot_completed
adb -s emulator-<端口> install -r build/release/FnthinkCalculator_<版本名>.apk
adb -s emulator-<端口> shell am start -W -n com.fnthink.FnthinkCalculator/.MainActivity
adb -s emulator-<端口> exec-out screencap -p > build/release/smoke-<版本名>.png
adb -s emulator-<端口> emu kill

# 文档提交后（tag 前再确认一次）
git status
git tag -a v<版本名> -F <tag说明文件>

# 获得明确授权后
git push <remote> main
git push <remote> v<版本名>
```

相关文件：

- 发版记录：[update.md](update.md)
- 技术基线：[base.md](base.md)
- UI/交互标准：[xiaomi-reference.md](xiaomi-reference.md)
- 打包脚本：[tool/build_release_arm64.sh](../tool/build_release_arm64.sh)
- 纯净检查：[tool/check_apk_purity.sh](../tool/check_apk_purity.sh)
- 发版闸门：[tool/release.sh](../tool/release.sh)
