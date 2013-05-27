#!/sbin/sh

PATH=$PATH:/sbin


# For sdcard boot only, check if this is the new sdcard install
# and if so, create partitions and such
mount /dev/block/mmcblk1p1 /boot -t vfat
if [ -f /boot/MLO -a -f /boot/u-boot.bin -a ! -e /dev/block/mmcblk1p2 ] ; then

      umount /boot

      # New layout: boot, 800M /system, and the rest goes to /data
      echo -e "n\np\n2\n\n+800M\nn\np\n3\n\n\nw\n" | fdisk /dev/block/mmcblk1 >/dev/null

      mke2fs -T ext4 /dev/block/mmcblk1p3

      mount /dev/block/mmcblk1p3 /data
      mkdir /data/media
      chmod 775 /data/media
      umount /data
else
   umount /boot
fi

# Resets the boot counter and the BCB instructions
mkdir /bootdata
mount /dev/block/mmcblk0p6 /bootdata
mount -o rw,remount /bootdata

# Zero out the boot counter
dd if=/dev/zero of=/bootdata/BootCnt bs=1 count=4

# Reset the bootloader control block (bcb) file
dd if=/dev/zero of=/bootdata/BCB bs=1 count=1088

umount /bootdata
rmdir /bootdata

# Create fake emmc symlink
mkdir /int-data
mount /dev/block/platform/omap/omap_hsmmc.1/by-name/userdata /int-data
rmdir /emmc
ln -sf /int-data/media /emmc
