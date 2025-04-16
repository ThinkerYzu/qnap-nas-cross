pkg:
	@echo "Packaging $(PKG_NAME)"
	@mkdir -p dist
	@cd $(TOOLCHAIN) && \
		tar zcvfT $(CURDIR)/dist/$(PKG_NAME).tgz $(CURDIR)/filelist
	@echo "Package $(PKG_NAME) created at $(CURDIR)/dist/$(PKG_NAME).tgz"

