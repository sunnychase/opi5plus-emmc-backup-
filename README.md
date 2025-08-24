# Orange Pi 5 Plus — Hybrid Boot with eMMC + USB-C NVMe

This project documents setting up a **hybrid boot system** on the Orange Pi 5 Plus:

- **eMMC** → holds U-Boot + `/boot` (kernel, initrd, extlinux.conf)
- **USB-C NVMe SSD** → holds the root filesystem (`/`)

It also includes scripts and steps for backing up and restoring the **eMMC /boot** partition so you can quickly recover if something breaks.

---

## 🚀 Hybrid Boot Setup (Recap)

- Flashed U-Boot SPL + FIT to eMMC at:
  - SPL → sector 64 (32 KiB)
  - FIT → sector 16384 (8 MiB)
- Synced `/boot` files from SSD → eMMC
- Configured `extlinux.conf` on eMMC to point `root=` to the SSD UUID
- Verified boot worked with microSD removed:

  ```bash
  mount | grep " / "
  cat /proc/cmdline | tr ' ' '\n' | grep ^root=
   ```

---

## 📦 Backup Workflow

### 1. Mount eMMC /boot

```bash
sudo mkdir -p /mnt/emmcb
sudo mount /dev/mmcblk0p1 /mnt/emmcb
```

### 2. Create a timestamped backup archive

```bash
sudo tar -C /mnt -czf ~/emmcb_boot_backup_$(date +%F_%H%M%S).tar.gz emmcb
```

Example result:

```
-rw-r--r-- 1 root root 91M Aug 23 18:00 emmcb_boot_backup_2025-08-23_180036.tar.gz
```

---

## 🔍 Verify the Backup

### List the first few files in the archive

```bash
tar -tzf ~/emmcb_boot_backup_2025-08-23_180036.tar.gz | head
```

Example:

```
emmcb/
emmcb/extlinux/extlinux.conf
emmcb/boot/vmlinuz-6.1.0-1025-rockchip
emmcb/boot/initrd.img-6.1.0-1025-rockchip
```

### Dry-run restore (no overwrite, safe)

```bash
mkdir ~/restore_test
tar -xzf ~/emmcb_boot_backup_2025-08-23_180036.tar.gz -C ~/restore_test
ls ~/restore_test/emmcb
```

You should see the same structure as your live eMMC `/boot`.

---

## ♻️ Restore Procedure

If `/boot` gets corrupted or wiped:

1. Mount the eMMC partition:

   ```bash
   sudo mkdir -p /mnt/emmcb
   sudo mount /dev/mmcblk0p1 /mnt/emmcb
   ```

2. Restore from the archive:

   ```bash
   sudo tar -C /mnt -xzf ~/emmcb_boot_backup_2025-08-23_180036.tar.gz
   sudo sync
   ```

3. Verify:

   ```bash
   ls /mnt/emmcb
   ```

---

## 📜 Scripts

### 🔹 `backup_emmc_boot.sh`

```bash
#!/bin/bash
# Create a compressed backup of the eMMC /boot partition

set -e
BACKUP_DIR="$HOME"
TIMESTAMP=$(date +%F_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/emmcb_boot_backup_${TIMESTAMP}.tar.gz"

echo "[*] Mounting eMMC /boot..."
sudo mkdir -p /mnt/emmcb
sudo mount /dev/mmcblk0p1 /mnt/emmcb

echo "[*] Creating backup at $BACKUP_FILE ..."
sudo tar -C /mnt -czf "$BACKUP_FILE" emmcb

echo "[*] Done:"
ls -lh "$BACKUP_FILE"
```

### 🔹 `restore_emmc_boot.sh`

```bash
#!/bin/bash
# Restore eMMC /boot from a backup archive

set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: file $BACKUP_FILE not found"
  exit 1
fi

echo "[*] Mounting eMMC /boot..."
sudo mkdir -p /mnt/emmcb
sudo mount /dev/mmcblk0p1 /mnt/emmcb

echo "[*] Restoring from $BACKUP_FILE ..."
sudo tar -C /mnt -xzf "$BACKUP_FILE"
sync

echo "[*] Restore complete."
ls -lh /mnt/emmcb
```

Make them executable:

```bash
chmod +x backup_emmc_boot.sh restore_emmc_boot.sh
```

---

## ⚡ Pro Tips

* Always re-run `backup_emmc_boot.sh` after a **kernel upgrade**.
* Keep backups in multiple locations (local, GitHub, external USB).
* Generate checksums to verify integrity:

  ```bash
  sha256sum emmcb_boot_backup_*.tar.gz > checksums.sha256
  sha256sum -c checksums.sha256
  ```

---

## 📂 Example Backup Artifacts

* `emmcb_boot_backup_2025-08-23_180036.tar.gz` — 91 MB archive of `/boot`

---

## 📜 License

All Rights Reserved 2025, Sunny Chase
