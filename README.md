## kcptun for Android

[![CircleCI](https://circleci.com/gh/maxto3/kcptun-android.svg?style=svg)](https://circleci.com/gh/maxto3/kcptun-android)
[![API](https://img.shields.io/badge/API-24%2B-brightgreen.svg?style=flat)](https://android-arsenal.com/api?level=24)
[![Releases](https://img.shields.io/github/downloads/maxto3/kcptun-android/total.svg)](https://github.com/maxto3/kcptun-android/releases)
[![Language: Kotlin](https://img.shields.io/github/languages/top/maxto3/kcptun-android.svg)](https://github.com/maxto3/kcptun-android/search?l=kotlin)
[![License](https://img.shields.io/github/license/maxto3/kcptun-android.svg)](https://github.com/maxto3/kcptun-android/blob/master/LICENSE)

[kcptun](https://github.com/shadowsocks/kcptun) plugin for [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android).

<a href="https://play.google.com/store/apps/details?id=com.github.shadowsocks.plugin.kcptun"><img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png" height="48"></a>

### PREREQUISITES

* JDK 17+
* Go 1.25+
* Android SDK
  - Android NDK r25+
* (Optional) Set environment variables or configure `local.properties`:
  - `ANDROID_HOME` or `sdk.dir`: Path to Android SDK
  - `ANDROID_NDK_HOME` or `ndk.dir`: Path to Android NDK

### BUILD

You can check whether the latest commit builds by checking CI status.

#### Linux/macOS (Traditional)
* Clone the repo using `git clone --recurse-submodules <repo>` or update submodules using `git submodule update --init --recursive`
* Build using Android Studio or Gradle: `./gradlew assembleRelease`

#### Windows (Native Support)
* Clone the repo as above
* Build using PowerShell-compatible Gradle wrapper: `./gradlew assembleRelease`
* Native Go compilation is handled automatically via PowerShell scripts (`make.ps1` / `clean.ps1`)
* Note: PowerShell execution policy may need adjustment. Use `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` if scripts are blocked.

The project supports cross-platform builds with:
- **Linux/macOS**: Bash scripts (`make.bash` / `clean.bash`)
- **Windows**: PowerShell scripts (`make.ps1` / `clean.ps1`)

### TRANSLATE

This plugin is an official plugin thus you can see [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android/blob/master/README.md#translate)'s instructions to translate this plugin's UI.

## OPEN SOURCE LICENSES

<ul>
    <li>kcptun: <a href="https://github.com/shadowsocks/kcptun/blob/shadowsocks/LICENSE.md">MIT</a></li>
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