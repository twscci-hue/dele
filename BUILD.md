# Build Instructions for dele.sh Native Launcher

This document describes how to package `dele.sh` into an encrypted native C launcher for Android.

## Overview

The packaging workflow:
1. Optionally minifies the shell script
2. Compresses with gzip
3. Encrypts with AES-256-CBC
4. Base64 encodes the encrypted data
5. Generates a native C launcher with embedded payload
6. Compiles for Android architectures (arm64-v8a, armeabi-v7a, x86)

## Prerequisites

### Build Machine Requirements (Linux/macOS)

Required tools:
- `bash` (version 4.0+)
- `openssl` (for encryption)
- `gzip` (for compression)
- `base64` (for encoding)
- Android NDK (for native compilation)

#### Installing Android NDK

**Option 1: Android Studio**
1. Install Android Studio
2. Open SDK Manager (Tools → SDK Manager)
3. Go to SDK Tools tab
4. Check "NDK (Side by side)" and install

**Option 2: Command Line**
```bash
# Download NDK
wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip

# Extract
unzip android-ndk-r25c-linux.zip

# Set environment variable
export ANDROID_NDK_HOME=/path/to/android-ndk-r25c
export PATH=$ANDROID_NDK_HOME:$PATH
```

## Usage

### Step 1: Package the Script

Use `tools/pack.sh` to create the encrypted launcher:

```bash
cd /path/to/dele
./tools/pack.sh --key "your32characterencryptionkey12" --input ./dele.sh --out-dir ./release
```

#### pack.sh Options

- `--input FILE` - Input shell script (default: `./dele.sh`)
- `--out-dir DIR` - Output directory (default: `./release`)
- `--no-minify` - Skip minification step
- `--key KEY` - AES-256-CBC encryption key (**required**, must be exactly 32 characters)

#### Example with Custom Options

```bash
# Package without minification
./tools/pack.sh --key "my_super_secret_key_32_chars!!" --input ./dele.sh --out-dir ./build --no-minify

# Package with default output directory
./tools/pack.sh --key "production_key_32characters!!" --input ./custom_script.sh
```

**Important Notes:**
- The encryption key must be exactly 32 characters for AES-256-CBC
- The original `dele.sh` file is **never modified**
- Keep your encryption key secure and private

### Step 2: Build the Native Launcher

After running `pack.sh`, you'll have `launcher.c` in your output directory. Now compile it for Android.

#### Method 1: Using Android NDK (ndk-build)

```bash
# Set up environment
export ANDROID_NDK_HOME=/path/to/android-ndk
cd /path/to/dele

# Copy build files to release directory
cp tools/Android.mk release/
cp tools/Application.mk release/

# Build for all architectures
cd release
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk

# Built binaries will be in: libs/arm64-v8a/, libs/armeabi-v7a/, libs/x86/
```

#### Method 2: Using CMake with Android Toolchain

```bash
# Set up environment
export ANDROID_NDK_HOME=/path/to/android-ndk

# Build for arm64-v8a
mkdir -p release/build-arm64
cd release/build-arm64
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_PLATFORM=android-21 \
      ..
make

# Build for armeabi-v7a
mkdir -p ../build-armv7
cd ../build-armv7
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=armeabi-v7a \
      -DANDROID_PLATFORM=android-21 \
      ..
make

# Build for x86
mkdir -p ../build-x86
cd ../build-x86
cmake -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=x86 \
      -ANDROID_PLATFORM=android-21 \
      ..
make
```

#### Method 3: Direct Compilation (Advanced)

For direct cross-compilation:

```bash
# For arm64-v8a
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
    -o dele_launcher_arm64 \
    launcher.c \
    -lz -lcrypto -static

# For armeabi-v7a
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang \
    -o dele_launcher_armv7 \
    launcher.c \
    -lz -lcrypto -static

# For x86
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android21-clang \
    -o dele_launcher_x86 \
    launcher.c \
    -lz -lcrypto -static
```

