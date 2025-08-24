#!/bin/bash
# restore_emmc_boot.sh
# Restore the eMMC /boot partition backup on Orange Pi 5 Plus

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file $BACKUP_FILE not found."
  exit 1
fi

echo "[*] Mounting eMMC /boot partition..."
sudo mkdir -p /mnt/emmcb
sudo mount /dev/mmcblk0p1 /mnt/emmcb

echo "[*] Restoring backup from $BACKUP_FILE ..."
sudo tar -C /mnt -xzf "$BACKUP_FILE"

echo "[*] Syncing data to disk..."
sync

echo "[*] Restore complete. Contents of /mnt/emmcb:"
ls -lh /mnt/emmcb
