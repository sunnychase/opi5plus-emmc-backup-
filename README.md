# Orange Pi 5 Plus — eMMC /boot Backup & Restore

This repository documents how to back up and restore the **eMMC /boot** partition on the Orange Pi 5 Plus when using a **hybrid boot setup**:

- **eMMC**: stores U-Boot + `/boot` (kernel, initrd, extlinux.conf)
- **USB-C NVMe SSD**: holds the root filesystem (`/`)

Maintaining a reliable backup of eMMC `/boot` ensures that you can quickly recover if the bootloader, kernel, or extlinux configuration becomes corrupted.

---

## 🎯 Why Back Up?
- Avoid re-doing the hybrid boot process from scratch  
- Restore quickly if an `apt upgrade` or misconfigured `extlinux.conf` breaks boot  
- Keep versioned archives (e.g., after each kernel upgrade)  

---

## 📦 Backup Procedure

1. **Mount the eMMC /boot partition**
   ```bash
   sudo mkdir -p /mnt/emmcb
   sudo mount /dev/mmcblk0p1 /mnt/emmcb```

2. **Verify contents**

   ```bash
   ls /mnt/emmcb
   # Expect: vmlinuz-*, initrd.img-*, extlinux/, lib/, System.map-*, etc.
   ```

3. **Create a compressed backup archive**

   ```bash
   sudo tar -C /mnt -czf ~/emmcb_boot_backup_$(date +%F_%H%M%S).tar.gz emmcb
   ```

4. **Confirm the backup file**

   ```bash
   ls -lh ~/emmcb_boot_backup_*.tar.gz
   # Example: 91M  emmcb_boot_backup_2025-08-23_180036.tar.gz
   ```

---

## 🔍 Verify the Backup

To inspect the contents without extracting:

```bash
tar -tzf ~/emmcb_boot_backup_2025-08-23_180036.tar.gz | head
```

---

## ♻️ Restore Procedure

1. **Re-mount the eMMC partition**

   ```bash
   sudo mkdir -p /mnt/emmcb
   sudo mount /dev/mmcblk0p1 /mnt/emmcb
   ```

2. **Restore from your archive**

   ```bash
   sudo tar -C /mnt -xzf ~/emmcb_boot_backup_2025-08-23_180036.tar.gz
   sudo sync
   ```

3. **Verify restored files**

   ```bash
   ls /mnt/emmcb
   ```

---

## ⚡ Pro Tips

* Keep multiple versions of backups, especially after **kernel upgrades**.
* Pair this with [`sync_emmc_boot.sh`](../sync_emmc_boot.sh) to automatically sync `/boot` after kernel updates.
* Store archives in GitHub or external media for redundancy.
* Check `extlinux.conf` inside the backup archive if troubleshooting boot issues.

---

## 📂 Example Backup Artifact

* `emmcb_boot_backup_2025-08-23_180036.tar.gz` — 91 MB
  Created on **Aug 23, 2025** after successful hybrid boot.

---

## 📜 License

All Rights Reserved 2025, Sunny Chase