### Step 3: Deploy and Run

```bash
# Push to Android device
adb push libs/arm64-v8a/dele_launcher /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dele_launcher

# Execute (requires root)
adb shell su -c /data/local/tmp/dele_launcher
```

## Architecture Support

The build system supports three Android architectures:

| Architecture | Description | Devices |
|-------------|-------------|---------|
| arm64-v8a | 64-bit ARM | Modern Android devices (2015+) |
| armeabi-v7a | 32-bit ARM | Older Android devices |
| x86 | 32-bit Intel | Android emulators, some tablets |

## Security Considerations

1. **Encryption Key Management**
   - Never commit encryption keys to version control
   - Use environment variables or secure key management
   - Consider using different keys for different environments

2. **Obfuscation**
   - The launcher uses simple XOR obfuscation for the key
   - For production, consider stronger obfuscation techniques
   - The payload is encrypted with AES-256-CBC

3. **Binary Distribution**
   - Do not commit compiled binaries to the repository
   - Binaries should be built from source in CI/CD
   - Sign binaries for production distribution

## Troubleshooting

### OpenSSL Not Found

If you get OpenSSL linking errors:

```bash
# On Linux
sudo apt-get install libssl-dev

# On macOS
brew install openssl
```

For Android NDK builds, ensure you have OpenSSL compiled for Android or link statically.

### "launcher.c not found"

Make sure you run `pack.sh` before attempting to build:

```bash
./tools/pack.sh --key "your32characterencryptionkey12"
```

### NDK Build Fails

Check your NDK installation:

```bash
# Verify NDK path
echo $ANDROID_NDK_HOME
ls $ANDROID_NDK_HOME/ndk-build

# Verify NDK version (r21+ recommended)
$ANDROID_NDK_HOME/ndk-build --version
```

### Permission Denied on Android

The launcher requires root access on Android:

```bash
# Execute with root
adb shell su -c /path/to/dele_launcher

# Or enter shell first
adb shell
su
/path/to/dele_launcher
```

## Complete Build Example

Here's a complete workflow from scratch:

```bash
# 1. Clone repository
git clone https://github.com/twscci-hue/dele.git
cd dele

# 2. Package the script
./tools/pack.sh --key "my_production_key_exactly_32!!" --input ./dele.sh --out-dir ./release

# 3. Build for all architectures
cd release
cp ../tools/Android.mk ../tools/Application.mk .
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk

# 4. Check built binaries
ls -lh libs/*/dele_launcher

# 5. Deploy to device
adb push libs/arm64-v8a/dele_launcher /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dele_launcher
adb shell su -c /data/local/tmp/dele_launcher
```

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Build Native Launcher

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Android NDK
        uses: nttld/setup-ndk@v1
        with:
          ndk-version: r25c
      
      - name: Package script
        run: |
          ./tools/pack.sh --key "${{ secrets.ENCRYPTION_KEY }}" --input ./dele.sh --out-dir ./release
      
      - name: Build launcher
        run: |
          cd release
          cp ../tools/Android.mk ../tools/Application.mk .
          $ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: dele-launcher
          path: release/libs/
```

## Advanced Usage

### Custom Minification

If you want to use a custom minification tool:

```bash
# Skip built-in minification
./tools/pack.sh --no-minify --key "key..." --input ./dele.sh

# Use your own minifier
your-minifier dele.sh > dele.min.sh
./tools/pack.sh --key "key..." --input ./dele.min.sh
```

### Multiple Scripts

Package different scripts for different purposes:

```bash
# Development version
./tools/pack.sh --key "dev_key_32_characters_long!!" --input ./dele.sh --out-dir ./dev-release

# Production version with minification
./tools/pack.sh --key "prod_key_32_characters_long!" --input ./dele.sh --out-dir ./prod-release
```

## License

This build system and tools are part of the dele project. See the main project for license information.
