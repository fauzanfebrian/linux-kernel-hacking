#!/bin/bash

# Original logic by: cusdeb_com (https://github.com/tutorin-tech/)
# Curated by: Fauzan (https://github.com/fauzanfebrian/)
# Based on the "Operating System Camp" material

# Configuration
IMG_NAME="fs.img"
MOUNT_POINT="/mnt/linux-kernel-hacking"
# You can change 'trixie' to 'noble' if you specifically want an Ubuntu inside the VM.
DISTRO_CODENAME="trixie"
REPO_URL="https://ftp.debian.org/debian"

echo "[+] Starting Root Filesystem Setup for Linux Mint/Ubuntu..."

echo "[+] Creating 500MB sparse file ${IMG_NAME}..."
dd if=/dev/zero of=${IMG_NAME} bs=1024 seek=$(( 500 * 1024 )) count=1

echo "[+] Formatting ${IMG_NAME} as ext4..."
/sbin/mkfs.ext4 ${IMG_NAME}

echo "[+] Mounting image to ${MOUNT_POINT} (requires sudo)..."
sudo mkdir -p ${MOUNT_POINT}
sudo mount -o loop ${IMG_NAME} ${MOUNT_POINT}

if ! command -v debootstrap &> /dev/null; then
    echo "[+] 'debootstrap' not found. Installing it..."
    sudo apt update
    sudo apt install -y debootstrap
fi

echo "[+] Bootstrapping ${DISTRO_CODENAME} into ${MOUNT_POINT}..."
sudo debootstrap ${DISTRO_CODENAME} ${MOUNT_POINT} ${REPO_URL}

echo "[+] Unmounting..."
sudo umount ${MOUNT_POINT}
sudo rm -rf ${MOUNT_POINT}

echo "[SUCCESS] Filesystem image ${IMG_NAME} is ready."