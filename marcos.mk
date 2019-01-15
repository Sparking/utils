# 编译器相关
cross_compiler_version       := $(shell echo __GNUC__            | LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(CROSS)-gcc -E - | tail -n 1)
cross_compiler_minor_version := $(shell echo __GNUC_MINOR__      | LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(CROSS)-gcc -E - | tail -n 1)
cross_compiler_patchlevel    := $(shell echo __GNUC_PATCHLEVEL__ | LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(CROSS)-gcc -E - | tail -n 1)
cross_compiler_sizeof_size_t := $(shell echo __SIZEOF_SIZE_T__   | LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(CROSS)-gcc -E - | tail -n 1)

# 尝试裁剪符号
# $1: 存放文件的目录
define try_strip_dir
@for obj in `find $1 2>/dev/null`; do \
    if ! [ `file $${obj} | grep -i elf | grep 'not stripped' | wc -m` -eq 0 ]; then \
        $(CROSS)-strip -s $${obj}; \
        echo STRIP $${obj}; \
    fi; \
 done
endef

# 尝试裁剪符号
# $1: 文件列表
# $2: 文件的存放位置, 可选参数
define try_strip_files
@ prefix=$(shell echo $2); \
 if ! [ -d "$${prefix}" ]; then \
    echo strip error: directory $2 not foud 1>&2; \
    exit 1; \
 fi; \
 if ! [ -z "$${prefix}" ]; then \
	 prefix=$${prefix}/; \
 fi; \
 for obj in $1; do \
    if ! [ `file $${prefix}$${obj} | grep -i elf | grep 'not stripped' | wc -m` -eq 0 ]; then \
        $(CROSS)-strip -s $${prefix}$${obj}; \
        echo STRIP $${obj}; \
    fi; \
 done
endef

define try_mkdir
@if ! [ -d $1 ]; then \
    echo build directory $1; \
    mkdir -p $1; \
 fi
endef

define remkdir
@echo remkdir $1 ...
@rm -rf $1
@mkdir -p $1
endef

# 记录sha1和编译器信息到指定文件中
# $1: 目录列表
# $2: 记录log的文件
define log_sha1
@for d in $1; do \
    echo git log -1 --pretty="format:%H" $${d} > $2; \
 done
@$(CROSS)-gcc -v >> $2 2>&1
endef

# 参数说明
# $1: tarball 压缩包
# $2: 压缩包的解压位置
# $3: 压缩包解开后的文件夹名称
define extract_tarball
@echo Extracting $1 to $2
@tar -xf $1 -C $2
@if [ -d $3 ]; then \
	echo "extract success"; \
 else \
    echo "extract failed" 1>&2; \
	exit 1; \
 fi
endef

# 打补丁
# 参数说明
# $1: 源码的根目录
# $2: 存放补丁的目录
define patch_src
@if [ -d $1 ] && [ -d $2 ]; then \
     pushd $1 > /dev/null; \
     for pa in `find $2 -type f -name "*.patch" | sort`; do \
         patch -p1 < $${pa}; \
     done; \
     popd > /dev/null; \
 fi
endef

# 拷贝列表中的文件到指定目录
# $1: 列表中的文件的根目录
# $2: 目标文件夹
# $3: 文件列表
# $4: cp命令的参数
define copy_files
@echo copy files from $1 to $2
@if [ -d $1 ] && [ -d $2 ]; then \
    if [ "$1" == "$2" ]; then \
        echo copy error: the source directory \`$1\" is the same with destination directory 1>&2; \
	    exit 1; \
    fi; \
	for obj in $3; do \
	    if cp $4 $1/$${obj} $2 > /dev/null; then \
		    printf "copy $${obj} success\n"; \
		else \
		    printf "copy $${obj} failed\n" 1>&2; \
			exit 1; \
		fi; \
	done; \
 else \
     printf "copy error: " 1>&2; \
     if ! [ -d $1 ]; then \
         echo $1 not found 1>&2; \
     else \
         echo $2 not found 1>&2; \
     fi; \
	 exit 1; \
 fi
endef

# 拷贝文件夹下的所有内容到指定的文件夹下
# $1: 源文件夹
# $2: 目标文件夹
# $3: cp命令的参数
define copy_dir
@echo copy files from $1 to $2
@if [ -d $1 ] && [ -d $2 ]; then \
    if [ "$1" == "$2" ]; then \
        echo copy error: the source directory \`$1\" is the same with destination directory 1>&2; \
        exit 1; \
    fi; \
	for obj in `ls -A $1`; do \
        if cp $3 $1/$${obj} $2 > /dev/null; then \
            printf "copy $${obj} success\n"; \
        else \
            printf "copy $${obj} failed\n" 1>&2; \
			exit 1; \
        fi; \
	done; \
 else \
     printf "copy error: " 1>&2; \
     if ! [ -d $1 ]; then \
         echo $1 not found 1>&2; \
     else \
         echo $2 not found 1>&2; \
     fi; \
	 exit 1; \
 fi
endef

