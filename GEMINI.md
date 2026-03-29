# kcptun for Android

## Project Overview

This project is a maintained fork of the original `shadowsocks/kcptun-android` repository, now hosted at `maxto3/kcptun-android`. It serves as an official [kcptun](https://github.com/shadowsocks/kcptun) plugin for [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android), wrapping the `kcptun` Go client into an Android application package (APK) that provides KCP tunneling capabilities.

## Key Updates in This Fork

- **Modernized Build System**: Updated to JDK 17+, Go 1.25+, and Android Gradle Plugin 8.x
- **Windows Native Support**: Added PowerShell build scripts alongside traditional Bash scripts
- **Updated Dependencies**: Upgraded Kotlin to 1.9.20, target SDK to 34
- **Build Automation**: Migrated from Travis CI to CircleCI
- **Configuration Defaults**: Set default `autoexpire` to 10 seconds for improved connection management

## Project Architecture

The project consists of two main components:

1. **Go Core**: A modified version of the `kcptun` client located in `app/src/kcptun`. It is cross-compiled into shared libraries (`libkcptun.so`) for Android ABIs (armeabi-v7a, arm64-v8a, x86, x86_64).

2. **Android Wrapper**: A minimal Kotlin-based Android application that provides the binary to `shadowsocks-android` via a `ContentProvider` (`BinaryProvider`) and handles help requests via an Activity (`HelpCallback`).

### Technical Specifications

- **Languages**: Kotlin (Android), Go (Core logic)
- **Build System**: Gradle with platform-specific shell scripts for Go cross-compilation
- **Min SDK**: 24
- **Target SDK**: 34
- **Compile SDK**: 34
- **Kotlin Version**: 1.9.20
- **Go Version**: 1.25+

## Building and Running

### Prerequisites

- **JDK**: 17 or higher
- **Go**: 1.21 or higher
- **Android SDK**: Latest with NDK r25+ recommended
- **Environment Setup**:
  - Set `ANDROID_HOME` (or `sdk.dir` in `local.properties`) to Android SDK path
  - Set `ANDROID_NDK_HOME` (or `ndk.dir` in `local.properties`) to Android NDK path

### Build Commands

#### Complete Build (All Platforms)
```bash
./gradlew assembleRelease
```

#### Native Go Compilation Only
- **Linux/macOS**: `app/src/make.bash <min_api_level>`
- **Windows**: `powershell -ExecutionPolicy Bypass -File app/src/make.ps1 <min_api_level>`

#### Clean Native Libraries
- **Linux/macOS**: `app/src/clean.bash`
- **Windows**: `powershell -ExecutionPolicy Bypass -File app/src/clean.ps1`

### Platform-Specific Notes

#### Linux/macOS (Traditional)
- Uses Bash scripts (`make.bash` / `clean.bash`)
- Follows standard Unix build conventions
- Compatible with existing CI/CD pipelines

#### Windows (Native Support)
- Uses PowerShell scripts (`make.ps1` / `clean.ps1`)
- No WSL required for Go compilation
- Integrates with Windows-based development environments
- Automatically detects NDK toolchain paths

## Development Conventions

### Kotlin (Android Layer)
- Follow standard Kotlin coding conventions
- The Android component is minimal, acting primarily as a bridge for the `shadowsocks-android` plugin API
- Integration is defined in `AndroidManifest.xml` using specific `intent-filter`s and `meta-data`
- Key files: `BinaryProvider.kt`, `HelpCallback.kt`

### Go (Core Logic)
- Located in `app/src/kcptun` (submodule)
- Android-specific modifications include:
  - `-V` flag for VPN mode compatibility
  - `parentMonitor` routine ensuring process cleanup when parent (shadowsocks-android) terminates
  - Log redirection to stderr/files for Android environment
  - Default `autoexpire` set to 10 seconds for better connection management

### Adding New Features
1. **KCP Logic Changes**: Modify files in `app/src/kcptun/client/`
2. **Configuration Options**: Update `BinaryProvider.kt` or `HelpCallback.kt` to expose new settings to Shadowsocks UI
3. **Build System**: Update platform-specific scripts in `app/src/` for new ABIs or toolchain changes

## Continuous Integration

The project uses CircleCI for automated builds. The configuration (`.circleci/config.yml`) builds the project in a Docker container with pre-installed Android NDK and Go toolchain.

## License

- **Project**: GNU General Public License v3.0
- **kcptun Core**: MIT License (see `app/src/kcptun/LICENSE.md`)

## Contributing

This fork maintains compatibility with the upstream `shadowsocks/kcptun-android` while providing modern toolchain support and Windows compatibility. Contributions should maintain cross-platform compatibility and follow existing code conventions.

## Acknowledgments

- Original project: `shadowsocks/kcptun-android`
- kcptun core: `shadowsocks/kcptun`
- Shadowsocks Android: `shadowsocks/shadowsocks-android`
- Contributors to this fork for modernization efforts