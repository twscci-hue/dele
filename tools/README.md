# dele.sh Packaging Tools

This directory contains tools for packaging `dele.sh` into an encrypted native C launcher.

## Files

- **pack.sh** - Main packaging script that compresses, encrypts, and generates C launcher
- **Android.mk** - Android NDK build configuration for ndk-build
- **Application.mk** - Application-level NDK configuration
- **CMakeLists.txt** - CMake build configuration (alternative to NDK)

## Quick Start

### 1. Package the Script

```bash
./pack.sh --key "your32characterencryptionkey12" --input ../dele.sh --out-dir ../release
```

This will:
- Optionally minify the script (use `--no-minify` to skip)
- Compress with gzip
- Encrypt with AES-256-CBC
- Generate `launcher.c` in the output directory

### 2. Build the Native Launcher

See [BUILD.md](../BUILD.md) for complete build instructions.

## pack.sh Usage

```
./pack.sh [OPTIONS]

OPTIONS:
    --input FILE        Input shell script (default: ./dele.sh)
    --out-dir DIR       Output directory (default: ./release)
    --no-minify         Skip minification step
    --key KEY           AES-256-CBC encryption key (32 chars, required)
    -h, --help          Show help message
```

### Examples

```bash
# Basic usage
./pack.sh --key "production_key_32_characters!!"

# Custom input and output
./pack.sh --key "test_key_32_characters_long!" --input custom.sh --out-dir build

# Skip minification
./pack.sh --key "dev_key_exactly_32_characters!" --no-minify
```

## Requirements

- bash 4.0+
- openssl (for AES-256-CBC encryption)
- gzip (for compression)
- base64 (for encoding)
- Android NDK (for building native launcher)

## Security Notes

1. **Never commit encryption keys to version control**
2. Use environment variables for sensitive keys
3. Keep your encryption key exactly 32 characters
4. The original input script is never modified

## Build Methods

### Method 1: Android NDK (ndk-build)

```bash
cd ../release
cp ../tools/Android.mk ../tools/Application.mk .
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk
```

### Method 2: CMake

```bash
cd ../release
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=arm64-v8a \
      ..
make
```

## Output

After successful packaging and building, you'll have:

- `release/launcher.c` - Generated C source with embedded encrypted payload
- `release/libs/arm64-v8a/dele_launcher` - 64-bit ARM binary
- `release/libs/armeabi-v7a/dele_launcher` - 32-bit ARM binary
- `release/libs/x86/dele_launcher` - x86 binary

## Troubleshooting

### Key Length Error

```
Error: Key must be exactly 32 characters for AES-256-CBC
```

Solution: Ensure your encryption key is exactly 32 characters.

### OpenSSL Not Found

```
Error: Required command not found: openssl
```

Solution: Install OpenSSL (`apt-get install openssl` or `brew install openssl`)

### Input File Not Found

```
Error: Input file not found: ./dele.sh
```

Solution: Specify the correct path with `--input /path/to/dele.sh`

## For More Information

See [BUILD.md](../BUILD.md) for comprehensive build instructions, troubleshooting, and advanced usage.
