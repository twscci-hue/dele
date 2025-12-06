LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# Module name
LOCAL_MODULE := dele_launcher

# Source files (launcher.c will be generated in release/ by pack.sh)
LOCAL_SRC_FILES := ../release/launcher.c

# Link against OpenSSL and zlib
LOCAL_LDLIBS := -lz -llog
LOCAL_STATIC_LIBRARIES := libcrypto_static

# C flags
LOCAL_CFLAGS := -Wall -Wextra -O2 -DANDROID

# Support for multiple architectures
LOCAL_MULTILIB := both

include $(BUILD_EXECUTABLE)

# Import OpenSSL prebuilt library
$(call import-module,openssl)
