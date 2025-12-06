# AES-256-CBC Packaging System for dele.sh

This directory contains tools for packaging `dele.sh` into encrypted native Android binaries using AES-256-CBC encryption, similar to gzexe but with stronger security.

## ⚠️ IMPORTANT: Template Status

**The launcher.c.template file contains PLACEHOLDER decompression code.** Before production use, you MUST:

1. Integrate a real gzip decompression library (recommended: [miniz](https://github.com/richgel999/miniz))
2. Replace the `tinfl_decompress_mem_to_heap()` placeholder implementation
3. Test thoroughly with encrypted scripts

The template currently demonstrates the structure and encryption/decryption flow, but will NOT properly decompress data without a real decompression library integrated.

## Overview

The packaging system performs the following steps:
1. **Process** - Optionally minify the original script (remove comments/blank lines)
2. **Compress** - Use gzip to reduce size
3. **Encrypt** - Apply AES-256-CBC encryption with PBKDF2 key derivation
4. **Embed** - Generate a C launcher with the encrypted payload embedded
5. **Compile** - Build native binaries for Android architectures (arm64, armv7, x86)
6. **Deploy** - Run on device without leaving plaintext on disk

## Files

- **pack.sh** - Main packaging script that encrypts and generates launcher.c
- **build.sh** - NDK compilation script for cross-compilation
- **launcher.c.template** - C source template with embedded AES/gzip implementations
- **README_pack.md** - This documentation

## Requirements

### Build Machine (Linux)
- Bash shell
- OpenSSL command-line tools
- gzip
- base64
- xxd (usually part of vim package)
- Android NDK (for compilation step)

### Target Device (Android)
- Android 5.0+ (API 21+)
- Root access (required to execute)
- Compatible architecture: arm64-v8a, armeabi-v7a, or x86

## Usage

### Step 1: Package the Script

```bash
cd /path/to/dele/repository

# Basic usage (auto-generates random key)
./tools/pack.sh

# With custom key
./tools/pack.sh --key "MySecretKey12345678901234567890"

# Custom input and output
./tools/pack.sh --input ./dele.sh --out-dir ./release --key "MyKey"

# Without minification (keep all comments)
./tools/pack.sh --no-minify --key "MyKey"
```

**Options:**
- `--input PATH` - Input script path (default: ./dele.sh)
- `--out-dir PATH` - Output directory (default: ./release)
- `--no-minify` - Disable comment removal and minification
- `--key KEY` - Encryption key (32 chars max; if not provided, generates random)

**Output:**
- `release/launcher.c` - Generated C source with embedded encrypted payload
- `release/BUILD_INSTRUCTIONS.txt` - Build commands and encryption key info

**IMPORTANT:** Save the encryption key shown during packaging! It's embedded in the launcher but shown for your records.

### Step 2: Compile with Android NDK

First, ensure you have Android NDK installed and `NDK_ROOT` set:

```bash
# Download NDK from: https://developer.android.com/ndk/downloads
# Extract and set environment variable
export NDK_ROOT=/path/to/android-ndk-r21e
```

Compile for all architectures:

```bash
./tools/build.sh
```

Or compile specific architectures:

```bash
# ARM64 only
./tools/build.sh --arch "arm64"

# ARM64 and ARMv7
./tools/build.sh --arch "arm64 armv7"

# With custom paths
./tools/build.sh --source ./release/launcher.c --output-dir ./release --ndk-root /opt/ndk
```

**Output binaries:**
- `release/dele_arm64` - ARM64-v8a (aarch64) binary
- `release/dele_armv7` - ARMv7 (32-bit ARM) binary
- `release/dele_x86` - x86 (32-bit Intel) binary

### Step 3: Deploy to Android Device

#### Push binary to device:

```bash
# Determine your device architecture
adb shell getprop ro.product.cpu.abi
# Result examples: arm64-v8a, armeabi-v7a, x86

# Push appropriate binary
adb push release/dele_arm64 /data/local/tmp/dele

# Set executable permissions
adb shell chmod 755 /data/local/tmp/dele
```

#### Run on device:

```bash
# Connect to device
adb shell

# Switch to root
su

# Navigate to binary location
cd /data/local/tmp

# Execute
./dele
```

**Alternative direct execution:**

```bash
adb shell "su -c '/data/local/tmp/dele'"
```

## Security Features

### Encryption
- **Algorithm:** AES-256-CBC
- **Key Derivation:** PBKDF2 with 100,000 iterations
- **IV:** Random 16-byte initialization vector per build
- **Encoding:** Base64 for embedded storage

### Key Obfuscation
The encryption key is split into 4 fragments of 8 bytes each and XOR-obfuscated in the C source:
```c
// Key fragments are stored as:
key_frag1[8] = { 0xXX, ... } ^ xor_mask
key_frag2[8] = { 0xXX, ... } ^ xor_mask
key_frag3[8] = { 0xXX, ... } ^ xor_mask
key_frag4[8] = { 0xXX, ... } ^ xor_mask
```

At runtime, the launcher reconstructs the key by:
1. XOR-ing each fragment with the mask
2. Concatenating fragments to form the 32-byte key

**Note:** This is *obfuscation*, not strong protection. A determined attacker with the binary can extract the key. The primary security comes from:
- No plaintext on disk during execution
- Binary-only distribution (harder to analyze than scripts)
- Compilation with `-O2 -s` and symbol stripping

### Execution Model
The launcher executes the script **without writing plaintext to disk**:
1. Decrypts payload in memory
2. Decompresses in memory
3. Creates a pipe to `/system/bin/sh -s`
4. Writes plaintext script to pipe stdin
5. Shell executes directly from pipe

This prevents forensic recovery of the plaintext script from disk.

## Architecture Details

### Supported Architectures

| Architecture | Android ABI | Compiler Target | Notes |
|--------------|-------------|-----------------|-------|
| arm64-v8a | aarch64 | aarch64-linux-android21-clang | 64-bit ARM (most modern devices) |
| armeabi-v7a | armv7 | armv7a-linux-androideabi21-clang | 32-bit ARM with NEON |
| x86 | x86 | i686-linux-android21-clang | 32-bit Intel (emulators, rare devices) |

### Compilation Flags
- `-O2` - Optimization level 2 (good balance of size/speed)
- `-s` - Strip symbols from binary
- `-fPIE -pie` - Position Independent Executable (required on Android)
- Additional stripping with `llvm-strip` after compilation

## Runtime Requirements

### Permissions
- **Root access** - Required to execute privileged operations in dele.sh
- **Executable permission** - Binary must have `chmod +x` or `0755`

### SELinux Considerations
If SELinux is enforcing, you may need to:
1. Set permissive mode (temporary): `setenforce 0`
2. Add appropriate SELinux rules for your domain
3. Run from allowed directories (e.g., `/data/local/tmp`)

Common SELinux issues:
```bash
# Check SELinux status
getenforce

# Check denials (if execution fails)
dmesg | grep avc | grep dele

# Temporary permissive mode (requires root)
su -c "setenforce 0"
```

### Android Version Compatibility
- **Minimum:** Android 5.0 (API 21)
- **Tested:** Android 7.0 - 13.0
- **Note:** Newer Android versions have stricter security; root access may require unlocked bootloader

## Troubleshooting

### Build Issues

**Problem:** `NDK_ROOT not set`
```bash
# Solution: Set environment variable
export NDK_ROOT=/path/to/android-ndk-r21e
```

**Problem:** Compiler not found
```bash
# Solution: Verify NDK installation and version
ls $NDK_ROOT/toolchains/llvm/prebuilt/
# Should show: linux-x86_64, darwin-x86_64, or windows-x86_64
```

**Problem:** `launcher.c not found`
```bash
# Solution: Run pack.sh first
./tools/pack.sh --key "YourKey"
```

### Runtime Issues

**Problem:** `Permission denied` when executing
```bash
# Solution: Check permissions
ls -l /data/local/tmp/dele
# Should show: -rwxr-xr-x or similar

# Fix permissions
adb shell chmod 755 /data/local/tmp/dele
```

**Problem:** `not found` error (even though file exists)
```bash
# Solution: Wrong architecture
# Check device architecture:
adb shell getprop ro.product.cpu.abi

# Use correct binary:
# arm64-v8a -> dele_arm64
# armeabi-v7a -> dele_armv7
# x86 -> dele_x86
```

**Problem:** Decryption fails at runtime
```bash
# Possible causes:
# 1. Corrupted binary during transfer
#    Solution: Re-push with adb
# 2. Template/script mismatch
#    Solution: Rebuild from clean state
# 3. Incorrect key embedded
#    Solution: Rerun pack.sh and rebuild
```

**Problem:** SELinux denials
```bash
# Check denials
adb shell "su -c 'dmesg | grep avc | tail -20'"

# Temporary fix (requires root)
adb shell "su -c 'setenforce 0'"

# Persistent fix: Add SELinux policy (advanced)
```

### Debugging

Enable verbose output by modifying launcher.c before compilation:
```c
// Add at start of main():
fprintf(stderr, "Launcher starting...\n");
fprintf(stderr, "Decoding payload...\n");
// etc.
```

Check device logs:
```bash
# Connect to device and monitor logs
adb shell
su
cd /data/local/tmp
./dele 2>&1 | tee dele_debug.log
```

## Version Management

### Current Version
The `version.txt` file in the repository root contains the version number:
```
3.0.0
```

This version reflects the packaging system version, not necessarily the dele.sh version.

### Updating dele.sh Version
The original `dele.sh` script contains a `CURRENT_VERSION` variable. **This PR does not modify dele.sh**, so if you want to update the version in the script:

1. Manually edit `dele.sh`:
```bash
# Change line 7:
CURRENT_VERSION="2.0.0"
# To:
CURRENT_VERSION="3.0.0"
```

2. Rebuild:
```bash
./tools/pack.sh --key "YourKey"
./tools/build.sh
```

## Advanced Usage

### Custom Build Flags
Edit `build.sh` and modify `COMMON_FLAGS`:
```bash
# Example: Add debug symbols
COMMON_FLAGS="-O2 -g -fPIE -pie -Wall"

# Example: Maximum optimization
COMMON_FLAGS="-O3 -s -fPIE -pie -Wall -flto"
```

### Alternative Compression
The template uses gzip. To use other compression:
1. Modify `pack.sh` compression step
2. Update `launcher.c.template` decompression logic
3. Ensure embedded decompressor is compatible

### Multiple Keys
Generate separate binaries with different keys:
```bash
./tools/pack.sh --key "KeyForProduction" --out-dir ./release_prod
./tools/build.sh --source ./release_prod/launcher.c --output-dir ./release_prod

./tools/pack.sh --key "KeyForTesting" --out-dir ./release_test
./tools/build.sh --source ./release_test/launcher.c --output-dir ./release_test
```

## Security Considerations

### Threat Model
This packaging system protects against:
- ✓ Casual inspection of script contents
- ✓ Simple file system forensics
- ✓ Accidental exposure of plaintext
- ✓ Basic static analysis

This system does NOT protect against:
- ✗ Determined reverse engineering of the binary
- ✗ Runtime memory inspection (root debugger)
- ✗ Key extraction through binary analysis
- ✗ Network-based attacks (not relevant here)

### Best Practices
1. **Use strong, random keys** for production builds
2. **Keep encryption keys secret** - don't commit to git
3. **Don't distribute template or pack.sh** with keys
4. **Rotate keys regularly** for sensitive deployments
5. **Test on target devices** before distribution
6. **Monitor for SELinux issues** in logs
7. **Keep NDK and tools updated** for security patches

### Limitations
- Key is embedded in binary (can be extracted with effort)
- No remote key fetch or hardware-backed keystore
- No device-specific binding (requested by user)
- Obfuscation is not encryption of the key itself

## Git and CI/CD

### What to Commit
✓ Commit these files:
- `tools/pack.sh`
- `tools/build.sh`
- `tools/launcher.c.template`
- `tools/README_pack.md`
- `version.txt`

✗ DO NOT commit:
- `release/` directory (build artifacts)
- Generated `launcher.c` (contains encrypted payload)
- Compiled binaries (`dele_arm64`, etc.)
- `BUILD_INSTRUCTIONS.txt` (contains keys)

### .gitignore
Add to repository `.gitignore`:
```
# Build artifacts
release/
tools/release/

# Generated sources
launcher.c

# Build instructions (may contain keys)
BUILD_INSTRUCTIONS.txt
```

### CI/CD Pipeline
Example GitHub Actions workflow:
```yaml
name: Build Encrypted Binaries

on:
  workflow_dispatch:
    inputs:
      encryption_key:
        description: 'Encryption key'
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install NDK
        run: |
          wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip
          unzip android-ndk-r21e-linux-x86_64.zip
          echo "NDK_ROOT=$PWD/android-ndk-r21e" >> $GITHUB_ENV
      
      - name: Package Script
        run: ./tools/pack.sh --key "${{ github.event.inputs.encryption_key }}"
      
      - name: Build Binaries
        run: ./tools/build.sh
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v2
        with:
          name: encrypted-binaries
          path: release/dele_*
```

## Testing

### Local Testing
Before deploying to device:

1. **Verify packaging:**
```bash
./tools/pack.sh --key "TestKey123" --out-dir ./test_release
ls -lh ./test_release/
# Should show launcher.c and BUILD_INSTRUCTIONS.txt
```

2. **Verify compilation:**
```bash
export NDK_ROOT=/path/to/ndk
./tools/build.sh --source ./test_release/launcher.c --output-dir ./test_release
ls -lh ./test_release/dele_*
# Should show compiled binaries
```

3. **Basic binary check:**
```bash
file ./test_release/dele_arm64
# Should show: ELF 64-bit LSB executable, ARM aarch64...
```

### Device Testing
1. Push to test device
2. Execute and verify output
3. Check that script functions work correctly
4. Verify no plaintext written to disk
5. Test with SELinux enforcing

## FAQ

**Q: Do I need to modify dele.sh?**  
A: No, this PR does not modify dele.sh. It creates a packaging system around it.

**Q: Can I use this without root?**  
A: The launcher itself doesn't require root, but dele.sh operations likely do.

**Q: What if I lose the encryption key?**  
A: The key is embedded in launcher.c, but you should save it separately for records. If both are lost, you must repackage from source.

**Q: Can I run this on non-Android Linux?**  
A: The launcher is designed for Android, but with minor modifications it could work on standard Linux.

**Q: Is this more secure than just distributing dele.sh?**  
A: Yes, in several ways: (1) no plaintext on disk, (2) harder to inspect/modify, (3) encrypted payload. But it's not military-grade security.

**Q: Can I distribute only the binary without the source?**  
A: Yes, that's the intended use case. Keep pack.sh, template, and source private; distribute only the compiled binaries.

## Support

For issues or questions:
1. Check this README first
2. Review `BUILD_INSTRUCTIONS.txt` in release directory
3. Check device logs: `adb logcat` or `dmesg`
4. Contact: @闲鱼:WuTa (as specified in dele.sh)

## License

This packaging system follows the same license as the main dele repository.
