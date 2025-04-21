TOOLCHAIN=$(CURDIR)/../../toolchain
ROOT=$(realpath $(CURDIR)/../..)

PKG_NAME:=sqlite3
URL=https://sqlite.org/2025/sqlite-src-3490100.zip
TARBALL=$(notdir $(URL))
ARCH=aarch64-unknown-linux-gnu
CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++
BINS=usr/bin/sqlite3

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
	@unzip -x $(TARBALL) -d src
	@touch $@

# The configuration with --with-termlib and --disable-widec will
# create libtinfo.so.
.build-completed: .untar-completed
	@echo "Building $(PKG_NAME)"
	cd src/sqlite-src-3490100/ && \
	PATH=$(TOOLCHAIN)/bin:$$PATH \
	CC=$(CC) CXX=$(CXX) \
	./configure --prefix=$(TOOLCHAIN)/usr \
	--disable-tcl \
	--host=$(ARCH) && \
	CC=$(CC) CXX=$(CXX) PATH=$(TOOLCHAIN)/bin:$$PATH make
	@touch $@

build: .build-completed
	@echo "Build $(PKG_NAME) completed"

install: .build-completed
	@echo "Installing $(PKG_NAME)"
	# Install the library
	@touch .install-before-completed
	@cd src/sqlite-src-3490100/ && \
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
