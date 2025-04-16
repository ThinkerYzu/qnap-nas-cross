ARCH=aarch64-unknown-linux-gnu

ROOT=$(CURDIR)

STAGE1 := $(ROOT)/stage1
STAGE2 := $(ROOT)/toolchain
TAR_DIRS := binutils-2.44 gcc-12.2.0 glibc-2.41 gmp-6.3.0 isl-0.24 \
	linux-6.14.2 mpc-1.3.1 mpfr-4.2.2

BINUTILS_TAR=binutils-2.44.tar.xz
BINUTILS_DIR=binutils-2.44
BINUTILS_URL=https://sourceware.org/pub/binutils/releases/binutils-2.44.tar.xz
GCC_TAR=gcc-12.2.0.tar.xz
GCC_DIR=gcc-12.2.0
GCC_URL=https://sourceware.org/pub/gcc/releases/gcc-12.2.0/gcc-12.2.0.tar.xz
GLIBC_TAR=glibc-2.41.tar.xz
GLIBC_DIR=glibc-2.41
GLIBC_URL=https://ftp.gnu.org/gnu/glibc/glibc-2.41.tar.xz
LINUX_TAR=linux-6.14.2.tar.xz
LINUX_DIR=linux-6.14.2
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.2.tar.xz

GMP_TAR=gmp-6.3.0.tar.xz
MPC_TAR=mpc-1.3.1.tar.gz
MPFR_TAR=mpfr-4.2.2.tar.xz
ISL_TAR=isl-0.24.tar.bz2

GMP_URL=https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
MPC_URL=https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
MPFR_URL=https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz
ISL_URL=https://libisl.sourceforge.io/isl-0.24.tar.bz2

TARS := $(BINUTILS_TAR) $(GCC_TAR) $(GLIBC_TAR) $(LINUX_TAR) \
		$(GMP_TAR) $(MPC_TAR) $(MPFR_TAR) $(ISL_TAR)

STAGES := binutils-stage1 gcc-stage1 linux-stage1 glibc-stage1 \
		binutils-stage2 linux-stage2 glibc-stage2 gcc-stage2 \
		stage1-build stage2-build

all:: stage2-build

clean::
	rm -rf $(STAGE1) $(STAGE2)
	cd src; rm -rf $(TAR_DIRS)
	rm -rf $(STAGES)

clean-all:: clean
	@echo "Clean all"
	@cd src; rm -rf $(TARS)
	@rm prepare-stage1

stage1-build: binutils-stage1 gcc-stage1 linux-stage1 glibc-stage1
	@touch $@

prepare-stage1:
	@echo "Fetch source code"
	@cd src && if ! test -f $(BINUTILS_TAR); then wget $(BINUTILS_URL); fi
	@cd src && if ! test -f $(GCC_TAR); then wget $(GCC_URL); fi
	@cd src && if ! test -f $(GLIBC_TAR); then wget $(GLIBC_URL); fi
	@cd src && if ! test -f $(LINUX_TAR); then wget $(LINUX_URL); fi
	@cd src && if ! test -f $(GMP_TAR); then wget $(GMP_URL); fi
	@cd src && if ! test -f $(MPC_TAR); then wget $(MPC_URL); fi
	@cd src && if ! test -f $(MPFR_TAR); then wget $(MPFR_URL); fi
	@cd src && if ! test -f $(ISL_TAR); then wget $(ISL_URL); fi
	@touch $@

binutils-stage1: prepare-stage1
	@echo "Building binutils stage1"
	@cd src && tar Jxf $(BINUTILS_TAR) && mkdir $(BINUTILS_DIR)/objs
	@cd src/$(BINUTILS_DIR)/objs && ../configure --prefix=$(STAGE1) --target=$(ARCH)
	@cd src/$(BINUTILS_DIR)/objs && $(MAKE) -j32
	@cd src/$(BINUTILS_DIR)/objs && $(MAKE) install
	@touch $@

gcc-stage1: binutils-stage1
	@echo "Building gcc stage1"
	@cd src && tar Jxf $(GCC_TAR) && mkdir $(GCC_DIR)/objs
	@cd src && tar jxvf isl-0.24.tar.bz2 && \
		tar Jxvf gmp-6.3.0.tar.xz && \
		tar zxvf mpc-1.3.1.tar.gz && \
		tar Jxvf mpfr-4.2.2.tar.xz
	@cd src/$(GCC_DIR) && patch -p1 < ../gcc-12.2.0.diff && \
		ln -s ../isl-0.24 isl && \
		ln -s ../gmp-6.3.0 gmp && \
		ln -s ../mpc-1.3.1 mpc && \
		ln -s ../mpfr-4.2.2 mpfr
	@cd src/$(GCC_DIR)/objs && \
		PATH=$(STAGE1)/bin/:$$PATH \
			../configure --target=$(ARCH) \
				--enable-languages=c,c++ \
				--with-build-sysroot=$(STAGE1) \
				--with-newlib --host=x86_64-pc-linux-gnu \
				--prefix=$(STAGE1) --disable-libstdcxx \
				--disable-libssp --without-headers \
				--disable-threads --disable-libvtv \
				--disable-libquadmath --disable-libgomp \
				--disable-libatomic
	@cd src/$(GCC_DIR)/objs && \
		PATH=$(STAGE1)/bin/:$$PATH $(MAKE) -j32 && \
		PATH=$(STAGE1)/bin/:$$PATH $(MAKE) install
	@touch $@

