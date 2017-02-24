REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk

build:

install::
	/bin/mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	/bin/cp files/* $(ROOT)/$(PKGROOT)/

clean::
