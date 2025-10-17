CROSS_COMPILE 	:= riscv64-linux-gnu-
COMMON_CFLAGS 	:= -fno-pic -march=rv64g -mcmodel=medany -mstrict-align
CFLAGS 			+= $(COMMON_CFLAGS) -static
ASFLAGS			+= $(COMMON_CFLAGS) -O0
LDFLAGS			+= -melf64lriscv

COMMON_CFLAGS += -march=rv32im_zicsr -mabi=ilp32   # overwrite
LDFLAGS       += -melf32lriscv                     # overwrite
