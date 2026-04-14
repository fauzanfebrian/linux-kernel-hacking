BPF_CLANG ?= clang
CC ?= clang

ARCH := $(shell uname -m | sed 's/x86_64/x86/;s/aarch64/arm64/')
INCLUDE_ARCH := $(shell uname -m)-linux-gnu

CFLAGS := -O2 -g -Wall
BPF_CFLAGS := -O2 -g -target bpf -D__TARGET_ARCH_$(ARCH) -I/usr/include/$(INCLUDE_ARCH)

all: hello

hello.bpf.o: hello.bpf.c
	$(BPF_CLANG) $(BPF_CFLAGS) -c $< -o $@

hello.skel.h: hello.bpf.o
	bpftool gen skeleton $< > $@

hello.o: hello.c hello.skel.h
	$(CC) $(CFLAGS) -c hello.c -o hello.o

hello: hello.o
	$(CC) hello.o -o hello -lbpf

clean:
	rm -f *.o *.skel.h hello

.PHONY: all clean