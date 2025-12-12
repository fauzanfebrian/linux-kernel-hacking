# Linux Kernel Hacking: From First Principles

Personal repo for exploring the Linux kernel through User-Mode Linux (UML). Focus: Kernel internals, module development, and debugging techniques.

All code and notes here are based on the "Operating System Camp" material by CusDeb / Tutorin Tech.

## 🧠 Focus Areas

- **Kernel Architecture**: Understanding the Linux kernel structure and subsystems
- **User-Mode Linux**: Running and debugging the kernel as a userspace process
- **Module Development**: Writing and loading kernel modules
- **Kernel Debugging**: Using GDB to step through kernel code
- **Build System**: Kernel compilation and configuration (Kconfig, Makefiles)
- **Filesystem**: Root filesystem creation and management
- **System Calls**: Tracing and understanding kernel-user space interactions

## 🛠️ Why this Repo Exists

This is the execution log for the "Operating System Camp" phase of my engineering journey. Used for:

- Removing the "black box" magic from kernel-level programming
- Hands-on experience with kernel source code and debugging
- Understanding system internals beyond high-level abstractions
- Documentation of kernel concepts and debugging workflows

## 📚 Resources (The Learning Loop)

Since I am following the Operating System Camp curriculum, I follow this loop:

1. **Setup**: Run `./scripts/setup_env.sh` to fetch kernel 6.17.7 and prepare the environment
2. **Build**: Compile the kernel with `make ARCH=um -j4` in `linux-6.17.7/`
3. **Debug**: Use GDB with `gdb ./linux -x ../gdb_cmd` to step through kernel code
4. **Experiment**: Modify kernel code, write modules, and observe behavior changes

## 🚀 Quick Setup

**Prerequisites:** A Debian-based Linux host (Ubuntu, Mint, etc.) and `sudo` access.

```bash
# 1. Setup environment (downloads kernel 6.17.7)
./scripts/setup_env.sh

# 2. Create filesystem image (Debian Trixie, requires sudo)
./scripts/setup_fs.sh

# 3. (optional) Configure kernel via top-level helper
make menuconfig

# 4. Build kernel
make build

# 5. Run UML kernel
make run

# 6. Debug with GDB
make gdb

# 7. Synchronize modules linkage
make syncmodules
```

---

**Based on:** [CusDeb Operating System Camp](https://instagram.com/cusdeb_com)
