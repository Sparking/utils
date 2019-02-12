include ../macros.mk

IMAGES = $(PRJROOT)/images
KBUILD_OUTPUT = $(PRJROOT)/tmp/kernel-build

# 编译依赖的目录
pkg               := db
pwd               := $(shell pwd)
pkg_build_root    := $(pwd)/build
pkg_storage_root  := $(pwd)/packages
pkg_version       := 18.1.25
pkg_location      := $(pkg_storage_root)/$(pkg)-$(pkg_version).tar.gz
pkg_build_dir     := $(pkg_build_root)/$(pkg)-$(pkg_version)
pkg_version_major := 18
pkg_version_minor := 1
pkg_version_build := 25
#pkg_version_revision :=

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
install_header_dir  := ${install_root}/header/$(header_location)
install_adir        := $(install_root)/lib
install_rootfs_dir  := $(install_root)/rootfs
install_sodir       := $(install_rootfs_dir)/$(INSTALL_SODIR)
install_usr_bin_dir := $(install_rootfs_dir)/usr/bin
install_usr_lib_dir := $(install_rootfs_dir)/usr/lib
install_sbin_dir    := $(install_rootfs_dir)/sbin
install_etc_dir     := $(install_rootfs_dir)/etc
INSTALL_MOD_PATH    := $(install_rootfs_dir)

# 临时安装目录
install_tmp_root       := $(pwd)/install
pkg_tmp_install_dir    := $(install_tmp_root)/$(pkg)-$(pkg_version)

# 缓存目录
pkg_cache_root    := $(CACHE)/utils/$(pkg)
cache_header_dir  := $(pkg_cache_root)/header/$(header_location)
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

# 探测编译器的sizeof(size_t)的大小
ifeq ("$(cross_compiler_sizeof_size_t)", "8")
build_use_64_option := 1
else
build_use_64_option := 0
endif

# 编译选项
pkg_spec_cflags  := $(CFLAGS)
pkg_spec_ldflags := $(LDFLAGS) 
pkg_spec_libs    := $(LIBS)
pkg_extra_conf   :=
pkg_extra_libs   :=

# 额外的编译选项
pkg_support_tcl     := n
pkg_support_openssl := n

ifeq ("$(pkg_support_tcl)", "y")
# 依赖的tcl的临时安装目录
tcl_install_path := $(shell cat $(pwd)/../tcl-expect/install/tcl_install_path)
tcl_config_path  := $(tcl_install_path)/lib
pkg_extra_conf += --enable-test --enable-tcl --with-tcl=$(tcl_config_path)
pkg_extra_libs += libdb_tcl.so libdb_tcl-$(pkg_version_major).so \
                   libdb_tcl-$(pkg_version_major).$(pkg_version_minor).so
else
pkg_extra_conf += --disable-test --disable-tcl
endif

ifneq ("$(pkg_support_openssl)", "y")
pkg_extra_conf += --with-repmgr-ssl=no
endif


.PHONY: all
all: $(pkg)

.PHONY: $(pkg) $(pkg)-build $(pkg)-install
$(pkg):
	$(call log_sha1, $(pwd) $(pwd)/../tcl-expect, $(pkg_check_flag))
	@if [ -f $(pkg_build_flag) ] && [ `diff -Nrua $(pkg_build_flag) $(pkg_check_flag) 2>&1 | wc -m` -eq 0 ] ; then \
		cp -ar $(pkg_cache_root)/* $(IMAGES); \
		echo $(pkg)-$(pkg_version) cached; \
	else \
		rm -rf $(pkg_build_flag) $(pkg_check_flag); \
		$(MAKE) clean $(pkg)-install install; \
	fi
$(pkg_build_dir): $(pkg_location)
	$(call try_mkdir, $(pkg_build_root))
	$(call extract_tarball, $<, $(pkg_build_root), $@)
$(pkg)-build: $(pkg_build_dir)
	@echo "building $(pkg) ..."
	pushd $(pkg_build_dir)/build_unix > /dev/null && \
	../dist/configure \
	    --prefix=$(pkg_tmp_install_dir) \
	    --host=$(CROSS) \
	    --disable-static \
	    $(pkg_extra_conf) \
	    CFLAGS="$(pkg_spec_cflags)" \
	    LDFLAGS="$(pkg_spec_ldflags)" \
	    LIBS="$(pkg_spec_libs)" && \
	$(MAKE) && \
	$(MAKE) install && \
	popd > /dev/null
$(pkg)-install: $(pkg)-build
	$(call try_mkdir, $(cache_sodir))
	$(call try_mkdir, $(cache_header_dir))
	$(call try_mkdir, $(cache_usr_bin_dir))
	$(call try_mkdir, $(install_sodir))
	$(call try_mkdir, $(install_header_dir))
	$(call try_mkdir, $(install_usr_bin_dir))
	$(call try_strip_dir, $(pkg_tmp_install_dir)/bin)
	$(call try_strip_dir, $(pkg_tmp_install_dir)/lib)
	@echo installing $(pkg) ...
	$(call copy_dir, $(pkg_tmp_install_dir)/include, $(install_header_dir), -ar)
	$(call copy_dir, $(pkg_tmp_install_dir)/bin, $(install_usr_bin_dir), -ar)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(install_sodir), \
	    libdb-$(pkg_version_major).$(pkg_version_minor).so \
	    libdb-$(pkg_version_major).so libdb.so \
		$(pkg_extra_libs), -a)
	@echo caching $(pkg) ...
	$(call copy_dir, $(pkg_tmp_install_dir)/include, $(cache_header_dir), -ar)
	$(call copy_dir, $(pkg_tmp_install_dir)/bin, $(cache_usr_bin_dir), -ar)
	$(call copy_files, $(pkg_tmp_install_dir)/lib, $(cache_sodir), \
	    libdb-$(pkg_version_major).$(pkg_version_minor).so \
	    libdb-$(pkg_version_major).so libdb.so \
		$(pkg_extra_libs), -a)
	$(call log_sha1, $(pwd) $(pwd)/../tcl-expect, $(pkg_build_flag))

.PHONY: install
install:
	$(call try_mkdir, $(IMAGES))
	$(call copy_dir, $(install_root), $(IMAGES), -arv)

.PHONY: clean
clean:
	rm -rf $(pkg_check_flag)
	rm -rf $(pkg_build_flag)
	rm -rf $(install_tmp_root)
	rm -rf $(install_root)
	rm -rf $(pkg_build_root)
	rm -rf $(pkg_cache_root)

