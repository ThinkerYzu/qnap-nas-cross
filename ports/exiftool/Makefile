ROOT=$(realpath $(CURDIR)/../..)
TOOLCHAIN=$(ROOT)/toolchain

PKG_NAME:=exiftool
URL=https://exiftool.org/Image-ExifTool-13.27.tar.gz
TARBALL=$(notdir $(URL))
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

fetch: .fetch-completed
	@echo "Fetch $(TARBALL) completed"

.untar-completed: .fetch-completed
	@echo "Preparing $@"
	# Create the src directory if it doesn't exist
	@mkdir -p src
	# Unpack the tarball to src/
	@tar zxvf $(TARBALL) -C src --strip-components=1
	@touch $@

.build-completed: .untar-completed
	@echo "Building $(PKG_NAME)"
	cd src && \
	perl ./Makefile.PL && \
	sed "s/\\[root\\]/$$(echo $(ROOT)|sed 's/\//\\\//g')/g" ../makefile.temp > Makefile && \
	PERL5LIB=$(TOOLCHAIN)/usr/lib/perl5/5.40.2/ PATH=$(TOOLCHAIN)/bin:$$PATH make
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
