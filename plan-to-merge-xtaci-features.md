# kcptun-android 功能移植与 Go 版本升级计划 (20260314 Upstream 特性)

本计划旨在将 `kcptun-android` 的 Go 环境从 1.14 升级至 **1.25**，并全量同步 `kcptun-20260314` (Upstream) 中的 SMUX v2 改进与 MultiPort 优化。通过升级 Go 版本，我们可以直接利用 Upstream 的新语法特性（如泛型、`any`）和标准库改进。

## 1. 目标 (Objectives)
- **环境对齐**：将 Go 编译器版本升级至 1.25，支持现代 Go 语法与标准库。
- **协议升级**：将 SMUX 库升级至 v1.5.57，支持高效流量控制与高并发流处理。
- **稳定性增强**：引入 `Pipe` 逻辑与 `CloseWrite` 支持，彻底解决 SMUX v2 流关闭异常。
- **性能优化**：引入 `bufPool` 减少 GC 压力，并对 MultiPort 拨号逻辑进行缓存重构。

## 2. 移植步骤 (Detailed Steps)

### 第一阶段：Go 1.25 构建环境升级 (Option A: Direct Upgrade)
1. **工具链更新**：
   - 确保宿主机已安装 Go 1.25。
   - 更新 Android NDK (建议 r26+) 以支持 Go 1.25 生成的 ELF 符号。
   - 升级 `gomobile` 至最新版本：`go install golang.org/x/mobile/cmd/gomobile@latest`。
2. **项目配置更新**：
   - 修改 `kcptun-android/app/src/kcptun/go.mod`：将 `go 1.14` 更改为 `go 1.25`。
   - 运行 `go mod tidy` 同步所有依赖项（重点关注 `kcp-go/v5`, `smux`, `tcpraw`）。
3. **消除语法冲突**：
   - 由于已经支持 Go 1.25，**无需**再将 `any` 改回 `interface{}`。反之，建议将旧代码逐步迁移至 `any` 以保持代码一致性。

### 第二阶段：核心协议栈与 IO 优化
1. **同步 SMUX 源码**：
   - 全量覆盖 `kcptun-android/app/src/kcptun/vendor/github.com/xtaci/smux/`。
2. **重构 IO 管道 (std/copy.go)**：
   - 在 `generic/copy.go` 中引入 `sync.Pool` 管理的 `bufPool`。
   - 实现 `Pipe(alice, bob io.ReadWriteCloser, closeWait int)`，利用 `CloseWrite()` 接口处理半关闭逻辑。
3. **handleClient 适配**：
   - 修改 `client/main.go` 中的 `handleClient`，使用 `Pipe` 代替原有的双向 `streamCopy` 协程，减少资源竞争风险。

### 第三阶段：配置与 SMUX v2 调优
1. **配置验证逻辑**：
   - 移植 `std/smuxcfg.go` 中的 `BuildSmuxConfig` 逻辑。
2. **参数扩展**：
   - 在 `client/config.go` 中增加 `FrameSize` 字段。
   - 在 `client/main.go` 的 CLI Flags 中增加 `framesize` 选项。
3. **会话创建**：
   - 更新 `client/main.go` 中的 `createConn`，确保配置通过 `smux.VerifyConfig` 校验。

### 第四阶段：MultiPort 性能重构
1. **正则解析优化**：
   - 在 `generic/multiport.go` 中将正则表达式改为包级预编译变量。
2. **缓存拨号地址**：
   - 修改 `client/dial.go` 和 `client/dial_android.go`。
   - 使用 `sync.Once` 确保 `remoteaddr` 字符串在整个运行周期内仅解析一次，显著降低频繁拨号时的 CPU 损耗。

## 3. 注意事项 (Critical Notes)
- **CGO 兼容性**：Go 1.20+ 对 CGO 函数调用的参数检查更严格。需重点测试 `dial_android.go` 中的 `ancil_send_fd` 是否因指针处理不当触发 runtime panic。
- **Android VpnMode**：在升级过程中必须保证 `ControlOnConnSetup` (fd protect) 逻辑不被破坏，这是在 Android 系统的 VPN 模式下建立连接的核心。
- **架构适配**：Go 1.24/1.25 在 arm64 架构上有显著性能提升，但在 armeabi-v7a (32bit) 上需额外关注内存布局问题。

## 4. 验证计划 (Verification)
1. **编译验证**：确保 `gomobile build` 能正常通过且不报错。
2. **流量压测**：在 Android 模拟器或实机上长时间运行大流量传输，监控内存使用曲线（验证 `bufPool` 和新版 GC 表现）。
3. **断网重连测试**：验证在新版 `Pipe` 逻辑下，异常断开连接是否能及时释放流资源和相关协程。