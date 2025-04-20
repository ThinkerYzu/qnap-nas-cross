-include $(ROOT)/dest-config.mk

ROOT ?= $(realpath $(CURDIR)/../..)
TOOLCHAIN ?= $(ROOT)/toolchain

pkg:
	@echo "Packaging $(PKG_NAME)"
	@mkdir -p dist
	@cd $(TOOLCHAIN) && \
		tar zcvfT $(CURDIR)/dist/$(PKG_NAME).tgz $(CURDIR)/filelist
	@echo "Package $(PKG_NAME) created at $(CURDIR)/dist/$(PKG_NAME).tgz"

initsysroot:
	@echo "Init sysroot for binaries"
	@mkdir -p $(TOOLCHAIN)
	@test -n "$(DEST_SYSROOT)" || \
		{ echo "Please provide 'DEST_SYSROOT' first"; exit 1; }
	@cd $(TOOLCHAIN) && \
		for i in $(BINS); do \
			echo "Including $${i}"; \
			$(ROOT)/scripts/chsysroot.sh $(DEST_SYSROOT) $${i}; \
		done

