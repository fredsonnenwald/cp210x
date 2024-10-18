cp210x driver with PPS support
=====

This project modifies the stock Linux kernel driver for the Silicon Labs
CP210X suite of devices to add support for modem control / status line
changes with particular attention to the Pulse Per Second (PPS) signal.

This was built and tested using Linux 6.6.51+rpt-rpi-2712 with the Adafruit
Ultimate GPS with USB-C (i.e., version 3) with the CP2012N USB to Serial Adapter.

# Driver will NOT make it into the Linux kernel

Unfortunately, the changes contained herein will NOT appear in the upstream
Linux kernel. The patch was rejected for two reasons:

1. This driver requires every character coming from the serial device be
   inspected for a special escape sequence. While necessary for the GPS
   receiver, it is unnecessary for the majority of devices. As such, it was
   regarded as undesirable behavior.

2. The timing precision provided by this device was regarded as inferior when
   compared to traditional serial devices. Traditional serial PPS devices yield
   timing precision of ~5-10 nanoseconds relevant to UTC. Because this device
   connects as a full-speed (USB 1.1) device, its timing precision is limited
   to 1 millisecond. If it could be made to operate as a high-speed (USB 2.0)
   device its timing precision would be 0.125 ms. Both were regarded as
   inferior compared with a true PPS device.

I would caution the user to keep these things in consideration before using
this driver.

# Summary of modifications

1. Backport the interfaces to the 5.15.0 kernel. You can revert this by
   skipping commit `4d9f958f6b44de604ffa81d09bcfa851aef92f56`.
2. Add support for `TIOCMIWAIT` and modem status `EMBED_EVENTS`
3. Add support for the Adafruit GPS with USB-C's PPS signal on the RI line.
4. Update for Raspberry Pi OS 6.6.51 kernel, add kernel message notification of PPS support,
   and add `make install`.

# Building, testing, and installing

The following instructions were written for [Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/)
Lite 12 (Bookworm) on a Raspberry Pi 5.
Your operating system may require different installation steps.

1. Blacklist the stock driver in the Linux Kernel by adding `blacklist cp210x`
to the end of the `/etc/modprobe.d/blacklist.conf` file. Then reboot your
computer.

```
$ tail /etc/modprobe.d/blacklist.conf
...
blacklist cp210x
```

2. Install dependencies

```
sudo apt install gpsd git
```

3. Clone and build this repository

```
git clone https://github.com/fredsonnenwald/cp210x
cd cp210x
make
sudo insmod ./cp210x.ko
```

4. Test that the driver works.

Plug in your device and run

```
gpsmon
```

You should see GPS + PPS signals on the console.
PPS signals may take a minutes or two to appear if the GPS module does not yet have a good fix.
A good fix is indicated by `gpsmon` reporting "Quality: 2".

If you have more than one GPS device explicitly specify the correct device by running, e.g., `gpsmon /dev/ttyUSB0`.

5. Install the driver

```
sudo make install
```

Note that you'll need to repeat this step every time the kernel is updated.

6. Undo the blacklist in step 1 to use the new driver.
