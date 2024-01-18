#!/bin/bash
AOSP_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/git/AOSP
BRANCH=main-kernel-build-2023
[ -e build-tools ] || git clone $AOSP_MIRROR/platform/prebuilts/build-tools -b $BRANCH --depth 1 build-tools
[ -e kernel-build-tools ] || git clone $AOSP_MIRROR/kernel/prebuilts/build-tools -b $BRANCH --depth 1 kernel-build-tools

UNPACK_BOOTIMG=tools/mkbootimg/unpack_bootimg.py
MKBOOTIMG=tools/mkbootimg/mkbootimg.py
AVBTOOL=kernel-build-tools/linux-x86/bin/avbtool
GZIP=build-tools/path/linux-x86/gzip
PATCH_LEVEL="2023-11"



	BUILD_CONFIG=common/build.config.gki.aarch64 build/build.sh

	#echo '[+] Download prebuilt ramdisk'
    #GKI_URL=https://dl.google.com/android/gki/gki-certified-boot-android12-5.10-"${PATCH_LEVEL}"_r1.zip
    #FALLBACK_URL=https://dl.google.com/android/gki/gki-certified-boot-android12-5.10-2023-01_r1.zip
    #status=$(curl -sL -w "%{http_code}" "$GKI_URL" -o /dev/null)
    #if [ "$status" = "200" ]; then
    #    curl -Lo gki-kernel.zip "$GKI_URL"
    #else
    #    echo "[+] $GKI_URL not found, using $FALLBACK_URL"
    #    curl -Lo gki-kernel.zip "$FALLBACK_URL"
    #fi
	#unzip gki-kernel.zip && rm gki-kernel.zip

	echo '[+] Unpack prebuilt boot.img'
	BOOT_IMG=boot-5.10.img
	$UNPACK_BOOTIMG --boot_img="$BOOT_IMG"
	#rm "$BOOT_IMG"

	echo '[+] Building Image.gz'
	$GZIP -n -k -f -9 out/android12-5.10/dist/Image -c > Image.gz

	#echo '[+] Building boot.img'
	#$MKBOOTIMG --header_version 4 --kernel Image --output boot.img --ramdisk out/ramdisk --os_version 12.0.0 --os_patch_level "${PATCH_LEVEL}"
	#$AVBTOOL add_hash_footer --partition_name boot --partition_size $((64 * 1024 * 1024)) --image boot.img --algorithm SHA256_RSA2048 --key ../kernel-build-tools/linux-x86/share/avb/testkey_rsa2048.pem

	echo '[+] Building boot-gz.img'
	$MKBOOTIMG --header_version 4 --kernel Image.gz --output boot-gz.img --ramdisk out/ramdisk --os_version 12.0.0 --os_patch_level "${PATCH_LEVEL}"
	$AVBTOOL add_hash_footer --partition_name boot --partition_size $((64 * 1024 * 1024)) --image boot-gz.img --algorithm SHA256_RSA2048 --key kernel-build-tools/linux-x86/share/avb/testkey_rsa2048.pem

	#echo '[+] Building boot-lz4.img'
	#$MKBOOTIMG --header_version 4 --kernel Image.lz4 --output boot-lz4.img --ramdisk out/ramdisk --os_version 12.0.0 --os_patch_level "${PATCH_LEVEL}"
	#$AVBTOOL add_hash_footer --partition_name boot --partition_size $((64 * 1024 * 1024)) --image boot-lz4.img --algorithm SHA256_RSA2048 --key ../kernel-build-tools/linux-x86/share/avb/testkey_rsa2048.pem

	



