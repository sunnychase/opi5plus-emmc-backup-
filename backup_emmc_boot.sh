#!/bin/bash
# backup_emmc_boot.sh
# Create a compressed backup of the eMMC /boot partition on Orange Pi 5 Plus

set -e

BACKUP_DIR="$HOME"
TIMESTAMP=$(date +%F_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/emmcb_boot_backup_${TIMESTAMP}.tar.gz"

echo "[*] Mounting eMMC /boot partition..."
sudo mkdir -p /mnt/emmcb
sudo mount /dev/mmcblk0p1 /mnt/emmcb

echo "[*] Creating backup archive at $BACKUP_FILE ..."
sudo tar -C /mnt -czf "$BACKUP_FILE" emmcb

echo "[*] Backup complete:"
ls -lh "$BACKUP_FILE"
