# 迁移上游 kcptun 到 maxto3/kcptun 的分步计划 (已完成)

## 概述

本计划已成功执行，将 `kcptun-android` 的上游依赖从 `shadowsocks/kcptun` 迁移到 `maxto3/kcptun`。此次迁移采取了“代码接管”策略，旨在由 `maxto3` 组织完全维护项目代码，同时保持与原始插件生态的兼容性。

## 迁移状态：✅ 已完成

- **执行日期**：2026年3月30日
- **迁移范围**：`.gitmodules` 配置、子模块路径/名称修复、代码分支锁定。

## 已实施的改进

与原始计划相比，我们在执行过程中进行了以下优化：

1.  **子模块名称规范化**：将 `.gitmodules` 中的名称从 `src/kcptun` 修改为 `app/src/kcptun`，使其与物理路径完全一致，减少维护混淆。
2.  **开发分支锁定**：自动化将子模块从“游离头指针 (Detached HEAD)”状态切换到了 `shadowsocks` 分支，方便直接在子模块中提交代码并推送到 `maxto3` 仓库。
3.  **自动化同步**：通过 Git 命令链完成了 URL 同步、强制初始化和代码更新。

## 验证记录

- ✅ `.gitmodules` 中的 URL 已指向 `https://github.com/maxto3/kcptun.git`
- ✅ 子模块远程 `origin` 已更新为 `maxto3` 仓库
- ✅ 子模块已检出 `shadowsocks` 分支并处于最新状态

## 迁移后的开发工作流

现在你可以直接按照以下流程进行维护：

1.  **修改代码**：直接进入 `app/src/kcptun` 目录修改 Go 核心逻辑。
2.  **提交更改**：
    ```bash
    cd app/src/kcptun
    git add .
    git commit -m "Your changes"
    git push origin shadowsocks
    ```
3.  **同步主仓库**：
    ```bash
    cd ../..
    git add app/src/kcptun
    git commit -m "Update kcptun submodule reference"
    git push
    ```

## 注意事项

- **包名兼容性**：为了保持与 Shadowsocks-android 主程序的插件兼容性，我们保留了原始的 Android 包名和配置，仅接管了源代码层面的维护。
- **构建环境**：继续使用 `app/src/make.bash` 或 `app/src/make.ps1` 进行交叉编译。

---

**文档版本**：2.0 (迁移完成版)  
**最后更新**：2026-03-30  
**适用项目**：kcptun-android  
**相关文件**：`.gitmodules`, `GEMINI.md`, `README.md`, `app/src/kcptun/`
