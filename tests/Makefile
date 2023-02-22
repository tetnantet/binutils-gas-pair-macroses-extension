TARGET_EXEC := macro-tests
SRCS := macro-tests.s

AS := ../binutils-usr/bin/as
LD := ../binutils-usr/bin/ld

# -a[cdghlmns]
#     Turn on listings, in any of a variety of ways:
#     -ac omit false conditionals
#     -ad omit debugging directives
#     -ag include general information, like as version and options passed
#     -ah include high-level source
#     -al include assembly
#     -am include macro expansions
#     -an omit forms processing
#     -as include symbols
ASLISTINGOPTS := lmncd

ASFLAGS :=
LDFLAGS :=

OBJS := $(SRCS:.s=.o)
LSTS := $(SRCS:.s=.lst)

all: $(TARGET_EXEC)

$(TARGET_EXEC): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

%.o: %.s
	$(AS) -a$(ASLISTINGOPTS)=$(<:.s=.lst) -o $@ $<

.PHONY: clean

clean:
	rm -f $(OBJS)
	rm -f $(LSTS)
	rm -f $(TARGET_EXEC)
