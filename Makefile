export pkgs          := zlib libiconv ncurses readline lua sqlite db file nss-nspr popt rpm
export PRJROOT        = $(CURDIR)/project
export IMAGES        := $(PRJROOT)/images
export CACHE         := $(PRJROOT)/cache
export INSTALL_SODIR  = lib

export ARCH          := arm
export TARGET        := arm-linux-gnueabihf
export CROSS_COMPILE := $(TARGET)-

export CROSS_COMPILE_INCLUDE_PATH         := $(PRJROOT)/include
export CROSS_COMPILE_DYNAMIC_LIBRARY_PATH := $(IMAGES)/$(INSTALL_SODIR)
export CROSS_COMPILE_STATIC_LIBRARY_PATH  := $(PRJROOT)/lib

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

