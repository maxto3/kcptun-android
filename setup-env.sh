#!/bin/bash
# setup-env.sh - Android SDK/NDK environment setup script for Linux/macOS
# This script automatically detects Android SDK and NDK paths and creates local.properties

set -e

FORCE=0
HELP=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=1
            shift
            ;;
        -h|--help)
            HELP=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ $HELP -eq 1 ]]; then
    echo "Usage: ./setup-env.sh [-f|--force] [-h|--help]"
    echo ""
    echo "Options:"
    echo "  -f, --force    Overwrite existing local.properties file"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Description:"
    echo "  Automatically detects Android SDK and NDK paths on Linux/macOS and creates"
    echo "  local.properties file for Gradle builds."
    exit 0
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

write_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

write_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

write_error() {
    echo -e "${RED}✗ $1${NC}"
}

find_android_sdk() {
    # Common Android SDK installation paths on Linux/macOS
    local possible_paths=()
    
    # Environment variables
    if [[ -n "$ANDROID_HOME" ]]; then
        possible_paths+=("$ANDROID_HOME")
    fi
    if [[ -n "$ANDROID_SDK_ROOT" ]]; then
        possible_paths+=("$ANDROID_SDK_ROOT")
    fi
    
    # Linux common locations
    possible_paths+=("$HOME/Android/Sdk")
    possible_paths+=("/opt/android/sdk")
    possible_paths+=("/usr/local/android/sdk")
    possible_paths+=("/usr/lib/android-sdk")
    
    # macOS common locations
    possible_paths+=("$HOME/Library/Android/sdk")
    possible_paths+=("/Applications/Android Studio.app/Contents/sdk")
    
    # Android Studio default locations
    possible_paths+=("$HOME/.android/sdk")
    
    for path in "${possible_paths[@]}"; do
        if [[ -n "$path" && -d "$path" ]]; then
            local resolved_path
            resolved_path=$(realpath "$path" 2>/dev/null || echo "$path")
            write_info "Found Android SDK at: $resolved_path"
            
            # Verify it's a valid SDK directory
            local platforms_dir="$resolved_path/platforms"
            local tools_dir="$resolved_path/tools"
            if [[ -d "$platforms_dir" || -d "$tools_dir" ]]; then
                write_success "Valid Android SDK directory confirmed"
                echo "$resolved_path"
                return 0
            else
                write_warning "Path exists but doesn't appear to be a valid Android SDK: $resolved_path"
            fi
        fi
    done
    
    return 1
}

find_java_home() {
    # Common Java/JBR installation paths on Linux/macOS
    local possible_paths=()
    
    # Environment variable
    if [[ -n "$JAVA_HOME" ]]; then
        possible_paths+=("$JAVA_HOME")
    fi
    
    # Android Studio JBR (JetBrains Runtime) - priority
    # Linux
    possible_paths+=("$HOME/android-studio/jbr")
    possible_paths+=("/opt/android-studio/jbr")
    possible_paths+=("/usr/local/android-studio/jbr")
    # macOS
    possible_paths+=("/Applications/Android Studio.app/Contents/jbr")
    possible_paths+=("$HOME/Applications/Android Studio.app/Contents/jbr")
    
    # Common JDK paths
    possible_paths+=("/usr/lib/jvm/default-java")
    possible_paths+=("/usr/lib/jvm/java-17-openjdk-amd64")
    possible_paths+=("/usr/lib/jvm/java-11-openjdk-amd64")
    
    for path in "${possible_paths[@]}"; do
        if [[ -n "$path" && -d "$path" ]]; then
            local resolved_path
            resolved_path=$(realpath "$path" 2>/dev/null || echo "$path")
            
            # If it's a directory containing bin/java, it's likely a valid JAVA_HOME
            if [[ -x "$resolved_path/bin/java" ]]; then
                write_info "Found Java/JBR at: $resolved_path"
                write_success "Valid Java environment confirmed"
                echo "$resolved_path"
                return 0
            fi
        fi
    done
    
    return 1
}

