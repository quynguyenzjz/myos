# Compiler settings
AS = nasm

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source files
BOOT_SRC = $(SRC_DIR)/boot/boot.asm

# Final binary
OS_IMAGE = $(BUILD_DIR)/myos.bin

.PHONY: all clean

all: $(OS_IMAGE)

$(OS_IMAGE): $(BOOT_SRC)
	$(AS) -f bin $< -o $@

clean:
	rm -f $(BUILD_DIR)/* 