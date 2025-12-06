#!/bin/bash

# Example usage script for pack.sh
# This demonstrates how to package dele.sh with different options

set -e

# Define a secure 32-character encryption key
# In production, use a secure key management system
ENCRYPTION_KEY="production_key_32_characters!"

echo "=== dele.sh Packaging Examples ==="
echo ""

# Example 1: Basic packaging with default settings
echo "Example 1: Basic packaging"
echo "Command: ./pack.sh --key \$ENCRYPTION_KEY --input ../dele.sh"
echo ""
./pack.sh --key "$ENCRYPTION_KEY" --input ../dele.sh --out-dir ../release_example1
echo ""
echo "---"
echo ""

# Example 2: Packaging without minification
echo "Example 2: Packaging without minification"
echo "Command: ./pack.sh --key \$ENCRYPTION_KEY --input ../dele.sh --no-minify"
echo ""
./pack.sh --key "$ENCRYPTION_KEY" --input ../dele.sh --no-minify --out-dir ../release_example2
echo ""
echo "---"
echo ""

# Example 3: Custom output directory
echo "Example 3: Custom output directory"
echo "Command: ./pack.sh --key \$ENCRYPTION_KEY --input ../dele.sh --out-dir ../custom_build"
echo ""
./pack.sh --key "$ENCRYPTION_KEY" --input ../dele.sh --out-dir ../custom_build
echo ""
echo "---"
echo ""

echo "=== All examples completed successfully ==="
echo ""
echo "Generated files:"
ls -lh ../release_example1/launcher.c ../release_example2/launcher.c ../custom_build/launcher.c 2>/dev/null || true
echo ""
echo "Next step: Build the launcher with Android NDK"
echo "See BUILD.md for detailed build instructions"
