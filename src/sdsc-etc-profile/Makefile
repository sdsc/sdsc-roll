REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk

build:

install::
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	cp *.sh $(ROOT)/$(PKGROOT)/
	cp *.csh $(ROOT)/$(PKGROOT)/

clean::
