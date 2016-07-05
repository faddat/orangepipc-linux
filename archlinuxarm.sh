#!/bin/bash
#Arch Linux ARM for Orange Pi PC


export PATH=$PATH:/home/faddat/projects/orangearches/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf/bin
export PROJECTROOT=$(pwd)
export BUILDTIME=$(date +%T)
mkdir boot


echo "[INFO] Creating u-boot"
if [ ! -d u-boot ]; then
        git clone git://github.com/u-boot/u-boot
elif [ -d u-boot ]; then
        cd u-boot 
        git pull
        cd ..
fi

cd u-boot 
CROSS_COMPILE=arm-linux-gnueabihf- make orangepi_pc_config 
CROSS_COMPILE=arm-linux-gnueabihf- make 
cp u-boot-sunxi-with-spl.bin ../boot/u-boot-sunxi-with-spl.bin
cd ..

echo "[INFO] Creating Boot zImage"
if [ ! -d linux ]; then
		git clone https://github.com/faddat/orangepipc-linux linux 
		cd linux 
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- 
        mkdir -p ../build/boot/boot/dtb 
        cp arch/arm/boot/dts/sun8i-h3-orangepi-pc.dtb ../boot/sun8i-h3-orangepi-pc.dtb 
        cp arch/arm/boot/zImage ../boot/zImage
        cd ..
elif [ -d u-boot ]; then
		cd linux 
		git pull https://github.com/faddat/orangepipc-linux 
		cp OPIPC_TEST_CONFIG .config 
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
		cp arch/arm/boot/dts/sun8i-h3-orangepi-pc.dtb ../boot/sun8i-h3-orangepi-pc.dtb 
        cp arch/arm/boot/zImage ../boot/zImage
        cd ..
fi

cd  $PWD
cp boot.cmd boot/boot.cmd
cd boot
ls
mkimage -C none -A arm -T script -d boot.cmd boot.scr 
cd $PWD

echo "[INFO] Allocating image space"
dd if=/dev/zero of=orangepiarch.img bs=1M count=2048
mkfs.ext4  orangepiarch.img
losetup orangepiarch.img /dev/loop0
sudo dd if=/dev/zero of=/dev/loop0 bs=1k count=1023 seek=1
sudo dd if=u-boot/u-boot-sunxi-with-spl.bin of=/dev/loop0 bs=1024 seek=8
sudo losetup -d /dev/loop0
sync
mount /dev/loop0 /mountee
sync

echo "[INFO] Copying rootfs"
if [ ! -f ArchLinuxARM-armv7-latest.tar.gz ]; then
        wget http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz
fi
sudo bsdtar -C /mountee -xzf ArchLinuxARM-armv7-latest.tar.gz
sync
sudo cp boot/* /mountee/boot


echo "[INFO] Creating /proc, /sys, /mnt, /tmp & /boot"
sudo mkdir -p /mountee/proc
sudo mkdir -p /mountee/sys
sudo mkdir -p /mountee/mnt
sudo mkdir -p /mountee/tmp
sudo mkdir -p /mountee/boot
sync

umount /mountee
