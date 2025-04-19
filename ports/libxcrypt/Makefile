TOOLCHAIN=$(CURDIR)/../../toolchain

PKG_NAME:=libxcrypt
URL=https://github.com/besser82/libxcrypt
ARCH=aarch64-unknown-linux-gnu
CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++

.PHONY: all install clean pkg

all: build

.fetch-completed:
	@echo "Fetch popt..."
	@git clone --depth 1 $(URL) src
	@touch $@

fetch: .fetch-completed
	@echo "Fetch $(PKG_NAME) completed."

.autoreconf-completed: .fetch-completed
	@echo "Running autoreconf..."
	# Run autoreconf
	@cd src && autoreconf --install
	@touch $@

.build-completed: .autoreconf-completed
	@echo "Building $(PKG_NAME)..."
	# Build the library
	@cd src && autoreconf --install
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
	@echo "Installing $(PKG_NAME)..."
	# Install the library
	@touch .install-before-completed
	@cd src && \
	PATH=$(TOOLCHAIN)/bin:$$PATH make install
	@find $(TOOLCHAIN) -newer .install-before-completed | \
		awk -F "$(TOOLCHAIN)" '{print $$2;}' | \
		sed 's/^\///' | \
		xargs -I '{}' bash -c "if [  -f $(TOOLCHAIN)/{} ]; then echo {}; fi" > filelist
	@echo "Installed $(PKG_NAME)"

clean:
	@echo "Cleaning up"
	# Remove the src directory
	@rm -rf src dist
	# Remove the tarball
	@rm -f $(TARBALL)
	@rm -f filelist
	@rm -f .*-completed

include ../MK/port.mk
