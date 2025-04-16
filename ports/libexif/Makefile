TOOLCHAIN=$(CURDIR)/../../toolchain

PKG_NAME:=libexif
URL=https://github.com/libexif/libexif/releases/download/v0.6.25/libexif-0.6.25.tar.xz
TARBALL=libexif-0.6.25.tar.xz
ARCH=aarch64-unknown-linux-gnu
CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++

.PHONY: all install clean pkg

all: build

.fetch-completed:
	@if [ ! -f $(TARBALL) ]; then \
		echo "Downloading $@"; \
		wget -c $(URL); \
	fi
	@touch $@

.untar-completed: .fetch-completed
	@echo "Preparing $@"
	# Create the src directory if it doesn't exist
	@mkdir -p src
	# Unpack the tarball to src/
	@tar Jxvf $(TARBALL) -C src --strip-components=1
	@touch $@

.build-completed: .untar-completed
	@echo "Building $@"
	# Build the library
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH \
	CC=$(CC) CXX=$(CXX) \
	./configure --prefix=$(TOOLCHAIN)/usr \
		--host=$(ARCH) && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make
	@touch $@

build: .build-completed
	@echo "Build libexif completed"

install: .build-completed
	@echo "Installing $@"
	# Install the library
	@touch .install-before-completed
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make install
	@find $(TOOLCHAIN) -newer .install-before-completed | \
		awk -F "$(TOOLCHAIN)" '{print $$2;}' | \
		sed 's/^\///' | \
		xargs -I '{}' bash -c "if [  -f $(TOOLCHAIN)/{} ]; then echo {}; fi" > filelist
	@echo "Installed libexif:"

clean:
	@echo "Cleaning up"
	# Remove the src directory
	@rm -rf src dist
	# Remove the tarball
	@rm -f $(TARBALL)
	@rm -f filelist
	@rm -f .*-completed

include ../MK/port.mk
