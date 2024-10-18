obj-m = cp210x.o
ko = cp210x.ko
KDIR = /lib/modules/`uname -r`/build
INSTALLDIR = /lib/modules/`uname -r`/kernel/drivers/usb/serial/
SRCDIR = $(PWD)
# try this instead if you don't have PWD defined
# SRCDIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
all:
	$(MAKE) -C $(KDIR) M=$(SRCDIR) modules
install:
	xz -k -f $(ko)
	cp $(ko).xz $(INSTALLDIR)
clean:
	$(MAKE) -C $(KDIR) M=$(SRCDIR) clean
