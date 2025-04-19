TOOLCHAIN=$(CURDIR)/../../toolchain

PKG_NAME:=libexif
URL=https://www.cpan.org/src/5.0/perl-5.40.2.tar.gz
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

.build-host-completed: .untar-completed
	@echo "Building $(PKG_NAME) host"
	# Build the library
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH ./Configure -de -Dusecrosscompile -Dtargetarch=$(ARCH) -Dcc=$(CC) -Dsysroot=$(TOOLCHAIN) -Dprefix=$(TOOLCHAIN)/usr && \
	cd host && PATH=$(TOOLCHAIN)/bin:$$PATH make
	@touch $@

.build-completed: .build-host-completed
	@echo "Building $(PKG_NAME)"
	cd src && \
	chmod +w Makefile.SH && \
	patch -p1 < ../Makefile.SH.diff && \
	cp ../config.sh ./ && \
	./Configure -S && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make
	@touch $@

build: .build-completed
	@echo "Build $(PKG_NAME) completed"

install: .build-completed
	@echo "Installing $(PKG_NAME)"
	# Install the library
	@touch .install-before-completed
	@cd src && \
	make install
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
