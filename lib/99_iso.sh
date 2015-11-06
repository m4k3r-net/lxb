generate_iso()
{

  # Ensure we have the packages we need
#  apt-get install syslinux-common mkisofs -y

  # Prepare a temparary directory
  WORK_DIR=$(mktemp -d)

  # Copy kernel and initramfs
  mkdir -p $WORK_DIR/boot/
  cp $CONTAINER_OUTPUT/boot/initrd* $WORK_DIR/boot/initrd
  cp $CONTAINER_OUTPUT/boot/vmlinuz* $WORK_DIR/boot/vmlinuz

  # Prepare the bootloader
  mkdir -p $WORK_DIR/boot/isolinux

cat > $WORK_DIR/boot/isolinux/isolinux.cfg <<EOF
DEFAULT cvisor
LABEL cvisor
      MENU LABEL CVisor
      LINUX /boot/vmlinuz
      INITRD /boot/initrd
      APPEND console=ttyS1,115200 console=tty0 boot=live root=/dev/ram0 live-media=initramfs
EOF

  cp /usr/lib/syslinux/isolinux.bin $WORK_DIR/boot/isolinux/

  # Build the iso
  old_dir=$(pwd)
  cd $WORK_DIR
  mkisofs -o $CONTAINER_OUTPUT/image.iso -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table .

  # Clean up
  cd $old_dir
  rm -rf $WORK_DIR
}
