REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk

build:

install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	install -m 755 *.sh $(ROOT)/$(PKGROOT)
	install -m 755 *.csh $(ROOT)/$(PKGROOT)
	mkdir -p -m 755 $(ROOT)/opt/modulefiles

clean::
