# LXB - LinuX Builder

This is a framework to build debian (ubuntu) LXC containers from scratch.

## Applications

* Guest containers - in place of linux VMs or entire systems
* Host container - read more on the containervisor (cvisor) below
* Installers - use a live installer to quickly bootstrap a system by copying an existing system

# Embedded, live containers

While LXC is used to build the live system, it is not necessary in order to run it. The output is a fully functioning system.

The rootfs of the container can be exported and embedded as follows:

* The system is squashed and compressed using squashfs with gzip.
* The squashfs image is embedded into an initramfs
* The initramfs uses debian live-boot with a small patch to load the squashfs image, and mount an overlay on top of it
* A fully functioning read-write system with optional persistence can then be booted

As only a kernel and the initramfs are required, this is extremely portable:

* syslinux / isolinux may be used to easily create a livecd / iso / USB
* A simple PXE config can be used for network booting

The following kernel arguments are required in order to successfully boot:

```
boot=live root=/dev/ram0 live-media=initramfs
```

* boot=live - this triggers the necessary [live-boot](http://live.debian.net/manpages/stable/en/html/live-boot.7.html) initramfs scripts
* root=/dev/ram0 - this tricks the kernel into using it's own initramfs as the root filesystem, so it won't panic
* live-media=initramfs - this tells live-boot to look at it's own initramfs to find the embedded squashfs image

So long as a bootloader can supply the above kernel arguments, and can load the kernel and initramfs, the cvisor can be booted.

# Container supervisor

Optionally, a container can be transformed into a 'container-supervisor' or 'cvisor', running directly on the host.

The cvisor image contains [lxd](http://www.ubuntu.com/cloud/tools/lxd) to manage lxc images.

This provides a shim to run other LXC containers, potentially performing more complex or specialized tasks.

Thus, a generic host can take on other more specialized roles with relative ease - with no need to reboot, re-image, or reinstall.

More on this later (lxd work in progress)

# Building containers

Building containers is quite simple with few requirements:

* A linux system with a modern kernel
* lxc, squashfs-tools
* optional (cdrom / iso support): syslinux, mkisofs

A named config file describes a few variables that tells the framework how to build.

To build cvisor:

```
./build.sh -n cvisor
```

This will result in a squashfs image, and a kernel/initramfs pair suitable for booting

You can optionally run any of the build steps with the ```-i``` flag. To package the system up into an ISO:

```
./build -n cvisor -i iso
```

For additional help:

```
./build -h
```

# Resources

* https://help.ubuntu.com/lts/serverguide/lxc.html
* https://help.ubuntu.com/community/LiveCDCustomizationFromScratch#The_ChRoot_Environment
* http://askubuntu.com/a/306887
* https://wiki.ubuntu.com/Initramfs
* https://l3net.wordpress.com/2013/11/03/debian-virtualization-lxc-debootstrap-filesystem/
