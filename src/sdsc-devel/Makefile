REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk

build:

install::
	/bin/mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	/bin/cp Pull.mk RollStack.mk CommonRolls.mk $(ROOT)/$(PKGROOT)/
	/bin/cp Makefile.abat.vanilla $(ROOT)/$(PKGROOT)/
	/bin/cp sdsc-Rules.mk $(ROOT)/$(PKGROOT)/Rules.mk
	/bin/cp package-version-check.{py,ini} $(ROOT)/$(PKGROOT)/
	/bin/cp copyright-storm.{sh,txt} $(ROOT)/$(PKGROOT)/
	/bin/cp module-inspect $(ROOT)/$(PKGROOT)/

clean::
