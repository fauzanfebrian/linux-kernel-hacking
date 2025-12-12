#!/bin/bash

# Original logic by: cusdeb_com (https://github.com/tutorin-tech/)
# Curated by: Fauzan (https://github.com/fauzanfebrian/)
# Based on the "Operating System Camp" material

# Configuration
KERNEL_VER="6.17.7"
KERNEL_TAR="linux-${KERNEL_VER}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_TAR}"
DIR_NAME="linux-${KERNEL_VER}"

echo "[+] Updating package lists..."
sudo apt update

echo "[+] Installing build dependencies (bc, bison, flex, gcc, libncurses, etc)..."
sudo apt install -y bc bison flex gcc libncurses-dev make wget xz-utils build-essential

echo "---------------------------------------------------"

if [ -d "$DIR_NAME" ]; then
    echo "[!] Directory $DIR_NAME already exists. Skipping download."
    exit 0
fi

echo "[+] Downloading Linux Kernel ${KERNEL_VER}..."
wget ${KERNEL_URL}

echo "[+] Extracting tarball (this may take a moment)..."
tar xJvf ${KERNEL_TAR}
rm -f ${KERNEL_TAR}

echo "[+] Linkage configs..."
ln -f "${PWD}/configs/.config" "${DIR_NAME}/.config"

echo "[SUCCESS] Kernel source extracted to ${DIR_NAME}/"