find_android_ndk() {
    local sdk_path="$1"
    local possible_paths=()
    
    # Environment variables
    if [[ -n "$ANDROID_NDK_HOME" ]]; then
        possible_paths+=("$ANDROID_NDK_HOME")
    fi
    if [[ -n "$ANDROID_NDK_ROOT" ]]; then
        possible_paths+=("$ANDROID_NDK_ROOT")
    fi
    
    # Within SDK directory
    if [[ -n "$sdk_path" ]]; then
        possible_paths+=("$sdk_path/ndk")
        possible_paths+=("$sdk_path/ndk-bundle")
    fi
    
    # Linux common locations
    possible_paths+=("$HOME/Android/Ndk")
    possible_paths+=("/opt/android/ndk")
    possible_paths+=("/usr/local/android/ndk")
    possible_paths+=("/usr/lib/android-ndk")
    
    # macOS common locations
    possible_paths+=("$HOME/Library/Android/ndk")
    
    # Standalone NDK installations
    possible_paths+=("/opt/android-ndk")
    possible_paths+=("/usr/local/android-ndk")
    
    for path in "${possible_paths[@]}"; do
        if [[ -n "$path" && -d "$path" ]]; then
            local resolved_path
            resolved_path=$(realpath "$path" 2>/dev/null || echo "$path")
            write_info "Found Android NDK at: $resolved_path"
            
            # Verify it's a valid NDK directory
            local toolchains_dir="$resolved_path/toolchains"
            if [[ -d "$toolchains_dir" ]]; then
                write_success "Valid Android NDK directory confirmed"
                echo "$resolved_path"
                return 0
            else
                write_warning "Path exists but doesn't appear to be a valid Android NDK: $resolved_path"
            fi
        fi
    done
    
    # Try to find NDK version directories within SDK
    if [[ -n "$sdk_path" && -d "$sdk_path/ndk" ]]; then
        local ndk_dir="$sdk_path/ndk"
        # Find the highest version number
        local latest_ndk
        latest_ndk=$(find "$ndk_dir" -maxdepth 1 -type d -name '*[0-9]*.*[0-9]*.*[0-9]*' | sort -V | tail -n 1)
        
        if [[ -n "$latest_ndk" && -d "$latest_ndk" ]]; then
            local version_name
            version_name=$(basename "$latest_ndk")
            write_success "Found Android NDK version: $version_name"
            echo "$latest_ndk"
            return 0
        fi
    fi
    
    return 1
}

create_local_properties() {
    local sdk_path="$1"
    local local_props_path="local.properties"
    
    if [[ -f "$local_props_path" && $FORCE -eq 0 ]]; then
        write_warning "local.properties already exists. Use --force to overwrite."
        read -r -p "Do you want to overwrite it? (y/N): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            write_info "Operation cancelled."
            return 1
        fi
    fi
    
    local content=""
    
    if [[ -n "$sdk_path" ]]; then
        # Convert path to Gradle-friendly format
        local gradle_sdk_path
        gradle_sdk_path=$(echo "$sdk_path" | sed 's/\\/\\/g')
        content+="sdk.dir=$gradle_sdk_path"
    fi
    
    if [[ -z "$content" ]]; then
        write_error "No SDK paths to write"
        return 1
    fi
    
    if echo "$content" > "$local_props_path"; then
        write_success "Created $local_props_path"
        
        # Show the created content
        echo -e "\n${CYAN}Contents of $local_props_path:${NC}"
        cat "$local_props_path" | while IFS= read -r line; do
            echo "  $line"
        done
        
        return 0
    else
        write_error "Failed to create $local_props_path"
        return 1
    fi
}

# Main execution
echo -e "${MAGENTA}=== Android SDK/NDK Environment Setup for Linux/macOS ===${NC}"
echo ""

# Find Android SDK
write_info "Searching for Android SDK..."
sdk_path=$(find_android_sdk || true)

if [[ -z "$sdk_path" ]]; then
    write_error "Could not find Android SDK automatically."
    echo ""
    echo "Please install Android Studio or the standalone Android SDK from:"
    echo "  https://developer.android.com/studio"
    echo ""
    echo "Common installation locations:"
    echo "  - Linux: ~/Android/Sdk, /opt/android/sdk"
    echo "  - macOS: ~/Library/Android/sdk"
    echo ""
    echo "You can also set the ANDROID_HOME environment variable:"
    echo "  export ANDROID_HOME=\$HOME/Android/Sdk"
    echo "  export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools"
    exit 1
fi

# Find Java/JBR
write_info "Searching for Java/JBR..."
java_home=$(find_java_home || true)

if [[ -n "$java_home" ]]; then
    export JAVA_HOME="$java_home"
    write_success "JAVA_HOME set to: $JAVA_HOME"
else
    write_warning "Could not find Java/JBR automatically."
    echo "Gradle might fail if JAVA_HOME is not set."
fi

# Find Android NDK (Keep for verification, though not written to local.properties anymore)
write_info "Searching for Android NDK..."
ndk_path=$(find_android_ndk "$sdk_path" || true)

if [[ -z "$ndk_path" ]]; then
    write_warning "Could not find Android NDK automatically."
    echo ""
    echo "The NDK is required for building native code. You can:"
    echo "  1. Install via Android Studio SDK Manager"
    echo "  2. Download from: https://developer.android.com/ndk/downloads"
    echo "  3. Set the ANDROID_NDK_HOME environment variable"
    echo ""
    read -r -p "Continue without NDK? (y/N): " continue_choice
    if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create local.properties
write_info "Creating local.properties file..."
if create_local_properties "$sdk_path"; then
    echo ""
    write_success "Setup completed successfully!"
    echo ""
    if [[ -z "$java_home" ]]; then
        write_warning "Reminder: You may need to set JAVA_HOME manually before running gradlew."
    else
        write_info "Note: Run 'source ./setup-env.sh' to apply JAVA_HOME to your current shell."
    fi
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./gradlew assembleDebug"
    echo "  2. If you move your SDK/NDK, run this script again"
    echo "  3. To update paths manually, edit local.properties"
else
    write_error "Setup failed."
    exit 1
fi
