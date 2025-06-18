# FBoot Makefile

# Assembler and flags
AS = nasm
ASFLAGS = -f bin

# Directories
SRC_DIR = src
BIN_DIR = bin

# Output binary name
OUT_BIN = $(BIN_DIR)/fboot.bin

# Phony targets
.PHONY: all clean


# By default, build the output binary
all: $(OUT_BIN)

# Build the output binary
$(OUT_BIN):
	mkdir -p $(BIN_DIR)

	$(AS) $(ASFLAGS) $(SRC_DIR)/boot.asm -o $(OUT_BIN)

# Delete build files
clean:
	rm -rf $(BIN_DIR)

