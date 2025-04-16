TOOLCHAIN=$(CURDIR)/../../toolchain
ARCH=aarch64-unknown-linux-gnu

PKG_NAME=exif
URL:=https://github.com/libexif/exif

.PHONY: all fetch clean install

all: build

.fetch-completed:
	@echo "Fetching exif..."
	@git clone --depth=1 $(URL) src
	@touch $@

fetch: .fetch-completed
	@echo "Fetch exif completed"

.build-completed: .fetch-completed
	@echo "Building exif..."
	@cd src && autoreconf --install
	@cd src && \
	PKG_CONFIG_PATH=$(TOOLCHAIN)/usr/lib/pkgconfig/ \
	CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc \
	CXX=$(TOOLCHAIN)/bin/$(ARCH)-g++ \
		./configure --prefix=$(TOOLCHAIN)/usr/ --host=$(ARCH)
	@cd src && $(MAKE) -j4
	@touch $@

build: .build-completed
	@echo "Build exif completed"

install:
	@echo "Installing exif..."
	@touch .install-before-completed
	@cd src && $(MAKE) install
	@find $(TOOLCHAIN) -newer .install-before-completed | \
		awk -F "$(TOOLCHAIN)" '{print $$2;}' | \
		sed 's/^\///' | \
		xargs -I '{}' bash -c "if [  -f $(TOOLCHAIN)/{} ]; then echo {}; fi" > filelist
	@echo "Install exif completed"

clean:
	@echo "Cleaning exif..."
	@rm -rf src dist
	@rm -f filelist
	@rm -f .*-completed
	@echo "Clean exif completed"

include ../MK/port.mk
