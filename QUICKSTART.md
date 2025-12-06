# Quick Start Guide - dele.sh Native Launcher

This guide will get you started with packaging and building the dele.sh native launcher in under 5 minutes.

## Prerequisites

- Linux or macOS build machine
- Android NDK installed
- OpenSSL, gzip, and base64 (usually pre-installed)

## Step 1: Generate Encryption Key (30 seconds)

Generate a secure 32-character encryption key:

```bash
# Option 1: Random key
export ENCRYPTION_KEY=$(openssl rand -base64 24 | head -c 32)

# Option 2: Custom key (must be exactly 32 characters)
export ENCRYPTION_KEY="my_custom_key_exactly_32chars"
```

**Important:** Save this key securely! You'll need it to build the launcher.

## Step 2: Package the Script (1 minute)

Run the packaging tool:

```bash
cd /path/to/dele
./tools/pack.sh --key "$ENCRYPTION_KEY" --input ./dele.sh --out-dir ./release
```

This will:
- ✓ Minify the script (optional, use `--no-minify` to skip)
- ✓ Compress with gzip
- ✓ Encrypt with AES-256-CBC
- ✓ Generate `release/launcher.c`

## Step 3: Build for Android (2-3 minutes)

### Quick Build with NDK

```bash
# Set up environment
export ANDROID_NDK_HOME=/path/to/android-ndk

# Build for all architectures
cd release
cp ../tools/Android.mk ../tools/Application.mk .
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk
```

Built binaries will be in:
- `libs/arm64-v8a/dele_launcher` (64-bit ARM)
- `libs/armeabi-v7a/dele_launcher` (32-bit ARM)
- `libs/x86/dele_launcher` (x86)

## Step 4: Deploy and Run (30 seconds)

```bash
# Push to Android device
adb push libs/arm64-v8a/dele_launcher /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dele_launcher

# Execute (requires root)
adb shell su -c /data/local/tmp/dele_launcher
```

## Complete Example

```bash
# 1. Generate key
export ENCRYPTION_KEY=$(openssl rand -base64 24 | head -c 32)

# 2. Package
./tools/pack.sh --key "$ENCRYPTION_KEY" --input ./dele.sh --out-dir ./release

# 3. Build
cd release
cp ../tools/Android.mk ../tools/Application.mk .
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk

# 4. Deploy
adb push libs/arm64-v8a/dele_launcher /data/local/tmp/
adb shell chmod 755 /data/local/tmp/dele_launcher
adb shell su -c /data/local/tmp/dele_launcher
```

## Troubleshooting

### "Key must be exactly 32 characters"
```bash
# Check key length
echo -n "$ENCRYPTION_KEY" | wc -c
# Should output: 32
```

### "openssl: command not found"
```bash
# Ubuntu/Debian
sudo apt-get install openssl

# macOS
brew install openssl
```

### "NDK not found"
```bash
# Set NDK path
export ANDROID_NDK_HOME=/path/to/android-ndk-r25c
export PATH=$ANDROID_NDK_HOME:$PATH
```

### Build fails with OpenSSL errors
The launcher requires OpenSSL. For Android builds:
- Use NDK's prebuilt OpenSSL libraries
- Or link statically with `-static`
- Or include OpenSSL sources in your project

## Next Steps

- Read [BUILD.md](BUILD.md) for comprehensive build instructions
- See [tools/README.md](tools/README.md) for pack.sh options
- Check [tools/example.sh](tools/example.sh) for more examples

## Security Notes

🔒 **Key Management**
- Never commit encryption keys to version control
- Use environment variables or secure key stores
- Different keys for dev/staging/production

🔒 **Binary Security**
- Don't commit compiled binaries to the repository
- Build in CI/CD from source
- Sign binaries for production distribution

## Support

For issues and questions, refer to the main repository documentation.
