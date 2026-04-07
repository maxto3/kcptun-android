#!/usr/bin/env pwsh
# setup-env.ps1 - Android SDK/NDK environment setup script for Windows
# This script automatically detects Android SDK and NDK paths and creates local.properties

param(
    [switch]$Force = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "Usage: .\setup-env.ps1 [-Force] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force    Overwrite existing local.properties file"
    Write-Host "  -Help     Show this help message"
    Write-Host ""
    Write-Host "Description:"
    Write-Host "  Automatically detects Android SDK and NDK paths on Windows and creates"
    Write-Host "  local.properties file for Gradle builds."
    exit 0
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Find-AndroidSdk {
    # Common Android SDK installation paths on Windows
    $possiblePaths = @()
    
    # Environment variables
    if ($env:ANDROID_HOME) { $possiblePaths += $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT) { $possiblePaths += $env:ANDROID_SDK_ROOT }
    
    # Android Studio default locations
    $possiblePaths += "$env:LOCALAPPDATA\Android\Sdk"
    $possiblePaths += "$env:ProgramFiles\Android\Android Studio\Sdk"
    
    # Standalone SDK installations
    $possiblePaths += "$env:ProgramFiles\Android\Sdk"
    $possiblePaths += "C:\Android\Sdk"
    $possiblePaths += "C:\android-sdk"
    
    # User directory
    $possiblePaths += "$env:USERPROFILE\AppData\Local\Android\Sdk"
    $possiblePaths += "$env:USERPROFILE\Android\Sdk"
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            $sdkPath = (Resolve-Path $path).Path
            # Remove trailing backslash if present
            $sdkPath = $sdkPath.TrimEnd('\')
            Write-Info "Found Android SDK at: $sdkPath"
            
            # Verify it's a valid SDK directory
            $platformsDir = Join-Path $sdkPath "platforms"
            $toolsDir = Join-Path $sdkPath "tools"
            if ((Test-Path $platformsDir) -or (Test-Path $toolsDir)) {
                Write-Success "Valid Android SDK directory confirmed"
                return $sdkPath
            } else {
                Write-Warning "Path exists but doesn't appear to be a valid Android SDK: $sdkPath"
            }
        }
    }
    
    return $null
}

function Find-JavaHome {
    # Common Java/JBR installation paths on Windows
    $possiblePaths = @()
    
    # Environment variable
    if ($env:JAVA_HOME) { $possiblePaths += $env:JAVA_HOME }
    
    # Android Studio JBR (JetBrains Runtime) - priority
    $asPaths = @(
        "$env:ProgramFiles\Android\Android Studio\jbr",
        "$env:LOCALAPPDATA\Android\Android Studio\jbr",
        "C:\Program Files\Android\Android Studio\jbr"
    )
    
    foreach ($asPath in $asPaths) {
        if (Test-Path $asPath) { $possiblePaths += $asPath }
    }
    
    # Common JDK paths
    $possiblePaths += "$env:ProgramFiles\Java"
    $possiblePaths += "C:\Java"
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            try {
                $resolvedPath = (Resolve-Path $path -ErrorAction SilentlyContinue).Path
                if (-not $resolvedPath) { continue }
                $resolvedPath = $resolvedPath.TrimEnd('\')
                
                # If it's a directory containing bin\java.exe, it's likely a valid JAVA_HOME
                if (Test-Path (Join-Path $resolvedPath "bin\java.exe")) {
                    Write-Info "Found Java/JBR at: $resolvedPath"
                    Write-Success "Valid Java environment confirmed"
                    return $resolvedPath
                }
                
                # If it's a parent Java directory, look for subdirectories like jdk-* or jbr
                $subDirs = Get-ChildItem -Path $resolvedPath -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending
                foreach ($subDir in $subDirs) {
                    if (Test-Path (Join-Path $subDir.FullName "bin\java.exe")) {
                        Write-Info "Found Java/JBR at: $($subDir.FullName)"
                        Write-Success "Valid Java environment confirmed"
                        return $subDir.FullName
                    }
                }
            } catch {
                # Ignore errors for specific paths
            }
        }
    }
    
    return $null
}

