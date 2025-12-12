# Simple wrapper Makefile to run kernel menuconfig inside linux-6.17.7
KERNEL_DIR := linux-6.17.7
ARCH      ?= um

.PHONY: build menuconfig gdb run syncmodules

menuconfig:
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) menuconfig

build:
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) -j4

run:
	./$(KERNEL_DIR)/linux ubd0=./fs.img root=/dev/ubda rw init=/bin/dash || true; \
	stty sane

gdb:
	gdb ./$(KERNEL_DIR)/linux -x gdb_cmd

syncmodules:
	ln -f ./modules/* ./linux-6.17.7/drivers/misc/