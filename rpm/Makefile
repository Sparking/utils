include ../macros.mk

IMAGES = $(PRJROOT)/images
KBUILD_OUTPUT = $(PRJROOT)/tmp/kernel-build

# 编译依赖的目录
pkg              := rpm
pwd              := $(shell pwd)
pkg_build_root   := $(pwd)/build
pkg_patches_root := $(pwd)/patches
pkg_storage_root := $(pwd)/packages
pkg_version      := 4.14.2.1
pkg_location     := $(pkg_storage_root)/rpm-$(pkg_version).tar.bz2
pkg_build_dir    := $(pkg_build_root)/rpm-$(pkg_version)
pkg_patches_dir  := $(pkg_patches_root)/rpm-$(pkg_version)

# 交叉编译工具链
CC := $(CROSS)-gcc
AR := $(CROSS)-ar
AS := $(CROSS)-as
LD := $(CROSS)-ld
STRIP := $(CROSS)-strip
RANLIB := $(CROSS)-ranlib

# 安装目录
header_location     := 
top_srcdir          := $(pwd)
install_root        := ${top_srcdir}/images
install_header_dir  := ${install_root}/include/$(header_location)
install_adir        := $(install_root)/lib
install_rootfs_dir  := $(install_root)/rootfs
install_sodir       := $(install_rootfs_dir)/$(INSTALL_SODIR)
install_usr_bin_dir := $(install_rootfs_dir)/usr/bin
install_usr_lib_dir := $(install_rootfs_dir)/usr/lib
install_sbin_dir    := $(install_rootfs_dir)/sbin
install_etc_dir     := $(install_rootfs_dir)/etc
INSTALL_MOD_PATH    := $(install_rootfs_dir)

# 临时安装目录
install_tmp_root    := $(pwd)/install
pkg_tmp_install_dir := $(install_tmp_root)/rpm-$(pkg_version)/usr

# 缓存目录
pkg_cache_root    := $(CACHE)/utils/$(pkg)
cache_header_dir  := $(pkg_cache_root)/include/$(header_location)
cache_adir        := $(pkg_cache_root)/lib
cache_rootfs_dir  := $(pkg_cache_root)/rootfs
cache_sodir       := $(cache_rootfs_dir)/$(INSTALL_SODIR)
cache_usr_bin_dir := $(cache_rootfs_dir)/usr/bin
cache_usr_lib_dir := $(cache_rootfs_dir)/usr/lib
cache_sbin_dir    := $(cache_rootfs_dir)/sbin
cache_etc_dir     := $(cache_rootfs_dir)/etc
cache_mod_path    := $(cache_rootfs_dir)

# 编译标记
pkg_build_flag := $(CACHE)/utils/.complete_$(pkg)
pkg_check_flag := $(pwd)/.complete_$(pkg)

# 组件的编译选项
pkg_spec_cflags  := $(CFLAGS) -I$(PRJROOT)/images/header/nss
pkg_spec_ldflags := -Wl,--as-needed $(LDFLAGS)
pkg_spec_libs    := -Wl,--as-needed -lz -lplc4 -lplds4 -lnspr4 -lnssutil3 -liconv

$(pkg)_install_libs_4.14.2.1 := \
	librpmbuild.so \
	librpmbuild.so.8 \
	librpmbuild.so.8.1.0 \
	librpmio.so \
	librpmio.so.8 \
	librpmio.so.8.1.0 \
	librpmsign.so \
	librpmsign.so.8 \
	librpmsign.so.8.1.0 \
	librpm.so \
	librpm.so.8 \
	librpm.so.8.1.0

.PHONY: all
ifeq ("$(CONFIG_TINY_FLASH)","1")
all:
else
all: $(pkg)
endif

.PHONY: $(pkg) $(pkg)-build $(pkg)-install
$(pkg):
	$(call try_mkdir, $(IMAGES))
	$(call log_sha1, $(pwd) $(pwd)/../nss-nspr, $(pkg_check_flag))
	@if [ -f $(pkg_build_flag) ] && [ `diff -Nrua $(pkg_build_flag) $(pkg_check_flag) 2>&1 | wc -m` -eq 0 ]; then \
		cp -ar $(pkg_cache_root)/* $(IMAGES); \
		echo $(pkg)-$(pkg_version) cached; \
	else \
		$(MAKE) clean $(pkg)-install install; \
	fi
$(pkg_build_dir): $(pkg_location)
	$(call try_mkdir, $(pkg_build_root))
	$(call extract_tarball, $<, $(pkg_build_root), $@)
	$(call patch_src, $(pkg_build_dir), $(pkg_patches_dir))
$(pkg)-build: $(pkg_build_dir)
	@echo "building $(pkg) ..."
	pushd $(pkg_build_dir) > /dev/null && \
	./configure \
	    --prefix=/usr \
	    --libdir=$(pkg_tmp_install_dir)/lib \
	    --host=$(CROSS) \
	    --disable-nls \
	    --disable-rpath \
	    --disable-static \
	    --disable-python \
	    --disable-plugins \
	    --without-lua \
	    --without-archive \
	    --with-external-db \
	    --with-gnu-ld \
	    CPPFLAGS="$(pkg_spec_cflags)" \
	    LDFLAGS="$(pkg_spec_ldflags)" \
	    LIBS="$(pkg_spec_libs)" && \
	$(MAKE) && \
	$(MAKE) install prefix=$(pkg_tmp_install_dir) && \
	popd > /dev/null
$(pkg)-install: $(pkg)-build
	@echo install $(pkg) ...
	$(call try_mkdir, $(cache_sodir))
	$(call try_mkdir, $(cache_header_dir))
	$(call try_mkdir, $(cache_usr_bin_dir))
	$(call try_mkdir, $(cache_usr_lib_dir))
	$(call try_mkdir, $(install_sodir))
	$(call try_mkdir, $(install_header_dir))
	$(call try_mkdir, $(install_usr_bin_dir))
	$(call try_mkdir, $(install_usr_lib_dir))
	$(call try_strip_dir, $(pkg_tmp_install_dir))
	@echo installing $(pkg) ...
	$(call copy_dir, $(pkg_tmp_install_dir)/include, $(install_header_dir), -a)
	$(call copy_dir, $(pkg_tmp_install_dir)/bin, $(install_usr_bin_dir), -a)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(install_sodir), \
		$($(pkg)_install_libs_$(pkg_version)), -a)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(install_usr_lib_dir), rpm, -ar)
	@echo caching $(pkg) ...
	$(call copy_dir, $(pkg_tmp_install_dir)/include, $(cache_header_dir), -a)
	$(call copy_dir, $(pkg_tmp_install_dir)/bin, $(cache_usr_bin_dir), -a)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(cache_sodir), \
		$($(pkg)_install_libs_$(pkg_version)), -a)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(cache_usr_lib_dir), rpm, -ar)
	$(call log_sha1, $(pwd) $(pwd)/../nss-nspr, $(pkg_build_flag))

.PHONY: install
install:
	$(call try_mkdir, $(IMAGES))
	$(call copy_dir, $(install_root), $(IMAGES), -arv)

.PHONY: clean
clean:
	rm -rf $(pkg_build_flag)
	rm -rf $(pkg_check_flag)
	rm -rf $(install_tmp_root)
	rm -rf $(pkg_build_root)
	rm -rf $(install_root)
	rm -rf $(pkg_cache_root)

