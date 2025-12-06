#!/bin/bash

# gzexe-style packaging tool for dele.sh
# Compresses, encrypts, and packages shell scripts into a native C launcher

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INPUT_FILE="./dele.sh"
OUT_DIR="./release"
NO_MINIFY=0
KEY=""

# Display usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Package shell scripts with gzip compression and AES-256-CBC encryption.

OPTIONS:
    --input FILE        Input shell script (default: ./dele.sh)
    --out-dir DIR       Output directory (default: ./release)
    --no-minify         Skip minification step
    --key KEY           AES-256-CBC encryption key (32 chars, required)
    -h, --help          Show this help message

EXAMPLE:
    $0 --key "your32characterencryptionkey12" --input ./dele.sh --out-dir ./release

NOTES:
    - The input script will NOT be modified
    - The key must be exactly 32 characters for AES-256-CBC
    - Requires: openssl, gzip, base64
    - Output: launcher.c in the specified output directory

EOF
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT_FILE="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        --no-minify)
            NO_MINIFY=1
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
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$KEY" ]; then
    echo -e "${RED}Error: --key parameter is required${NC}"
    usage
fi

# Validate key length (must be 32 characters for AES-256)
if [ ${#KEY} -ne 32 ]; then
    echo -e "${RED}Error: Key must be exactly 32 characters for AES-256-CBC${NC}"
    echo -e "${YELLOW}Current key length: ${#KEY} characters${NC}"
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file not found: $INPUT_FILE${NC}"
    exit 1
fi

# Check for required tools
for cmd in openssl gzip base64; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}Error: Required command not found: $cmd${NC}"
        exit 1
    fi
done

# Create output directory
mkdir -p "$OUT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}dele.sh Packaging Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Input:      $INPUT_FILE"
echo -e "Output Dir: $OUT_DIR"
echo -e "Minify:     $([ $NO_MINIFY -eq 1 ] && echo 'No' || echo 'Yes')"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Optionally minify the script
WORK_FILE=$(mktemp)
if [ $NO_MINIFY -eq 1 ]; then
    echo -e "${YELLOW}[1/6] Skipping minification...${NC}"
    cp "$INPUT_FILE" "$WORK_FILE"
else
    echo -e "${YELLOW}[1/6] Minifying script...${NC}"
    # Simple minification: remove comments and empty lines
    grep -v '^[[:space:]]*#' "$INPUT_FILE" | grep -v '^[[:space:]]*$' > "$WORK_FILE" || cp "$INPUT_FILE" "$WORK_FILE"
fi

ORIGINAL_SIZE=$(wc -c < "$INPUT_FILE")
MINIFIED_SIZE=$(wc -c < "$WORK_FILE")
echo -e "${GREEN}    Original size: $ORIGINAL_SIZE bytes${NC}"
echo -e "${GREEN}    Processed size: $MINIFIED_SIZE bytes${NC}"

# Step 2: Gzip compression
echo -e "${YELLOW}[2/6] Compressing with gzip...${NC}"
COMPRESSED_FILE=$(mktemp)
gzip -c "$WORK_FILE" > "$COMPRESSED_FILE"
COMPRESSED_SIZE=$(wc -c < "$COMPRESSED_FILE")
echo -e "${GREEN}    Compressed size: $COMPRESSED_SIZE bytes${NC}"

# Step 3: AES-256-CBC encryption
echo -e "${YELLOW}[3/6] Encrypting with AES-256-CBC...${NC}"
ENCRYPTED_FILE=$(mktemp)
# Use a fixed IV for reproducibility (in production, consider random IV)
IV="0123456789abcdef0123456789abcdef"
openssl enc -aes-256-cbc -in "$COMPRESSED_FILE" -out "$ENCRYPTED_FILE" -K "$(echo -n "$KEY" | xxd -p -c 32)" -iv "$IV" 2>/dev/null
ENCRYPTED_SIZE=$(wc -c < "$ENCRYPTED_FILE")
echo -e "${GREEN}    Encrypted size: $ENCRYPTED_SIZE bytes${NC}"

# Step 4: Base64 encoding
echo -e "${YELLOW}[4/6] Encoding to base64...${NC}"
BASE64_DATA=$(base64 < "$ENCRYPTED_FILE" | tr -d '\n')
BASE64_SIZE=${#BASE64_DATA}
echo -e "${GREEN}    Base64 size: $BASE64_SIZE bytes${NC}"

# Step 5: Obfuscate the key (simple XOR with a constant)
echo -e "${YELLOW}[5/6] Obfuscating encryption key...${NC}"
obfuscate_key() {
    local key="$1"
    local obf=""
    for ((i=0; i<${#key}; i++)); do
        local char="${key:$i:1}"
        local ascii=$(printf '%d' "'$char")
        local xor=$((ascii ^ 0x5A))
        obf="${obf}\\x$(printf '%02x' $xor)"
    done
    echo "$obf"
}

OBFUSCATED_KEY=$(obfuscate_key "$KEY")
echo -e "${GREEN}    Key obfuscated${NC}"

# Step 6: Generate launcher.c
echo -e "${YELLOW}[6/6] Generating launcher.c...${NC}"

LAUNCHER_FILE="$OUT_DIR/launcher.c"

cat > "$LAUNCHER_FILE" << 'EOF'
/*
 * Native C Launcher for encrypted shell script payload
 * Generated by dele.sh packaging tool
 * 
 * This launcher:
 * 1. Deobfuscates the encryption key
 * 2. Base64 decodes the payload
 * 3. AES-256-CBC decrypts the data
 * 4. Decompresses with gzip
 * 5. Executes the shell script
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <openssl/evp.h>
#include <openssl/aes.h>
#include <zlib.h>

// Obfuscated encryption key (XOR with 0x5A)
static const unsigned char OBFUSCATED_KEY[] = "OBFUSCATED_KEY_PLACEHOLDER";

// IV used for AES-256-CBC
static const unsigned char IV[] = {
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66
};

// Base64 encoded encrypted payload
static const char PAYLOAD[] = "PAYLOAD_PLACEHOLDER";

// Deobfuscate the key
static void deobfuscate_key(const unsigned char *obf, unsigned char *key, int len) {
    for (int i = 0; i < len; i++) {
        key[i] = obf[i] ^ 0x5A;
    }
}

// Base64 decode function
static int base64_decode(const char *input, unsigned char **output, size_t *output_len) {
    BIO *bio, *b64;
    size_t input_len = strlen(input);
    *output = malloc(input_len);
    if (!*output) {
        return -1;
    }
    
    bio = BIO_new_mem_buf(input, input_len);
    if (!bio) {
        free(*output);
        return -1;
    }
    
    b64 = BIO_new(BIO_f_base64());
    if (!b64) {
        BIO_free(bio);
        free(*output);
        return -1;
    }
    
    bio = BIO_push(b64, bio);
    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
    
    *output_len = BIO_read(bio, *output, input_len);
    BIO_free_all(bio);
    
    return (*output_len > 0) ? 0 : -1;
}

// AES-256-CBC decrypt function
static int aes_decrypt(const unsigned char *ciphertext, int ciphertext_len,
                      const unsigned char *key, const unsigned char *iv,
                      unsigned char **plaintext, int *plaintext_len) {
    EVP_CIPHER_CTX *ctx;
    int len;
    int ret = 0;
    
    *plaintext = malloc(ciphertext_len + EVP_MAX_BLOCK_LENGTH);
    if (!*plaintext) {
        return -1;
    }
    
    if (!(ctx = EVP_CIPHER_CTX_new())) {
        free(*plaintext);
        return -1;
    }
    
    if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        free(*plaintext);
        return -1;
    }
    
    if (EVP_DecryptUpdate(ctx, *plaintext, &len, ciphertext, ciphertext_len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        free(*plaintext);
        return -1;
    }
    *plaintext_len = len;
    
    if (EVP_DecryptFinal_ex(ctx, *plaintext + len, &len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        free(*plaintext);
        return -1;
    }
    *plaintext_len += len;
    
    EVP_CIPHER_CTX_free(ctx);
    return 0;
}

// Gzip decompress function
static int gzip_decompress(const unsigned char *compressed, int compressed_len,
                          unsigned char **decompressed, size_t *decompressed_len) {
    z_stream stream;
    int ret;
    size_t buf_size = compressed_len * 10; // Initial buffer size
    *decompressed = malloc(buf_size);
    if (!*decompressed) {
        return -1;
    }
    
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = compressed_len;
    stream.next_in = (Bytef *)compressed;
    stream.avail_out = buf_size;
    stream.next_out = *decompressed;
    
    // 15+16 for gzip format
    ret = inflateInit2(&stream, 15 + 16);
    if (ret != Z_OK) {
        free(*decompressed);
        return -1;
    }
    
    ret = inflate(&stream, Z_FINISH);
    if (ret != Z_STREAM_END) {
        inflateEnd(&stream);
        free(*decompressed);
        return -1;
    }
    
    *decompressed_len = stream.total_out;
    inflateEnd(&stream);
    
    return 0;
}

int main(int argc, char *argv[]) {
    unsigned char key[32];
    unsigned char *encrypted_data = NULL;
    size_t encrypted_len = 0;
    unsigned char *decrypted_data = NULL;
    int decrypted_len = 0;
    unsigned char *decompressed_data = NULL;
    size_t decompressed_len = 0;
    FILE *tmp_file;
    // Try multiple temp locations for better compatibility
    char tmp_path[256];
    const char *tmpdir = getenv("TMPDIR");
    if (tmpdir) {
        snprintf(tmp_path, sizeof(tmp_path), "%s/dele_XXXXXX", tmpdir);
    } else {
        snprintf(tmp_path, sizeof(tmp_path), "/data/local/tmp/dele_XXXXXX");
    }
    int fd;
    
    // Step 1: Deobfuscate key
    deobfuscate_key(OBFUSCATED_KEY, key, 32);
    
    // Step 2: Base64 decode
    if (base64_decode(PAYLOAD, &encrypted_data, &encrypted_len) != 0) {
        fprintf(stderr, "Failed to decode payload\n");
        return 1;
    }
    
    // Step 3: AES decrypt
    if (aes_decrypt(encrypted_data, encrypted_len, key, IV, &decrypted_data, &decrypted_len) != 0) {
        fprintf(stderr, "Failed to decrypt payload\n");
        free(encrypted_data);
        return 1;
    }
    free(encrypted_data);
    
    // Step 4: Gzip decompress
    if (gzip_decompress(decrypted_data, decrypted_len, &decompressed_data, &decompressed_len) != 0) {
        fprintf(stderr, "Failed to decompress payload\n");
        free(decrypted_data);
        return 1;
    }
    free(decrypted_data);
    
    // Step 5: Write to temporary file and execute
    fd = mkstemp(tmp_path);
    if (fd == -1) {
        fprintf(stderr, "Failed to create temporary file\n");
        free(decompressed_data);
        return 1;
    }
    
    if (write(fd, decompressed_data, decompressed_len) != (ssize_t)decompressed_len) {
        fprintf(stderr, "Failed to write temporary file\n");
        close(fd);
        unlink(tmp_path);
        free(decompressed_data);
        return 1;
    }
    close(fd);
    free(decompressed_data);
    
    // Make executable
    chmod(tmp_path, 0700);
    
    // Execute with sh
    char *exec_argv[] = { "/system/bin/sh", tmp_path, NULL };
    execv("/system/bin/sh", exec_argv);
    
    // If execv returns, there was an error
    fprintf(stderr, "Failed to execute script\n");
    unlink(tmp_path);
    return 1;
}
EOF

# Replace placeholders in launcher.c
# Escape the base64 data for C string (replace " with \", etc.)
ESCAPED_BASE64=$(echo "$BASE64_DATA" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

# Replace OBFUSCATED_KEY_PLACEHOLDER
sed -i "s|OBFUSCATED_KEY_PLACEHOLDER|$OBFUSCATED_KEY|g" "$LAUNCHER_FILE"

# Replace PAYLOAD_PLACEHOLDER (may need to split into multiple lines for very large payloads)
# For now, we'll put it on one line but in production you might want to split it
sed -i "s|PAYLOAD_PLACEHOLDER|$ESCAPED_BASE64|g" "$LAUNCHER_FILE"

echo -e "${GREEN}    Generated: $LAUNCHER_FILE${NC}"

# Cleanup
rm -f "$WORK_FILE" "$COMPRESSED_FILE" "$ENCRYPTED_FILE"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Packaging complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Output file: ${GREEN}$LAUNCHER_FILE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Build the launcher with Android NDK:"
echo -e "   ${BLUE}cd $OUT_DIR && ndk-build${NC}"
echo -e "2. Or use CMake:"
echo -e "   ${BLUE}cd $OUT_DIR && cmake . && make${NC}"
echo -e "3. The compiled launcher will execute the packaged script"
echo ""

exit 0
