# Application.mk for dele_launcher
# Specifies Android platform and target architectures

# Target Android API level (Android 5.0+)
APP_PLATFORM := android-21

# Target ABIs (architectures)
APP_ABI := arm64-v8a armeabi-v7a x86

# Use libc++ as the C++ standard library
APP_STL := c++_shared

# Optimization level
APP_OPTIM := release

# Enable all warnings
APP_CFLAGS := -Wall -Wextra

# Define debug flag for debug builds
ifeq ($(APP_OPTIM),debug)
    APP_CFLAGS += -DDEBUG
endif
