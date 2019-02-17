export pkgs := busybox zlib libiconv ncurses readline lua sqlite db file nss-nspr popt rpm
export PRJROOT ?= $(shell pwd)/project
export IMAGES  ?= $(PRJROOT)/images
export INSTALL_SODIR ?= lib
export ARCH     = arm
export CROSS    = arm-linux-gnueabi
export CFLAGS   = -I$(IMAGES)/header
export CPPFLAGS = $(CFLAGS)
export LDFLAGS  = -L$(IMAGES)/rootfs/$(INSTALL_SODIR) -L$(IMAGES)/lib
export CACHE    = $(PRJROOT)/cache

all:
	for pkg in $(pkgs); do \
		$(MAKE) -C $${pkg}; \
	done

.PHONY: $(pkgs)
$(pkgs):
	$(MAKE) -C $@
clean:
	for pkg in $(pkgs); do \
		$(MAKE) -C $${pkg} clean; \
	done

