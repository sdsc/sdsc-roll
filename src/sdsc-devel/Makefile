REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk

build:

install::
	/bin/mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	/bin/cp {Modulefile,Package,Pull,RollTest}.mk $(ROOT)/$(PKGROOT)/
	/bin/cp package-version-check.{py,ini} $(ROOT)/$(PKGROOT)/

clean::
