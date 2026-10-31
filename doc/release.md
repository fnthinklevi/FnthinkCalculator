# 幻念计算器 · 标准发版流程

> 适用范围：所有对外安装包（真机、平板、折叠屏、分发给他人）的构建与发布。
> 一句话：**先提交版本准备 → 跑 `tool/release.sh` → 真机冒烟 → 更新记录 → 再打 tag**；脚本不代替安装、提交、打 tag 或 push。

## 1. 角色与授权

- **开发者（AI/维护者）**：准备版本、跑闸门、构建、整理产物、更新文档、提交本地改动。
- **发布负责人（用户）**：决定版本号、确认安装/卸载、确认真机冒烟结果、授权 push/tag/GitHub Release。
- 以下动作每次都需要明确授权，不能沿用上一次：
  - 安装/卸载真机或模拟器
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

### 步骤 4：真机冒烟

产物：

```text
build/release/FnthinkCalculator-v<版本>+<构建号>-arm64.apk
build/release/FnthinkCalculator-v<版本>+<构建号>-SHA256SUMS.txt
```

安装（串号必须明确；不要对未确认的设备执行）：

```bash
adb -s <serial> install -r build/release/FnthinkCalculator-v<版本>+<构建号>-arm64.apk
```

冒烟清单（至少一遍亮色 + 一遍深色）：

- [ ] 冷启动进入计算页，无崩溃、无布局溢出
- [ ] 标准/科学切换；四则、百分号、括号、退格、长按清空历史
- [ ] 结果复制、转换为大写数字
- [ ] 历史页打开、多选、复制/删除、清空
- [ ] 设置页切换百分数算法、角度、震动、主题；语音开关持久化
- [ ] 语音播报：按键与结果有声；关闭后静音
- [ ] 汇率：联网刷新；断网使用缓存并显示来源/更新时间
- [ ] 单位换算、进制、大写数字、称呼、BMI、比例、时间四页各做一次输入/结果
- [ ] 个税、房贷表单：系统数字键盘、校验、结果页、返回
- [ ] 旋转屏幕；折叠屏展开/折叠（有设备时）；平板宽度下列数/键盘不裁剪
- [ ] 升级安装（同签名）保留历史与设置；签名不一致时先停止，不要擅自卸载

任何一项失败：停止发版，修复后提升 BUILD，回到步骤 2。

### 步骤 5：更新文档并提交

按顺序更新：

1. `doc/update.md`
   - 顶部「当前构建」：版本、APK 大小、SHA-256、测试例数、签名状态
   - 本批次新增一条：提交号、用户可见改动、验证结果、构建/安装信息、已知限制
2. `doc/base.md`：当前版本、当前构建 SHA、测试例数、状态描述
3. `README.md`：版本徽章、当前版本、测试读数；行为或界面变化时同步功能说明
4. `doc/xiaomi-reference.md`：只有 UI/交互标准变化时才更新

提交前确认：文档里的 SHA 与 `SHA256SUMS` 一致；测试例数与闸门输出一致；版本名与 `pubspec.yaml` 一致。

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
| 安装签名冲突 | 停止；卸载会清数据，必须单独授权；优先先在测试设备验证 |
| 冒烟失败 | 修复 + 提升 BUILD，回到步骤 2；不 tag、不推送 |
| 文档与产物不一致 | 以 `SHA256SUMS`/构建输出为准修正文档；tag 前必须干净 |

## 5. 禁止事项

- 禁止把 keystore、`android/key.properties`、签名口令写入仓库、日志、文档或聊天记录。
- 禁止跳过 `tool/release.sh` 直接用 debug 签名包对外分发。
- 禁止在闸门通过后修改源码却沿用旧 SHA / 旧测试读数。
- 禁止未经确认安装到真机、卸载用户数据、push、打 tag、发布 Release 或部署。
- 禁止提交 APK、AAB、`build/`、`.jks`、`.keystore`。
- 禁止对已发布 tag 执行 force push 或重打。

## 6. 快速命令

```bash
# 版本准备提交后
bash tool/release.sh --preflight
bash tool/release.sh

# 真机冒烟（串号按实际替换）
adb -s <serial> install -r build/release/FnthinkCalculator-v<版本>+<构建号>-arm64.apk

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
