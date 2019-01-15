include ../marcos.mk

IMAGES = $(PRJROOT)/images
KBUILD_OUTPUT = $(PRJROOT)/tmp/kernel-build

# 编译依赖的目录
pkg              := nss-nspr
subpkg1          := nss
subpkg1_version  := 3.41
subpkg2          := nspr
subpkg2_version  := 4.20
pwd              := $(shell pwd)
pkg_build_root   := $(pwd)/build
pkg_patches_root := $(pwd)/patches
pkg_storage_root := $(pwd)/packages
pkg_location     := $(pkg_storage_root)/$(subpkg1)-$(subpkg1_version)-with-$(subpkg2)-$(subpkg2_version).tar.gz
pkg_build_dir    := $(pkg_build_root)/$(subpkg1)-$(subpkg1_version)
pkg_patches_dir  := $(pkg_patches_root)/$(subpkg1)-$(subpkg1_version)-with-$(subpkg2)-$(subpkg2_version)

# 交叉编译工具链
CC := 
AR := 
AS := 
LD := 
STRIP := 
RANLIB := 

# 安装目录
header_location     := 
top_srcdir          := $(pwd)
install_root        := ${top_srcdir}/images
install_header_dir  := ${install_root}/header/$(header_location)
install_rootfs_dir  := $(install_root)/rootfs
install_sodir       := $(install_rootfs_dir)/$(INSTALL_SODIR)
INSTALL_MOD_PATH    := $(install_rootfs_dir)

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
$(subpkg2)_spec_tools := AR=$(CROSS)-ar AS=$(CROSS)-as CC=$(CROSS)-gcc CXX=$(CROSS)-g++ LD=$(CROSS)-ld RANLIB=$(CROSS)-ranlib STRIP=$(CROSS)-strip
$(subpkg2)_spec_env   := "$($(subpkg2)_spec_tools) CPPFLAGS='$(CFLAGS)'"
$(subpkg2)_extra_conf_options :=
pkg_mk_extra_options  := NSS_ENABLE_WERROR=0

ifeq ($(build_use_64_option), 1)
pkg_mk_extra_options += USE_64=1
ifeq ($(ARCH), x86)
ARCH := x86_64
endif
endif

# 编译期间用到的临时目录
# 获取linux的内核版本(用于匹配路径)
linux_kernel_release=$(shell uname -r)
linux_kernel_release_prefix=$(subst $(suffix $(linux_kernel_release)),,$(linux_kernel_release))
# 目标文件的最终存放位置
ifeq ("$(build_use_64_option)", "1")
$(pkg)_build_obj_dir_mark := _64
else
$(pkg)_build_obj_dir_mark :=
endif
$(pkg)_build_obj_dist_dir=$(pkg_build_dir)/dist
$(pkg)_build_obj_dir=$($(pkg)_build_obj_dist_dir)/$(shell uname -s)$(linux_kernel_release_prefix)_$(ARCH)_glibc_PTH$($(pkg)_build_obj_dir_mark)_OPT.OBJ

pkg_install_libs := \
	libfreebl3.so \
	libfreeblpriv3.so \
	libnspr4.so \
	libnss3.so \
	libnssckbi.so \
	libnssdbm3.so \
	libnsssysinit.so \
	libnssutil3.so \
	libplc4.so \
	libplds4.so \
	libsmime3.so \
	libsoftokn3.so \
	libssl3.so

.PHONY: all
all: $(pkg)

.PHONY: $(pkg) $(pkg)-build $(pkg)-install
$(pkg):
	$(call try_mkdir, $(IMAGES))
	$(call log_sha1, $(pwd), $(pkg_check_flag))
	@if [ -f $(pkg_build_flag) ] && [ `diff -Nrua $(pkg_build_flag) $(pkg_check_flag) 2>&1 | wc -m` -eq 0 ] ; then \
		cp -ar $(pkg_cache_root)/* $(IMAGES); \
		echo $(subpkg1)-$(subpkg1_version)-$(subpkg2)-$(subpkg2_version) cached; \
	else \
		$(MAKE) clean $(pkg)-install install; \
	fi
$(pkg_build_dir): $(pkg_location)
	$(call try_mkdir, $(pkg_build_root))
	$(call extract_tarball, $<, $(pkg_build_root), $@)
	$(call patch_src, $(pkg_build_dir), $(pkg_patches_dir))
$(pkg)-build: $(pkg_build_dir)
	@echo building $(pkg) ...
	unset AR && unset CFLAGS && unset LDFLAGS && unset CPPFLAGS && \
	    NSPR_CONFIGURE_ENV=$($(subpkg2)_spec_env) \
	    NSPR_CONFIGURE_OPTS="--target=$(CROSS) --cache-file=/dev/null $($(subpkg2)_extra_conf_options)" \
	make -C $(pkg_build_dir)/nss nss_build_all \
	    OS_TEST=$(ARCH) \
	    NATIVE_CC=gcc \
	    CROSS_COMPILE=1 \
	    BUILD_OPT=1 \
	    OPT_CODE_SIZE=1 \
	    NSS_DISABLE_GTESTS=1 \
	    ALLOW_OPT_CODE_SIZE=1 \
	    NSS_USE_SYSTEM_SQLITE=1\
	   $(pkg_mk_extra_options)
$(pkg)-install: $(pkg)-build
	$(call try_mkdir, $(install_sodir))
	$(call try_mkdir, $(install_header_dir))
	$(call try_mkdir, $(cache_sodir))
	$(call try_mkdir, $(cache_header_dir))
	$(call try_strip_dir, $($(pkg)_build_obj_dir))
	@echo installing $(pkg) ...
	$(call copy_dir, $($(pkg)_build_obj_dist_dir)/public, $(install_header_dir), -arL)
	$(call copy_dir, $($(pkg)_build_obj_dist_dir)/private, $(install_header_dir), -arL)
	$(call copy_dir, $($(pkg)_build_obj_dir)/include, $(install_header_dir), -arL)
	$(call copy_files, $($(pkg)_build_obj_dir)/lib, $(install_sodir), \
	   $(pkg_install_libs), -arL)
	@echo caching $(pkg) ...
	$(call copy_dir, $($(pkg)_build_obj_dist_dir)/public, $(cache_header_dir), -arL)
	$(call copy_dir, $($(pkg)_build_obj_dist_dir)/private, $(cache_header_dir), -arL)
	$(call copy_dir, $($(pkg)_build_obj_dir)/include, $(cache_header_dir), -arL)
	$(call copy_files, $($(pkg)_build_obj_dir)/lib, $(cache_sodir), \
	   $(pkg_install_libs), -arL)
	$(call log_sha1, $(pwd), $(pkg_build_flag))

.PHONY: install
install:
	$(call try_mkdir, $(IMAGES))
	$(call copy_dir, $(install_root), $(IMAGES), -arL)

.PHONY: clean
clean:
	rm -rf $(pkg_build_flag)
	rm -rf $(pkg_check_flag)
	rm -rf $(install_root)
	rm -rf $(pkg_build_root)
	rm -rf $(pkg_cache_root)

