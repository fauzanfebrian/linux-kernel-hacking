# Kernel Configuration
KERNEL_VER 		:= 6.17.7
KERNEL_DIR 		:= linux-$(KERNEL_VER)
ARCH       		?= um
KERNEL_BUILD_DIR 	:= $(shell pwd)/build

# Color codes for the help output
BLUE := \033[36m
RESET := \033[0m

.PHONY: help build menuconfig gdb run syncmodules setup

help: ## Show help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-20s$(RESET) %s\n", $$1, $$2}'

setup: ## Run setup scripts to fetch kernel and build FS
	KERNEL_VER=$(KERNEL_VER) bash ./scripts/setup_env.sh
	KERNEL_VER=$(KERNEL_VER) bash ./scripts/setup_fs.sh
	KERNEL_VER=$(KERNEL_VER) bash ./scripts/setup_minix_fs.sh

menuconfig: ## Configure kernel options (ncurses)
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) KCONFIG_CONFIG=$(KERNEL_BUILD_DIR)/.config menuconfig

build: ## Compile the kernel with -j4
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) O=$(KERNEL_BUILD_DIR) -j4

mrproper: ## Clean up kernel building
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) O=$(KERNEL_BUILD_DIR) KCONFIG_CONFIG=$(KERNEL_BUILD_DIR)/.config mrproper

scripts_gdb: ## Clean up kernel building
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) O=$(KERNEL_BUILD_DIR) KCONFIG_CONFIG=$(KERNEL_BUILD_DIR)/.config scripts_gdb

run: ## Boot User-Mode Linux with fs.img
	$(KERNEL_BUILD_DIR)/linux ubd0=fs.img ubd1=minix.img root=/dev/ubda rw init=/bin/sh || true; \
	stty sane

gdb: ## Attach GDB to the kernel binary
	gdb $(KERNEL_BUILD_DIR)/linux -x gdb_cmd

syncmodules: ## Link local modules to kernel source tree
	ln -f ./modules/* ./$(KERNEL_DIR)/drivers/misc/