linux-stage1: gcc-stage1
	@echo "Building linux stage1"
	@cd src && tar Jxvf $(LINUX_TAR)
	@cd src/$(LINUX_DIR) && zcat ../qnap-config.gz > .config
	@cd src/$(LINUX_DIR) && PATH=$(STAGE1)/bin/:$$PATH \
		$(MAKE) ARCH=arm64 CROSS_COMPILE=$(ARCH)- olddefconfig
	@cd src/$(LINUX_DIR) && PATH=$(STAGE1)/bin/:$$PATH \
		$(MAKE) ARCH=arm64 CROSS_COMPILE=$(ARCH)- -j32
	@cd src/$(LINUX_DIR) && PATH=$(STAGE1)/bin/:$$PATH \
		$(MAKE) ARCH=arm64 CROSS_COMPILE=$(ARCH)- INSTALL_HDR_PATH=$(STAGE1) headers_install
	@touch $@

glibc-stage1: linux-stage1
	@echo "Building glibc stage1"
	@cd src && tar Jxvf $(GLIBC_TAR) && mkdir $(GLIBC_DIR)/objs
	@cd src/$(GLIBC_DIR)/objs && \
		CC=$(STAGE1)/bin/$(ARCH)-gcc \
		CXX=$(STAGE1)/bin/$(ARCH)-g++ \
		../configure --host=$(ARCH) --prefix= \
			--with-headers=$(STAGE1)/include/ --disable-werror
	@cd src/$(GLIBC_DIR)/objs && \
		$(MAKE) -j32
	@cd src/$(GLIBC_DIR)/objs && \
		$(MAKE) DESTDIR=$(STAGE1) install
	@mkdir $(STAGE1)/usr
	@mv $(STAGE1)/include $(STAGE1)/usr/
	@touch $@

stage2-build: binutils-stage2 linux-stage2 glibc-stage2 gcc-stage2
	@touch $@

binutils-stage2: stage1-build
	@echo "Building binutils stage2"
	@cd src/$(BINUTILS_DIR)/objs && rm -rf *
	@cd src/$(BINUTILS_DIR)/objs && ../configure --prefix=$(STAGE2) --target=$(ARCH)
	@cd src/$(BINUTILS_DIR)/objs && $(MAKE) -j32
	@cd src/$(BINUTILS_DIR)/objs && $(MAKE) install
	@touch $@

linux-stage2: stage1-build
	@echo "Building linux stage2"
	@cd src/$(LINUX_DIR) && PATH=$(STAGE1)/bin/:$$PATH \
		$(MAKE) ARCH=arm64 CROSS_COMPILE=$(ARCH)- INSTALL_HDR_PATH=$(STAGE2) headers_install
	@touch $@

glibc-stage2: linux-stage2
	@echo "Building glibc stage2"
	@cd src/$(GLIBC_DIR)/objs && rm -rf *
	# The parameter --prefix= make sure the paths in ldscripts
	# relative to the sysroot of the compiler and the linker
	@cd src/$(GLIBC_DIR)/objs && \
		CC=$(STAGE1)/bin/$(ARCH)-gcc \
		CXX=$(STAGE1)/bin/$(ARCH)-g++ \
		../configure --host=$(ARCH) --prefix= \
			--with-headers=$(STAGE2)/include/ --disable-werror
	@cd src/$(GLIBC_DIR)/objs && \
		$(MAKE) -j32
	# Install to the sysroot of the compiler and the linker
	@cd src/$(GLIBC_DIR)/objs && \
		$(MAKE) DESTDIR=$(STAGE2) install
	@mkdir $(STAGE2)/usr
	@mv $(STAGE2)/include $(STAGE2)/usr/
	@touch $@

gcc-stage2: glibc-stage2 binutils-stage2
	@echo "Building gcc stage2"
	@rm -rf src/$(GCC_DIR)
	@cd src && tar Jxf $(GCC_TAR) && mkdir $(GCC_DIR)/objs
	@cd src/$(GCC_DIR) && \
		ln -s ../isl-0.24 isl && \
		ln -s ../gmp-6.3.0 gmp && \
		ln -s ../mpc-1.3.1 mpc && \
		ln -s ../mpfr-4.2.2 mpfr
	@cd src/$(GCC_DIR)/objs && \
		PATH=$(STAGE2)/bin/:$$PATH \
			../configure --target=$(ARCH) \
				--enable-languages=c,c++ \
				--with-build-sysroot=$(STAGE2) \
				--host=x86_64-pc-linux-gnu \
				--prefix=$(STAGE2) \
				--disable-libsanitizer \
				--disable-sanity-checks
	@cd src/$(GCC_DIR)/objs && \
		PATH=$(STAGE2)/bin/:$$PATH $(MAKE) -j32 && \
		PATH=$(STAGE2)/bin/:$$PATH $(MAKE) install
	@touch $@
