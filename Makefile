TARGET			= user-folders
INSTALL_DIR  	= $(PREFIX)/usr/local/bin

.PHONY: all install uninstall

all:

install: $(INSTALL_DIR)/$(TARGET)

uninstall:
	rm -f $(INSTALL_DIR)/$(TARGET)

### Executable =================================================================

$(INSTALL_DIR):
	mkdir -p $@

$(INSTALL_DIR)/$(TARGET): $(TARGET).sh $(INSTALL_DIR)
	install $< $@

