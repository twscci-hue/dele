#!/bin/bash
#
# pack.sh - AES-256-CBC encryption packaging script for dele.sh
# Generates launcher.c with embedded encrypted payload
#

set -e

# Default parameters
INPUT_SCRIPT="./dele.sh"
OUT_DIR="./release"
MINIFY=1
KEY=""
TEMPLATE="tools/launcher.c.template"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
    --input PATH        Input script path (default: ./dele.sh)
    --out-dir PATH      Output directory (default: ./release)
    --no-minify         Disable comment removal/minification
    --key KEY           Encryption key (if not provided, generates random)
    -h, --help          Show this help message

Example:
    $0 --input ./dele.sh --out-dir ./release --key "MySecretKey123"
    $0 --no-minify
EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT_SCRIPT="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        --no-minify)
            MINIFY=0
            shift
            ;;
        --key)
            KEY="$2"
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

# Validate input script exists
if [ ! -f "$INPUT_SCRIPT" ]; then
    echo -e "${RED}Error: Input script '$INPUT_SCRIPT' not found${NC}"
    exit 1
fi

# Validate template exists
if [ ! -f "$TEMPLATE" ]; then
    echo -e "${RED}Error: Template '$TEMPLATE' not found${NC}"
    exit 1
fi

# Check required tools
for tool in gzip openssl base64; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: Required tool '$tool' not found${NC}"
        exit 1
    fi
done

echo -e "${GREEN}=== AES-256-CBC Packaging Tool ===${NC}"
echo -e "Input script: $INPUT_SCRIPT"
echo -e "Output directory: $OUT_DIR"
echo -e "Minification: $([ $MINIFY -eq 1 ] && echo 'enabled' || echo 'disabled')"

# Create output directory
mkdir -p "$OUT_DIR"

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "\n${YELLOW}[1/7] Processing input script...${NC}"

# Copy input script to temp location
cp "$INPUT_SCRIPT" "$TEMP_DIR/script_original.sh"

# Optionally minify (remove comments, blank lines)
if [ $MINIFY -eq 1 ]; then
    echo -e "  → Removing comments and blank lines..."
    # Preserve shebang, remove standalone comment lines (lines starting with #), keep empty lines removal
    # This preserves inline comments and # in strings/commands
    awk '
        NR==1 && /^#!/ { print; next }
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }
        { print }
    ' "$TEMP_DIR/script_original.sh" > "$TEMP_DIR/script_processed.sh"
else
    cp "$TEMP_DIR/script_original.sh" "$TEMP_DIR/script_processed.sh"
fi

PROCESSED_SIZE=$(wc -c < "$TEMP_DIR/script_processed.sh")
echo -e "  → Processed script size: $PROCESSED_SIZE bytes"

# Generate or validate encryption key
echo -e "\n${YELLOW}[2/7] Preparing encryption key...${NC}"
if [ -z "$KEY" ]; then
    # Generate random 32-character key
    KEY=$(openssl rand -base64 32 | head -c 32)
    echo -e "  ${RED}→ Generated random key: $KEY${NC}"
    echo -e "  ${RED}→ IMPORTANT: Save this key for decryption!${NC}"
else
    echo -e "  → Using provided key (length: ${#KEY} chars)"
fi

