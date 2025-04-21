TOOLCHAIN=$(CURDIR)/../../toolchain
ROOT=$(realpath $(CURDIR)/../..)

PKG_NAME:=bzip2
URL=https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
TARBALL=$(notdir $(URL))
ARCH=aarch64-unknown-linux-gnu
CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++
BINS=usr/bin/bzip2 usr/bin/bunzip2 usr/bin/bzcat usr/bin/bzip2recover

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

.build-completed: .untar-completed
	@echo "Building $(PKG_NAME)"
	cd src && \
	patch -p1 < ../makefile.diff && \
	CFLAGS="-Os -fPIC" \
	PATH=$(TOOLCHAIN)/bin:$$PATH make libbz2.a bzip2 bzip2recover
	@touch $@

build: .build-completed
	@echo "Build $(PKG_NAME) completed"

install: .build-completed
	@echo "Installing $(PKG_NAME)"
	# Install the library
	@touch .install-before-completed
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make PREFIX=$(TOOLCHAIN)/usr install
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
