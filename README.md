# RTL8821CU Driver Installation Script

This script automates the installation of the Realtek RTL8821CU Wi-Fi driver for USB adapters, such as the WD-4501AC, on Linux systems. It uses the `morrownr/8821cu-20210916` driver, which supports both 2.4GHz and 5GHz Wi-Fi networks. The script is designed for Ubuntu-based distributions but may work on other Linux systems with compatible kernels.

## Features

- Installs dependencies (`git`, `build-essential`, `dkms`, `linux-headers`).
- Clones and builds the `morrownr/8821cu-20210916` driver using DKMS.
- Blacklists the conflicting `rtl8xxxu` module.
- Provides diagnostic output for USB devices and network interfaces.
- Supports Realtek RTL8821CU-based adapters (USB ID: `0bda:c811`).

## Compatibility

- **Chipset**: Realtek RTL8821CU (e.g., WD-4501AC USB Wi-Fi adapter).
- **USB ID**: `0bda:c811`.
- **Operating System**: Ubuntu 20.04 LTS or later (tested on kernel 5.15.0-139-generic).
- **Kernel**: 5.4 or later (DKMS ensures compatibility with kernel updates).
- **Wi-Fi Bands**: Supports both 2.4GHz and 5GHz networks.

## Prerequisites

- A Linux system with `sudo` privileges.
- Internet connection for downloading dependencies and the driver.
- The target USB Wi-Fi adapter connected (verify with `lsusb | grep 0bda:c811`).

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/gustavoguarda/rtl8821cu-driver-install.git
   cd rtl8821cu-driver-install
   ```
2. Make the script executable:
   ```bash
   chmod +x scripts/install_rtl8821cu.sh
   ```
3. Run the script with `sudo`:
   ```bash
   sudo ./scripts/install_rtl8821cu.sh
   ```

## Usage

- The script performs the following steps:
  1. Installs required dependencies.
  2. Removes old versions of the driver (if any).
  3. Clones the `morrownr/8821cu-20210916` driver.
  4. Builds and installs the driver using DKMS.
  5. Blacklists the conflicting `rtl8xxxu` module.
  6. Loads the `8821cu` module and unblocks the radio (via `rfkill`).
  7. Displays detected USB devices and network interfaces.
- After running, check for the new interface (e.g., `wlx90de80b88729`):
  ```bash
  ip link show
  iwconfig
  ```
- Connect to a Wi-Fi network:
  ```bash
  nmcli device wifi connect "Your_SSID" password "Your_Password" ifname wlx90de80b88729
  ```
  Replace `Your_SSID` and `Your_Password` with your network details.

## Troubleshooting

- **No new interface detected**:
  - Verify the USB device: `lsusb | grep 0bda:c811`.
  - Check if the module is loaded: `lsmod | grep 8821cu`.
  - Manually load the module: `sudo modprobe 8821cu`.
  - Reboot: `sudo reboot`.
- **Cannot connect to 5GHz networks**:
  - Check supported frequencies: `iwlist wlx90de80b88729 frequency`.
  - Set regulatory domain: `sudo iw reg set BR; sudo iwconfig wlx90de80b88729 commit`.
  - Ensure router uses non-DFS channels (36, 40, 44, or 48) and WPA2-PSK (AES).
  - Scan for networks: `nmcli device wifi list ifname wlx90de80b88729`.
- **Secure Boot issues**:
  - If `dmesg` shows "module verification failed," disable Secure Boot in BIOS.
- **Logs for debugging**:
  ```bash
  dmesg | grep -i "rtl8821cu\|wlan"
  journalctl -xe | grep -i "network\|wlan"
  ```
- **Disable internal Wi-Fi**:
  - Temporarily: `sudo nmcli device disconnect wlp1s0`.
  - Permanently: Add `blacklist ath9k` to `/etc/modprobe.d/blacklist-ath9k.conf` and run `sudo update-initramfs -u`.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit issues or pull requests on GitHub.

## Acknowledgments

- [morrownr/8821cu-20210916](https://github.com/morrownr/8821cu-20210916) for the RTL8821CU driver.
- Ubuntu community forums for troubleshooting insights.
