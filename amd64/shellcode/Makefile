# Assembler
AS = as
# Assembler flags
ASFLAGS=
CCFLAGS=-Wall -fno-stack-protector -z execstack -g

# Shellcode source assembly files with .s extension
SRCS_ASM = $(wildcard code/*.s)
# Object files for shellcode assembly sources
OBJS_ASM = $(patsubst code/%.s, code/%.o, $(SRCS_ASM))

# Shellcode generation directory
SHELLCODE_DIR = code
# Shellcode output files
SHELLCODE_FILES = $(addprefix $(SHELLCODE_DIR)/, $(OBJS_ASM:code/%.o=%.bin))

# Executable name (C source)
EXEC_C = shellexec

# Default target
all: $(EXEC_C) $(SHELLCODE_FILES)

# Compile the C source file
$(EXEC_C): shellexec.c
	gcc $(CCFLAGS) -o $@ $<

# Assembly step for each shellcode source file
$(SHELLCODE_DIR)/%.o: code/%.s
	$(AS) $(ASFLAGS) -o $@ $<

# Generate shellcode from object files
$(SHELLCODE_DIR)/%.bin: $(SHELLCODE_DIR)/%.o
	objcopy -O binary -j .text $< $@

# Clean up object files, executables, and shellcode files
clean:
	rm -f $(EXEC_C) *.o $(SHELLCODE_DIR)/*.o $(SHELLCODE_DIR)/*.bin