function Find-AndroidNdk {
    param([string]$SdkPath)
    
    # Common NDK locations
    $possiblePaths = @()
    
    # Environment variables
    if ($env:ANDROID_NDK_HOME) { $possiblePaths += $env:ANDROID_NDK_HOME }
    if ($env:ANDROID_NDK_ROOT) { $possiblePaths += $env:ANDROID_NDK_ROOT }
    
    # Within SDK directory
    if ($SdkPath) {
        $possiblePaths += Join-Path $SdkPath "ndk"
        $possiblePaths += Join-Path $SdkPath "ndk-bundle"
    }
    
    # Standalone NDK installations
    $possiblePaths += "$env:ProgramFiles\Android\Android Studio\NDK"
    $possiblePaths += "C:\Android\Ndk"
    $possiblePaths += "C:\android-ndk"
    
    # User directory
    $possiblePaths += "$env:USERPROFILE\AppData\Local\Android\Ndk"
    $possiblePaths += "$env:USERPROFILE\Android\Ndk"
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            $ndkPath = (Resolve-Path $path).Path
            # Remove trailing backslash if present
            $ndkPath = $ndkPath.TrimEnd('\')
            Write-Info "Found Android NDK at: $ndkPath"
            
            # Verify it's a valid NDK directory
            $toolchainsDir = Join-Path $ndkPath "toolchains"
            if (Test-Path $toolchainsDir) {
                Write-Success "Valid Android NDK directory confirmed"
                return $ndkPath
            } else {
                Write-Warning "Path exists but doesn't appear to be a valid Android NDK: $ndkPath"
            }
        }
    }
    
    # Try to find NDK version directories within SDK
    if ($SdkPath) {
        $ndkDir = Join-Path $SdkPath "ndk"
        if (Test-Path $ndkDir) {
            # Find the highest version number
            $ndkVersions = Get-ChildItem -Path $ndkDir -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' } | Sort-Object Name -Descending
            if ($ndkVersions.Count -gt 0) {
                $latestNdk = $ndkVersions[0].FullName
                Write-Success "Found Android NDK version: $($ndkVersions[0].Name)"
                return $latestNdk
            }
        }
    }
    
    return $null
}

function Create-LocalProperties {
    param(
        [string]$SdkPath
    )
    
    $localPropsPath = "local.properties"
    
    if ((Test-Path $localPropsPath) -and (-not $Force)) {
        Write-Warning "local.properties already exists. Use -Force to overwrite."
        $choice = Read-Host "Do you want to overwrite it? (y/N)"
        if ($choice -notmatch '^[Yy]') {
            Write-Info "Operation cancelled."
            return $false
        }
    }
    
    $content = @()
    
    if ($SdkPath) {
        # Convert path to Gradle-friendly format for Java properties file
        # In Java properties files, backslashes need to be escaped as \\
        # So we need to replace each \ with \\
        $gradleSdkPath = $SdkPath -replace '\\', '\\'
        $content += "sdk.dir=$gradleSdkPath"
    }
    
    if ($content.Count -eq 0) {
        Write-Error "No SDK paths to write"
        return $false
    }
    
    try {
        $content | Out-File -FilePath $localPropsPath -Encoding UTF8
        Write-Success "Created $localPropsPath"
        
        # Show the created content
        Write-Host "`nContents of $localPropsPath :" -ForegroundColor Cyan
        Get-Content $localPropsPath | ForEach-Object { Write-Host "  $_" }
        
        return $true
    } catch {
        Write-Error "Failed to create $localPropsPath : $_"
        return $false
    }
}

# Main execution
Write-Host "=== Android SDK/NDK Environment Setup for Windows ===" -ForegroundColor Magenta
Write-Host ""

# Find Android SDK
Write-Info "Searching for Android SDK..."
$sdkPath = Find-AndroidSdk

if (-not $sdkPath) {
    Write-Error "Could not find Android SDK automatically."
    Write-Host ""
    Write-Host "Please install Android Studio or the standalone Android SDK from:"
    Write-Host "  https://developer.android.com/studio"
    Write-Host ""
    Write-Host "Common installation locations:"
    Write-Host "  - %LOCALAPPDATA%\Android\Sdk"
    Write-Host "  - C:\Android\Sdk"
    Write-Host "  - %ProgramFiles%\Android\Android Studio\Sdk"
    Write-Host ""
    Write-Host "You can also set the ANDROID_HOME environment variable."
    exit 1
}

# Find Java/JBR
Write-Info "Searching for Java/JBR..."
$javaHome = Find-JavaHome

if ($javaHome) {
    $env:JAVA_HOME = $javaHome
    Write-Success "JAVA_HOME set to: $javaHome"
} else {
    Write-Warning "Could not find Java/JBR automatically."
    Write-Host "Gradle might fail if JAVA_HOME is not set."
}

# Find Android NDK (Keep for verification, though not written to local.properties anymore)
Write-Info "Searching for Android NDK..."
$ndkPath = Find-AndroidNdk -SdkPath $sdkPath

if (-not $ndkPath) {
    Write-Warning "Could not find Android NDK automatically."
    Write-Host ""
    Write-Host "The NDK is required for building native code. You can:"
    Write-Host "  1. Install via Android Studio SDK Manager"
    Write-Host "  2. Download from: https://developer.android.com/ndk/downloads"
    Write-Host "  3. Set the ANDROID_NDK_HOME environment variable"
    Write-Host ""
    $continue = Read-Host "Continue without NDK? (y/N)"
    if ($continue -notmatch '^[Yy]') {
        exit 1
    }
}

# Create local.properties
Write-Info "Creating local.properties file..."
$success = Create-LocalProperties -SdkPath $sdkPath

if ($success) {
    Write-Host ""
    Write-Success "Setup completed successfully!"
    Write-Host ""
    if (-not $javaHome) {
        Write-Warning "Reminder: You may need to set JAVA_HOME manually before running gradlew."
    }
    Write-Host "Next steps:"
    Write-Host "  1. Run: .\gradlew assembleDebug"
    Write-Host "  2. If you move your SDK/NDK, run this script again"
    Write-Host "  3. To update paths manually, edit local.properties"
} else {
    Write-Error "Setup failed."
    exit 1
}
