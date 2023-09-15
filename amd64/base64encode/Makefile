EXE=base64encode
AS=as
ASFLAGS=-g
LD=ld
LDFLAGS=-N --no-warn-rwx-segment
RM=rm -f $(EXE)

.PHONY: all clean debug

all: $(EXE)

clean:
	$(RM) *.o

$(EXE).o: $(EXE).s
	$(AS) $(ASFLAGS) $< -o $@

$(EXE): $(EXE).o
	$(LD) $(LDFLAGS) $< -o $@

debug: $(EXE)
	gdb ./$(EXE)
