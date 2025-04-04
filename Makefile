TARGETS			:= user-folders system-folders
INSTALL_DIR  	:= $(PREFIX)/usr/local/bin
INSTALL_TARGETS	:= $(addprefix $(INSTALL_DIR)/, $(TARGETS))

.PHONY: all install uninstall

all:

install: $(INSTALL_TARGETS)

uninstall:
	rm -f $(INSTALL_TARGETS)

### Executable =================================================================

$(INSTALL_DIR):
	mkdir -p $@

$(INSTALL_DIR)/%: %.sh | $(INSTALL_DIR)
	install $< $@