# Ensure key is exactly 32 bytes for AES-256
if [ ${#KEY} -lt 32 ]; then
    # Pad key with zeros
    KEY=$(printf "%-32s" "$KEY")
elif [ ${#KEY} -gt 32 ]; then
    # Truncate key
    KEY=${KEY:0:32}
fi

# Generate random IV (16 bytes for AES CBC)
IV=$(openssl rand -hex 16)
echo -e "  → Generated IV: $IV"

# Compress the script
echo -e "\n${YELLOW}[3/7] Compressing script with gzip...${NC}"
gzip -c "$TEMP_DIR/script_processed.sh" > "$TEMP_DIR/script_compressed.gz"
COMPRESSED_SIZE=$(wc -c < "$TEMP_DIR/script_compressed.gz")
COMPRESSION_RATIO=$(awk "BEGIN {printf \"%.1f\", ($PROCESSED_SIZE/$COMPRESSED_SIZE)}")
echo -e "  → Compressed size: $COMPRESSED_SIZE bytes (${COMPRESSION_RATIO}x compression)"

# Encrypt with AES-256-CBC
echo -e "\n${YELLOW}[4/7] Encrypting with AES-256-CBC...${NC}"
# Use process substitution to avoid exposing key in process list
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
    -in "$TEMP_DIR/script_compressed.gz" \
    -out "$TEMP_DIR/script_encrypted.bin" \
    -pass file:<(printf '%s' "$KEY") \
    -iv "$IV"

ENCRYPTED_SIZE=$(wc -c < "$TEMP_DIR/script_encrypted.bin")
echo -e "  → Encrypted size: $ENCRYPTED_SIZE bytes"

# Base64 encode the ciphertext
echo -e "\n${YELLOW}[5/7] Base64 encoding...${NC}"
base64 -w 0 "$TEMP_DIR/script_encrypted.bin" > "$TEMP_DIR/ciphertext_b64.txt"
CIPHERTEXT_B64=$(cat "$TEMP_DIR/ciphertext_b64.txt")
B64_SIZE=${#CIPHERTEXT_B64}
echo -e "  → Base64 size: $B64_SIZE chars"

# Obfuscate key by splitting into fragments with XOR mask
echo -e "\n${YELLOW}[6/7] Generating obfuscated key fragments...${NC}"

# Generate random XOR mask (simple obfuscation)
XOR_MASK=$((RANDOM % 256))
echo -e "  → XOR mask: 0x$(printf '%02x' $XOR_MASK)"

# Convert key to hex and split into 4 fragments of 8 bytes each
KEY_HEX=$(echo -n "$KEY" | xxd -p | tr -d '\n')

# Split into 4 parts
FRAG1_HEX=${KEY_HEX:0:16}   # 8 bytes = 16 hex chars
FRAG2_HEX=${KEY_HEX:16:16}
FRAG3_HEX=${KEY_HEX:32:16}
FRAG4_HEX=${KEY_HEX:48:16}

# XOR each fragment with mask and format as C array
obfuscate_fragment() {
    local hex_str=$1
    local result="{ "
    for i in $(seq 0 2 $((${#hex_str}-2))); do
        byte_hex=${hex_str:$i:2}
        byte_dec=$((16#$byte_hex))
        xor_result=$(($byte_dec ^ $XOR_MASK))
        result="${result}0x$(printf '%02x' $xor_result), "
    done
    result="${result%%, } }"
    echo "$result"
}

FRAG1_C=$(obfuscate_fragment "$FRAG1_HEX")
FRAG2_C=$(obfuscate_fragment "$FRAG2_HEX")
FRAG3_C=$(obfuscate_fragment "$FRAG3_HEX")
FRAG4_C=$(obfuscate_fragment "$FRAG4_HEX")

# Convert IV to C array
IV_C="{ "
for i in $(seq 0 2 30); do
    byte_hex=${IV:$i:2}
    IV_C="${IV_C}0x$byte_hex, "
done
IV_C="${IV_C%%, } }"

echo -e "  → Key fragments generated"

# Generate launcher.c from template
echo -e "\n${YELLOW}[7/7] Generating launcher.c...${NC}"

cp "$TEMPLATE" "$OUT_DIR/launcher.c"

# Replace placeholders in launcher.c
# Note: Using @ as delimiter to avoid conflicts with special chars in base64

# Replace ciphertext
sed -i "s@PLACEHOLDER_CIPHERTEXT_B64@$CIPHERTEXT_B64@g" "$OUT_DIR/launcher.c"

# Replace key fragments
sed -i "s@{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; /\* PLACEHOLDER_FRAG1 \*/@$FRAG1_C; /* XOR obfuscated */@g" "$OUT_DIR/launcher.c"
sed -i "s@{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; /\* PLACEHOLDER_FRAG2 \*/@$FRAG2_C; /* XOR obfuscated */@g" "$OUT_DIR/launcher.c"
sed -i "s@{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; /\* PLACEHOLDER_FRAG3 \*/@$FRAG3_C; /* XOR obfuscated */@g" "$OUT_DIR/launcher.c"
sed -i "s@{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }; /\* PLACEHOLDER_FRAG4 \*/@$FRAG4_C; /* XOR obfuscated */@g" "$OUT_DIR/launcher.c"

# Replace XOR mask
sed -i "s@0x00; /\* PLACEHOLDER_XOR_MASK \*/@0x$(printf '%02x' $XOR_MASK); /* XOR mask */@g" "$OUT_DIR/launcher.c"

# Replace IV (between markers)
sed -i "/\/\* PLACEHOLDER_IV_START \*\//,/\/\* PLACEHOLDER_IV_END \*\//c\\
/* PLACEHOLDER_IV_START */\\
static const unsigned char aes_iv[AES_BLOCKLEN] = $IV_C;\\
/* PLACEHOLDER_IV_END */" "$OUT_DIR/launcher.c"

echo -e "  → launcher.c generated: $OUT_DIR/launcher.c"

# Generate build instructions
cat > "$OUT_DIR/BUILD_INSTRUCTIONS.txt" <<EOF
=== Build Instructions for Android NDK ===

Generated: $(date)
Encryption Key: $KEY
IV: $IV

To compile launcher.c for Android architectures, use the following commands:

Prerequisites:
- Android NDK installed (set NDK_ROOT environment variable)
- Supported architectures: arm64-v8a, armeabi-v7a, x86

Build Commands:
----------------

# ARM64 (aarch64)
\$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \\
    -O2 -s -fPIE -pie \\
    -o dele_arm64 \\
    launcher.c

# ARMv7 (32-bit ARM)
\$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang \\
    -O2 -s -fPIE -pie -march=armv7-a -mfloat-abi=softfp -mfpu=neon \\
    -o dele_armv7 \\
    launcher.c

# x86 (32-bit Intel)
\$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android21-clang \\
    -O2 -s -fPIE -pie \\
    -o dele_x86 \\
    launcher.c

Deployment:
-----------
# Push to device
adb push dele_arm64 /data/local/tmp/dele
adb shell chmod 755 /data/local/tmp/dele

# Run as root
adb shell
su
cd /data/local/tmp
./dele

Notes:
- The launcher contains embedded encrypted script
- No plaintext script is written to disk during execution
- Requires root access on device
- Make sure SELinux is permissive or add appropriate rules

EOF

echo -e "\n${GREEN}=== Packaging Complete ===${NC}"
echo -e "\nOutput files:"
echo -e "  - $OUT_DIR/launcher.c (C source with embedded payload)"
echo -e "  - $OUT_DIR/BUILD_INSTRUCTIONS.txt (NDK build commands)"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. Review $OUT_DIR/BUILD_INSTRUCTIONS.txt"
echo -e "  2. Use Android NDK to compile launcher.c (see tools/build.sh)"
echo -e "  3. Deploy binaries to device and test"
echo -e "\n${RED}IMPORTANT: Save your encryption key!${NC}"
echo -e "Key: $KEY\n"
