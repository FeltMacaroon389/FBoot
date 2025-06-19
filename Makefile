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
.PHONY: all help clean


# By default, build the output binary
all: $(OUT_BIN)

# Display help menu about this Makefile
help:
	@echo "Usage: make <target>"
	@echo " "
	@echo "Targets:"
	@echo "    <NO OPTIONS> - same as $(OUT_BIN)"
	@echo "    help		- Display this help menu"
	@echo "    $(OUT_BIN)	- Build the output binary"
	@echo "    clean	- Delete build files"
	@echo " "

# Build the output binary
$(OUT_BIN):
	mkdir -p $(BIN_DIR)

	$(AS) $(ASFLAGS) $(SRC_DIR)/boot.asm -o $(OUT_BIN)

# Delete build files
clean:
	rm -rf $(BIN_DIR)

