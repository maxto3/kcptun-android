param (
    [string]$MinApi = "24"
)

$ErrorActionPreference = "Stop"

$NDK = $env:ANDROID_NDK_HOME
if (-not $NDK) {
    $NDK = Join-Path $env:ANDROID_HOME "ndk"
    if (-not (Test-Path $NDK)) {
        # Try finding any version under ndk/
        $NDK_VERSIONS = Get-ChildItem -Path $NDK -Directory | Sort-Object Name -Descending
        if ($NDK_VERSIONS) {
            $NDK = $NDK_VERSIONS[0].FullName
        }
    } else {
        # Check for subdirectories like '30.0.14904198'
        $NDK_VERSIONS = Get-ChildItem -Path $NDK -Directory | Sort-Object Name -Descending
        if ($NDK_VERSIONS) {
            $NDK = $NDK_VERSIONS[0].FullName
        }
    }
}

if (-not (Test-Path $NDK)) {
    Write-Error "Android NDK not found at $NDK. Please set ANDROID_NDK_HOME."
    exit 1
}

Write-Host "Using NDK: $NDK"

$TOOLCHAIN_BIN_FULL = "$NDK\toolchains\llvm\prebuilt\windows-x86_64\bin"
if (-not (Test-Path $TOOLCHAIN_BIN_FULL)) {
    # Try finding any subdirectory that contains 'bin'
    $TOOLCHAIN_ROOT = Get-ChildItem -Path "$NDK\toolchains\llvm\prebuilt\windows-x86_64" -Directory | Select-Object -First 1
    if ($TOOLCHAIN_ROOT) {
        $TOOLCHAIN_BIN_FULL = Join-Path $TOOLCHAIN_ROOT.FullName "bin"
    }
}

if (-not (Test-Path $TOOLCHAIN_BIN_FULL)) {
    Write-Error "Toolchain bin directory not found at $TOOLCHAIN_BIN_FULL"
    exit 1
}

# Get short path to avoid spaces in CC
$fso = New-Object -ComObject Scripting.FileSystemObject
$TOOLCHAIN_BIN = $fso.GetFolder($TOOLCHAIN_BIN_FULL).ShortPath
if (-not $TOOLCHAIN_BIN) {
    $TOOLCHAIN_BIN = $TOOLCHAIN_BIN_FULL
}

$DIR = Get-Location
$TARGET = Join-Path $DIR "bin"

New-Item -ItemType Directory -Force -Path (Join-Path $TARGET "armeabi-v7a")
New-Item -ItemType Directory -Force -Path (Join-Path $TARGET "arm64-v8a")
New-Item -ItemType Directory -Force -Path (Join-Path $TARGET "x86")
New-Item -ItemType Directory -Force -Path (Join-Path $TARGET "x86_64")

$env:GOPATH = $DIR
$KCPTUN_CLIENT_DIR = Join-Path $DIR "kcptun\client"

Push-Location $KCPTUN_CLIENT_DIR

Write-Host "Get dependencies for kcptun"
go get -v ./...

$ABIS = @(
    @{ Arch = "arm"; Abi = "armeabi-v7a"; CC = "armv7a-linux-androideabi$MinApi-clang.cmd"; GoArm = "7" },
    @{ Arch = "arm64"; Abi = "arm64-v8a"; CC = "aarch64-linux-android$MinApi-clang.cmd" },
    @{ Arch = "386"; Abi = "x86"; CC = "i686-linux-android$MinApi-clang.cmd" },
    @{ Arch = "amd64"; Abi = "x86_64"; CC = "x86_64-linux-android$MinApi-clang.cmd" }
)

foreach ($ABI in $ABIS) {
    $ABI_NAME = $ABI.Abi
    $SO_PATH = Join-Path $TARGET "$ABI_NAME\libkcptun.so"
    
    if (-not (Test-Path $SO_PATH)) {
        Write-Host "Cross compile kcptun for $ABI_NAME"
        
        $env:CGO_ENABLED = "1"
        $env:GOOS = "android"
        $env:GOARCH = $ABI.Arch
        if ($ABI.GoArm) { $env:GOARM = $ABI.GoArm } else { $env:GOARM = "" }
        $env:CC = Join-Path $TOOLCHAIN_BIN $ABI.CC
        
        go build -ldflags="-s -w" -o client
        
        if (Test-Path "client") {
            # Strip using llvm-strip
            $STRIP = Join-Path $TOOLCHAIN_BIN "llvm-strip.exe"
            & $STRIP "client"
            Move-Item -Path "client" -Destination $SO_PATH -Force
        } else {
            Write-Error "Failed to build for $ABI_NAME"
            exit 1
        }
    }
}

Pop-Location
Write-Host "Successfully built kcptun"
