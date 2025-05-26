#!/usr/bin/env bash
set -euo pipefail

DRIVER="rtl8821cu"
VERSION="20210916"
REPO="https://github.com/morrownr/8821cu-20210916.git"
BRANCH="main"

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y git build-essential dkms linux-headers-$(uname -r)

echo "==> Removing old versions (apt/dkms) if any..."
sudo dkms remove -m rtl8821cu -v 1.0.0 --all 2>/dev/null || true
sudo dkms remove -m rtl8821cu -v "${VERSION}" --all 2>/dev/null || true
sudo apt purge -y rtl8812au-dkms 2>/dev/null || true

echo "==> Cloning driver ${DRIVER} ${VERSION}..."
cd /usr/src
sudo rm -rf "${DRIVER}-${VERSION}"
sudo git clone --depth 1 --branch "${BRANCH}" "${REPO}" "${DRIVER}-${VERSION}"

echo "==> Registering with DKMS..."
cd "${DRIVER}-${VERSION}"
sudo dkms add -m "${DRIVER}" -v "${VERSION}"

echo "==> Building and installing with DKMS..."
sudo dkms build -m "${DRIVER}" -v "${VERSION}"
sudo dkms install -m "${DRIVER}" -v "${VERSION}"

echo "==> Blacklisting the generic rtl8xxxu module..."
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-rtl8xxxu.conf
blacklist rtl8xxxu
EOF

echo "==> Updating initramfs..."
sudo update-initramfs -u

echo "==> Removing old modules and loading the new one..."
sudo modprobe -r rtl8xxxu 2>/dev/null || true
sudo modprobe 8821cu

echo "==> Unblocking wireless radio (rfkill)..."
sudo rfkill unblock all

echo "==> Waiting 2 seconds for the kernel to match the device..."
sleep 2

echo "==> Realtek USB devices 0bda:c811 in use:"
lsusb | grep -i 0bda:c811

echo
echo "==> Detected network interfaces:"
ip link show | sed -n '/^[0-9]\+:/p'

echo
echo "✅ Done! If the new interface (usually something like wlan1) does not appear, reboot the system or run manually:"
echo "   sudo modprobe 8821cu"
