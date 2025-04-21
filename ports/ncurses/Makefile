TOOLCHAIN=$(CURDIR)/../../toolchain
ROOT=$(realpath $(CURDIR)/../..)

PKG_NAME:=ncurses
URL=https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.5.tar.gz
TARBALL=$(notdir $(URL))
ARCH=aarch64-unknown-linux-gnu
CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++
BINS=usr/bin/tabs usr/bin/infocmp usr/bin/tic usr/bin/toe usr/bin/infotocap usr/bin/captoinfo usr/bin/reset usr/bin/tset usr/bin/tput usr/bin/clear 

.PHONY: all install clean pkg

all: build

.fetch-completed:
	@if [ ! -f $(TARBALL) ]; then \
		echo "Downloading $@"; \
		wget -c $(URL); \
	fi
	@touch $@

fetch: .fetch-completed
	@echo "Fetch $(TARBALL) completed"

.untar-completed: .fetch-completed
	@echo "Preparing $(PKG_NAME)"
	# Create the src directory if it doesn't exist
	@mkdir -p src
	# Unpack the tarball to src/
	@tar zxvf $(TARBALL) -C src --strip-components=1
	@touch $@

# The configuration with --with-termlib and --disable-widec will
# create libtinfo.so.
.build-completed: .untar-completed
	@echo "Building $(PKG_NAME)"
	cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH \
	CC=$(CC) CXX=$(CXX) \
	./configure --prefix=$(TOOLCHAIN)/usr \
	--disable-stripping \
	--with-termlib=yes \
	--disable-widec \
	--host=$(ARCH) && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make
	@touch $@

build: .build-completed
	@echo "Build $(PKG_NAME) completed"

install: .build-completed
	@echo "Installing $(PKG_NAME)"
	# Install the library
	@touch .install-before-completed
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make install
	@find $(TOOLCHAIN) -newer .install-before-completed | \
		awk -F "$(TOOLCHAIN)" '{print $$2;}' | \
		sed 's/^\///' | \
		xargs -I '{}' bash -c "if [  -f $(TOOLCHAIN)/{} ]; then echo {}; fi" > filelist
	@echo "Installed $(PKG_NAME):"

clean:
	@echo "Cleaning up"
	# Remove the src directory
	@rm -rf src dist
	# Remove the tarball
	@rm -f $(TARBALL)
	@rm -f filelist
	@rm -f .*-completed

include ../MK/port.mk
