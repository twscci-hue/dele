# dele
清理

## Native Launcher Packaging

This repository includes a gzexe-style packaging workflow that compresses and encrypts `dele.sh` into a native C launcher for Android.

### Quick Start

```bash
# Package the script
./tools/pack.sh --key "your32characterencryptionkey12" --input ./dele.sh --out-dir ./release

# Build for Android (requires Android NDK)
cd release
$ANDROID_NDK_HOME/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./Application.mk
```

### Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[BUILD.md](BUILD.md)** - Comprehensive build instructions
- **[tools/README.md](tools/README.md)** - Packaging tool documentation

### Features

- ✓ Gzip compression
- ✓ AES-256-CBC encryption
- ✓ Native C launcher
- ✓ Multi-architecture support (arm64-v8a, armeabi-v7a, x86)
- ✓ Original script unchanged
