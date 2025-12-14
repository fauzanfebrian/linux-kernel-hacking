# Kernel Configuration
KERNEL_VER := 6.17.7
KERNEL_DIR := linux-$(KERNEL_VER)
ARCH       ?= um

# Color codes for the help output
BLUE := \033[36m
RESET := \033[0m

.PHONY: help build menuconfig gdb run syncmodules setup

help: ## Show help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-20s$(RESET) %s\n", $$1, $$2}'

setup: ## Run setup scripts to fetch kernel and build FS
	KERNEL_VER=$(KERNEL_VER) bash ./scripts/setup_env.sh
	KERNEL_VER=$(KERNEL_VER) bash ./scripts/build_fs.sh

menuconfig: ## Configure kernel options (ncurses)
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) menuconfig

build: ## Compile the kernel with -j4
	$(MAKE) -C ./$(KERNEL_DIR) ARCH=$(ARCH) -j4

run: ## Boot User-Mode Linux with fs.img
	./$(KERNEL_DIR)/linux ubd0=./fs.img root=/dev/ubda rw init=/bin/dash || true; \
	stty sane

gdb: ## Attach GDB to the kernel binary
	gdb ./$(KERNEL_DIR)/linux -x gdb_cmd

syncmodules: ## Link local modules to kernel source tree
	ln -f ./modules/* ./$(KERNEL_DIR)/drivers/misc/