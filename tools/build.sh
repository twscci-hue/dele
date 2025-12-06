#!/bin/bash
#
# build.sh - Android NDK compilation script for launcher.c
# Compiles for arm64-v8a, armeabi-v7a, and x86 architectures
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Default parameters
LAUNCHER_SOURCE="./release/launcher.c"
OUTPUT_DIR="./release"
NDK_ROOT="${NDK_ROOT:-}"
ARCHITECTURES="arm64 armv7 x86"

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
    --source PATH       Launcher C source file (default: ./release/launcher.c)
    --output-dir PATH   Output directory for binaries (default: ./release)
    --ndk-root PATH     Android NDK root path (or set NDK_ROOT env var)
    --arch LIST         Space-separated architecture list: arm64, armv7, x86
                        (default: "arm64 armv7 x86")
    -h, --help          Show this help message

Environment Variables:
    NDK_ROOT            Path to Android NDK installation

Example:
    export NDK_ROOT=/path/to/android-ndk-r21e
    $0 --source ./release/launcher.c --output-dir ./release

    # Build only ARM64
    $0 --arch "arm64"
    
    # Build with explicit NDK path
    $0 --ndk-root /opt/android-ndk-r21e
EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --source)
            LAUNCHER_SOURCE="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --ndk-root)
            NDK_ROOT="$2"
            shift 2
            ;;
        --arch)
            ARCHITECTURES="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

echo -e "${GREEN}=== Android NDK Build Script ===${NC}"

# Validate NDK_ROOT
if [ -z "$NDK_ROOT" ]; then
    echo -e "${RED}Error: NDK_ROOT not set. Please set NDK_ROOT environment variable or use --ndk-root option.${NC}"
    echo -e "${YELLOW}Example: export NDK_ROOT=/path/to/android-ndk-r21e${NC}"
    exit 1
fi

if [ ! -d "$NDK_ROOT" ]; then
    echo -e "${RED}Error: NDK_ROOT directory does not exist: $NDK_ROOT${NC}"
    exit 1
fi

# Validate source file
if [ ! -f "$LAUNCHER_SOURCE" ]; then
    echo -e "${RED}Error: Launcher source file not found: $LAUNCHER_SOURCE${NC}"
    echo -e "${YELLOW}Hint: Run tools/pack.sh first to generate launcher.c${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "\nNDK Root: $NDK_ROOT"
echo -e "Source: $LAUNCHER_SOURCE"
echo -e "Output: $OUTPUT_DIR"
echo -e "Architectures: $ARCHITECTURES\n"

# Detect NDK toolchain path
TOOLCHAIN_BASE="$NDK_ROOT/toolchains/llvm/prebuilt"

# Try to detect the host OS toolchain
if [ -d "$TOOLCHAIN_BASE/linux-x86_64" ]; then
    TOOLCHAIN="$TOOLCHAIN_BASE/linux-x86_64"
elif [ -d "$TOOLCHAIN_BASE/darwin-x86_64" ]; then
    TOOLCHAIN="$TOOLCHAIN_BASE/darwin-x86_64"
elif [ -d "$TOOLCHAIN_BASE/windows-x86_64" ]; then
    TOOLCHAIN="$TOOLCHAIN_BASE/windows-x86_64"
else
    echo -e "${RED}Error: Could not find NDK toolchain in $TOOLCHAIN_BASE${NC}"
    echo -e "${YELLOW}Available directories:${NC}"
    ls -1 "$TOOLCHAIN_BASE" 2>/dev/null || echo "  (none)"
    exit 1
fi

echo -e "${GREEN}Using toolchain: $TOOLCHAIN${NC}\n"

# Compilation flags
COMMON_FLAGS="-O2 -s -fPIE -pie -Wall"
MIN_SDK="21"  # Android 5.0

# Build function
build_arch() {
    local arch=$1
    local compiler=""
    local output_name=""
    local extra_flags=""
    
    case $arch in
        arm64)
            compiler="$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK}-clang"
            output_name="dele_arm64"
            echo -e "${BLUE}[1/3] Building ARM64-v8a (aarch64)...${NC}"
            ;;
        armv7)
            compiler="$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK}-clang"
            output_name="dele_armv7"
            extra_flags="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
            echo -e "${BLUE}[2/3] Building ARMv7 (armeabi-v7a)...${NC}"
            ;;
        x86)
            compiler="$TOOLCHAIN/bin/i686-linux-android${MIN_SDK}-clang"
            output_name="dele_x86"
            echo -e "${BLUE}[3/3] Building x86 (32-bit Intel)...${NC}"
            ;;
        *)
            echo -e "${RED}Unknown architecture: $arch${NC}"
            return 1
            ;;
    esac
    
    # Check if compiler exists
    if [ ! -f "$compiler" ]; then
        echo -e "${RED}  Error: Compiler not found: $compiler${NC}"
        return 1
    fi
    
    # Compile
    local output_path="$OUTPUT_DIR/$output_name"
    echo -e "  Compiler: $(basename "$compiler")"
    echo -e "  Output: $output_path"
    
    if "$compiler" $COMMON_FLAGS $extra_flags -o "$output_path" "$LAUNCHER_SOURCE"; then
        # Strip symbols for smaller size
        if [ -f "$TOOLCHAIN/bin/llvm-strip" ]; then
            "$TOOLCHAIN/bin/llvm-strip" "$output_path"
        fi
        
        local size=$(wc -c < "$output_path")
        local size_kb=$((size / 1024))
        echo -e "  ${GREEN}✓ Success! Size: ${size_kb}KB ($size bytes)${NC}"
        
        # Make executable
        chmod +x "$output_path"
        return 0
    else
        echo -e "  ${RED}✗ Build failed${NC}"
        return 1
    fi
}

# Build counter
total=0
success=0
failed=0

# Build each architecture
for arch in $ARCHITECTURES; do
    total=$((total + 1))
    if build_arch "$arch"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    echo ""
done

# Summary
echo -e "${GREEN}=== Build Summary ===${NC}"
echo -e "Total: $total"
echo -e "${GREEN}Success: $success${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}Failed: $failed${NC}"
fi

echo -e "\n${GREEN}Built binaries in: $OUTPUT_DIR${NC}"
ls -lh "$OUTPUT_DIR"/dele_* 2>/dev/null || true

if [ $success -eq $total ]; then
    echo -e "\n${GREEN}All builds completed successfully!${NC}"
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e "  1. Test binaries locally (if possible)"
    echo -e "  2. Push to Android device:"
    echo -e "     ${BLUE}adb push $OUTPUT_DIR/dele_arm64 /data/local/tmp/dele${NC}"
    echo -e "     ${BLUE}adb shell chmod 755 /data/local/tmp/dele${NC}"
    echo -e "  3. Run on device:"
    echo -e "     ${BLUE}adb shell${NC}"
    echo -e "     ${BLUE}su${NC}"
    echo -e "     ${BLUE}/data/local/tmp/dele${NC}"
    exit 0
else
    echo -e "\n${RED}Some builds failed. Check errors above.${NC}"
    exit 1
fi
