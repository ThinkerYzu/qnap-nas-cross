TOOLCHAIN=$(CURDIR)/../../toolchain

PKG_NAME=popt
URL=https://github.com/rpm-software-management/popt

.PHONY: all clean fetch build install

all: build

.fetch-completed:
	@echo "Fetch popt..."
	@git clone --depth 1 $(URL) src
	@touch $@

fetch: .fetch-completed
	@echo "Fetch popt completed."

.build-completed: .fetch-completed
	@echo "Building popt..."
	@cd src && PATH=$(TOOLCHAIN)/bin:$$PATH \
		cmake --toolchain="../mytoolchain.cmake" -S. -Bbin \
			--install-prefix=$(TOOLCHAIN)/usr
	@cd src/bin && $(MAKE) -j4
	@echo "Building popt completed."
	@touch $@

build: .build-completed
	@echo "Building popt completed."

clean:
	@echo "Cleaning up..."
	@rm -rf src dist
	@rm -f filelist
	@rm -f .*-completed
	@echo "Cleaned up."

install: .build-completed
	@echo "Installing popt..."
	@touch .install-before-completed
	@cd src/bin && $(MAKE) install
	@find $(TOOLCHAIN) -newer .install-before-completed | \
		awk -F "$(TOOLCHAIN)" '{print $$2;}' | \
		sed 's/^\///' | \
		xargs -I '{}' bash -c "if [  -f $(TOOLCHAIN)/{} ]; then echo {}; fi" > filelist
	@echo "Installed popt."

include ../MK/port.mk
