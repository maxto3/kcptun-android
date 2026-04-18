## kcptun for Android

[![CircleCI](https://circleci.com/gh/maxto3/kcptun-android.svg?style=svg)](https://circleci.com/gh/maxto3/kcptun-android)
[![API](https://img.shields.io/badge/API-24%2B-brightgreen.svg?style=flat)](https://android-arsenal.com/api?level=24)
[![Releases](https://img.shields.io/github/downloads/maxto3/kcptun-android/total.svg)](https://github.com/maxto3/kcptun-android/releases)
[![Language: Kotlin](https://img.shields.io/github/languages/top/maxto3/kcptun-android.svg)](https://github.com/maxto3/kcptun-android/search?l=kotlin)
[![License](https://img.shields.io/github/license/maxto3/kcptun-android.svg)](https://github.com/maxto3/kcptun-android/blob/master/LICENSE)

[kcptun](https://github.com/maxto3/kcptun) plugin for [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android).

<a href="https://play.google.com/store/apps/details?id=com.github.shadowsocks.plugin.kcptun"><img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" height="48"></a>

### FEATURES

**MultiPort Support**
- Server and client support multi-port configuration via port ranges (e.g., `:29900-29910`)
- Client supports random port selection strategy for improved connection flexibility and stability
- Server can listen on multiple ports simultaneously to distribute load

**SMUX v2 Protocol**
- Supports SMUX v2 with efficient flow control and high-concurrency stream processing
- Configurable `smuxver` parameter to switch between v1/v2 protocol versions
- Supports `framesize` and `streambuf` parameters for fine-grained tuning

**Smart Reconnection & Health Checks**
- Intelligent reconnection mechanism in VPN mode for enhanced connection stability
- Automatic health checks that proactively close idle sessions to ensure connection freshness
- Pipe half-close support: uses `CloseWrite()` interface to handle half-close logic, fixing stream closure issues

**Performance Optimization**
- Buffer Pooling: manages buffers via `sync.Pool` to reduce GC pressure
- MultiPort Cache Optimization: uses `sync.Once` to ensure address parsing executes only once
- Go 1.25 Upgrade: leverages modern Go syntax features (generics) and standard library improvements

**Additional Features**
- Framesize & Closewait Configuration: customizable frame size and connection close wait time
- Unix Domain Socket support for local/target addresses
- Parent Process Monitor: auto-exits when parent process terminates

### CONFIGURATION

#### Client Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `localaddr` | `:12948` | Local listen address |
| `remoteaddr` | `vps:29900` | KCP server address (supports port ranges) |
| `key` | `it's a secrect` | Pre-shared secret between client and server |
| `crypt` | `aes` | Encryption: aes, aes-128, aes-192, salsa20, blowfish, twofish, cast5, 3des, tea, xtea, xor, sm4 |
| `mode` | `fast` | Profile: fast3, fast2, fast, normal, manual |
| `conn` | `1` | Number of UDP connections to server |
| `autoexpire` | `10` | Auto expiration time for UDP connections in seconds, 0 to disable |
| `scavengettl` | `600` | How long an expired connection can live in seconds |
| `mtu` | `1350` | Maximum transmission unit for UDP packets |
| `sndwnd` | `128` | Send window size (number of packets) |
| `rcvwnd` | `512` | Receive window size (number of packets) |
| `datashard` | `10` | Reed-Solomon erasure coding - datashard |
| `parityshard` | `3` | Reed-Solomon erasure coding - parityshard |
| `dscp` | `0` | DSCP marking (6bit) |
| `nocomp` | `false` | Disable compression |
| `acknodelay` | `false` | Flush ACK immediately when a packet is received |
| `nodelay` | `0` | Enable nodelay mode |
| `interval` | `50` | Send interval in milliseconds |
| `resend` | `0` | Triggered retransmission condition |
| `nc` | `0` | Disable congestion control |
| `sockbuf` | `4194304` | Per-socket buffer size in bytes |
| `smuxver` | `1` | SMUX version: 1, 2 |
| `smuxbuf` | `4194304` | SMUX total de-mux buffer in bytes |
| `framesize` | `32768` | SMUX maximum frame size in bytes |
| `streambuf` | `2097152` | Per-stream receive buffer in bytes, SMUX v2+ |
| `keepalive` | `10` | Heartbeat interval in seconds |
| `closewait` | `0` | Wait time before closing in seconds |
| `snmplog` | `` | SNMP log file path |
| `snmpperiod` | `60` | SNMP collection period in seconds |
| `log` | `` | Log file path, defaults to stderr |
| `quiet` | `false` | Suppress stream open/close messages |
| `tcp` | `false` | Emulate TCP connection (Linux) |
| `V` | `false` | Enable Shadowsocks Android VPN mode |

#### Server Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `listen` | `:29900` | KCP server listen address (supports port ranges) |
| `target` | `127.0.0.1:12948` | Target server address or Unix Socket path |
| `key` | `it's a secrect` | Pre-shared secret |
| `crypt` | `aes` | Encryption method |
| `mode` | `fast` | Profile |
| `mtu` | `1350` | Maximum transmission unit for UDP packets |
| `sndwnd` | `1024` | Send window size (number of packets) |
| `rcvwnd` | `1024` | Receive window size (number of packets) |
| `datashard` | `10` | Reed-Solomon erasure coding - datashard |
| `parityshard` | `3` | Reed-Solomon erasure coding - parityshard |
| `dscp` | `0` | DSCP marking (6bit) |
| `nocomp` | `false` | Disable compression |
| `sockbuf` | `4194304` | Per-socket buffer size in bytes |
| `smuxver` | `1` | SMUX version |
| `smuxbuf` | `4194304` | SMUX total de-mux buffer in bytes |
| `streambuf` | `2097152` | Per-stream receive buffer in bytes |
| `keepalive` | `10` | Heartbeat interval in seconds |
| `pprof` | `false` | Start profiling server on :6060 |
| `snmplog` | `` | SNMP log file path |
| `snmpperiod` | `60` | SNMP collection period in seconds |
| `log` | `` | Log file path |
| `quiet` | `false` | Suppress stream open/close messages |
| `tcp` | `false` | Emulate TCP connection (Linux) |

#### Mode Profiles

| Profile | nodelay | interval | resend | nc |
|---------|---------|----------|--------|-----|
| `normal` | 0 | 40 | 2 | 1 |
| `fast` | 0 | 30 | 2 | 1 |
| `fast2` | 1 | 20 | 2 | 1 |
| `fast3` | 1 | 10 | 2 | 1 |

### UPSTREAM MIGRATION

This project has fully migrated upstream kcptun latest features. Key changes include:

**Migration History**
- **2026-03**: Migrated from `shadowsocks/kcptun` to `maxto3/kcptun` for easier code change in upstream.
- **2026-03**: Go compiler upgraded from 1.14 to 1.25, supporting modern Go syntax and standard library
- **2026-03**: Build scripts migrated from Bash to PowerShell, enabling native Windows build support

**Feature Migration**
- **SMUX v2**: Full synchronization of kcp-go/v5 and smux/v2 improvements with efficient flow control
- **MultiPort**: Server and client multi-port support with random port selection strategy
- **Pipe Refactoring**: Bidirectional Pipe with half-close support to fix stream closure issues
- **Buffer Pooling**: Buffer pooling mechanism to reduce GC pressure
- **Framesize/Closewait**: New configuration options for frame size and connection close wait time

### PREREQUISITES

* JDK 17+
* Go 1.25+
* Android SDK
  - Android NDK r25+

### QUICK START

We provide automated setup scripts to configure your Android SDK/NDK paths:

#### Windows
```powershell
# Run the setup script (recommended)
.\setup-env.ps1

# Or with force flag to overwrite existing configuration
.\setup-env.ps1 -Force

# Show help
.\setup-env.ps1 -Help
```

#### Linux/macOS
```bash
# Make the script executable
chmod +x setup-env.sh

# Run the setup script (recommended)
./setup-env.sh

# Or with force flag to overwrite existing configuration
./setup-env.sh --force

# Show help
./setup-env.sh --help
```

#### Manual Configuration (Alternative)
If you prefer manual setup, you can:
1. Create or edit `local.properties` file in the project root:
   ```
   sdk.dir=/path/to/your/android/sdk
   ndk.dir=/path/to/your/android/ndk  # optional
   ```
2. Or set environment variables:
   - `ANDROID_HOME` or `ANDROID_SDK_ROOT`: Path to Android SDK
   - `ANDROID_NDK_HOME`: Path to Android NDK (optional)

### BUILD

You can check whether the latest commit builds by checking CI status.

#### Linux/macOS (Traditional)
* Clone the repo using `git clone --recurse-submodules <repo>` or update submodules using `git submodule update --init --recursive`
* Run the setup script: `./setup-env.sh`
* Build using Android Studio or Gradle: `./gradlew assembleRelease`

#### Windows (Native Support)
* Clone the repo as above
* Run the setup script: `.\setup-env.ps1`
* Build using PowerShell-compatible Gradle wrapper: `./gradlew assembleRelease`
* Native Go compilation is handled automatically via PowerShell scripts (`make.ps1` / `clean.ps1`)
* Note: PowerShell execution policy may need adjustment. Use `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` if scripts are blocked.

The project supports cross-platform builds with:
- **Linux/macOS**: Bash scripts (`make.bash` / `clean.bash`)
- **Windows**: PowerShell scripts (`make.ps1` / `clean.ps1`)

### TROUBLESHOOTING

If you encounter "SDK not found" errors:
1. Run the appropriate setup script for your platform (see Quick Start above)
2. Ensure Android Studio or the standalone Android SDK is installed
3. Verify the SDK path contains the `platforms` and `tools` directories

The build system will provide helpful error messages with platform-specific guidance if SDK configuration is missing.

### TRANSLATE

This plugin is an official plugin thus you can see [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android/blob/master/README.md#translate)'s instructions to translate this plugin's UI.

## OPEN SOURCE LICENSES

<ul>
    <li>kcptun: <a href="https://github.com/maxto3/kcptun/blob/shadowsocks/LICENSE.md">MIT</a></li>
</ul>

### LICENSE

Copyright (C) 2017 by Max Lv <<max.c.lv@gmail.com>>  
Copyright (C) 2017 by Mygod Studio <<contact-shadowsocks-android@mygod.be>>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.