ifndef __SDSCDEVEL_ROLLSTACK_MK
__SDSCDEVEL_ROLLSTACK_MK = yes

# This file packages a collection of gmake targets, vars and macros used in the
# construction of sets of Rocks rolls that follow SDSC building conventions.
# It is intended to be used at a directory level above any roll source tree,
# e.g., as part of an automated roll build-and-test system.
#
# Makefiles that include this file should invoke the ROLLDEF function once for
# each roll of interest; it sets make vars used by the various target recipes.
# An example invocation might be
#
# $(call ROLLDEF,abyss,ROLLCOMPILER=gnu,ROLLMPI=openmpi_ib)
#
# The first argument to ROLLDEF is the roll name.  This is optionally followed
# by one or more arguments that specify name=value pairs associated with the
# roll.  Recognized names in these pairs are
#
# * GET - the recipe steps used for fetching this roll's source.  Within this
#   recipe, the make var $(1) refers to the roll name.
# * PREREQS - a list of rolls that must be installed before this roll can be
#   built.  Any ROLLCOMPILER, ROLLMPI (not including rocks-openmpi), and ROLLPY
#   values are added to this list automatically.
# * ROLLCOMPILER - the ROLLCOMPILER value passed to the roll's make invocation
# * ROLLMPI - the ROLLMPI value passed to the roll's make invocation
# * ROLLOPTS - the ROLLOPTS value passed to the roll's make invocation
# * ROLLPY - the ROLLPY value passed to the roll's make invocation
# * PUT - the recipe steps used for committing changes to this roll's source,
#   evaluated from within the roll dir.
# * USER - the user used to run the roll's test
#
# ROLLDEF uses a default value for any of these that are not specified in the
# argument list, taken from the make vars DEFAULT_GET, DEFAULT_ROLLCOMPILER,
# etc.  These default vars can be defined before including RollStack.mk;
# otherwise, their values are
#
# * DEFAULT_GET = (empty)
# * DEFAULT_PREREQS = (empty)
# * DEFAULT_PUT = (empty)
# * DEFAULT_ROLLCOMPILER = gnu
# * DEFAULT_ROLLMPI = rocks-openmpi
# * DEFAULT_ROLLOPTS = (empty)
# * DEFAULT_ROLLPY = (empty)
# * DEFAULT_USER = $(USER)
#
# After ROLLDEF has been invoked, the following make targets are defined for
# the roll ('%' stands for the roll name).
#
# %-build - make the roll's default target
# %-commit - commit changes to the roll source
# %-distclean - make the roll's distclean target
# %-install - install the rpms produced by the roll build.  No post sections
#   from the roll's node file(s) are executed.
# %-packages - display the packages installed by the roll--for debugging.
# %-prereqs - build and install any prerequisite rolls
# %-purge - remove the roll source
# %-roll - use the roll's GET value to fetch the roll source
# %-test - run /root/rolltests/%.t
# %-uninstall - uninstall the rpms produced by the roll build.
# %-vars - display the variable values associated with the roll--for debugging.


ifndef DEFAULT_GET
  DEFAULT_GET =
endif
ifndef DEFAULT_PREREQS
  DEFAULT_PREREQS =
endif
ifndef DEFAULT_PUT
  DEFAULT_PUT =
endif
ifndef DEFAULT_ROLLCOMPILER
  DEFAULT_ROLLCOMPILER = gnu
endif
ifndef DEFAULT_ROLLMPI
  DEFAULT_ROLLMPI = rocks-openmpi
endif
ifndef DEFAULT_ROLLOPTS
  DEFAULT_ROLLOPTS =
endif
ifndef DEFAULT_ROLLPY
  DEFAULT_ROLLPY =
endif
ifndef DEFAULT_USER
  DEFAULT_USER = $(USER)
endif

ROLLDEF = \
  $(eval $(1)_GET = $(DEFAULT_GET)) \
  $(eval $(1)_PUT = $(DEFAULT_PUT)) \
  $(eval $(1)_ROLLCOMPILER = $(DEFAULT_ROLLCOMPILER)) \
  $(eval $(1)_ROLLMPI = $(DEFAULT_ROLLMPI)) \
  $(eval $(1)_ROLLOPTS = $(DEFAULT_ROLLOPTS)) \
  $(eval $(1)_ROLLPY = $(DEFAULT_ROLLPY)) \
  $(eval $(1)_USER = $(DEFAULT_USER)) \
  $(if $2,$(eval $(1)_$(2))) \
  $(if $3,$(eval $(1)_$(3))) \
  $(if $4,$(eval $(1)_$(4))) \
  $(if $5,$(eval $(1)_$(5))) \
  $(if $6,$(eval $(1)_$(6))) \
  $(if $7,$(eval $(1)_$(7))) \
  $(if $8,$(eval $(1)_$(8))) \
  $(if $9,$(eval $(1)_$(9))) \
  $(eval $(1)_MAKE = $(MAKE) $(if $($(1)_ROLLCOMPILER),ROLLCOMPILER="$($(1)_ROLLCOMPILER)") $(if $($(1)_ROLLMPI),ROLLMPI="$($(1)_ROLLMPI)") $(if $($(1)_ROLLPY),ROLLPY="$($(1)_ROLLPY)") $(if $($(1)_ROLLOPTS),ROLLOPTS="$($(1)_ROLLOPTS)")) \
  $(eval $(1)_PREREQS += $(subst gnu,gnucompiler,$($(1)_ROLLCOMPILER)) $(patsubst %,mpi,$(subst rocks-openmpi,,$($(1)_ROLLMPI))) $(patsubst %,python,$($(1)_ROLLPY))) \
  $(foreach prereq,$($(1)_PREREQS),$(if $(filter $(prereq),$(ALL_PREREQS)),,$(eval ALL_PREREQS += $(prereq))))

THIS_MAKEFILE = $(firstword $(MAKEFILE_LIST))

%-build: %-roll/RPMS/TIMESTAMP
	

%-commit: %-roll
	put='$($(*)_PUT)'; \
	if test -z "$$put"; then \
	  put='$(call DEFAULT_PUT,$(*))'; \
	fi; \
	cd $(*)-roll; eval "$$put"

%-distclean:
	if test -d $*-roll; then \
	  cd $*-roll; \
	  $($(*)_MAKE) distclean; \
	fi

%-install: /root/rolltests/%.t
	

%-prereqs:
	for PREREQ in $(patsubst %,/root/rolltests/%.t,$($(*)_PREREQS)); do \
	  $(MAKE) -f $(THIS_MAKEFILE) $$PREREQ; \
	done

%-purge:
	/bin/rm -fr $*-roll

%-roll:
	get='$($(*)_GET)'; \
	if test -z "$$get"; then \
	  get='$(call DEFAULT_GET,$(*))'; \
	fi; \
	eval "$$get"

%-roll/RPMS/TIMESTAMP:
	$(MAKE) -f $(THIS_MAKEFILE) $*-prereqs
	$(MAKE) -f $(THIS_MAKEFILE) $*-roll
	cd $*-roll; \
	if test -x bootstrap.sh; then \
	  ./bootstrap.sh; \
	fi; \
	echo $($(*)_MAKE) > build.log 2>&1; \
	$($(*)_MAKE) >> build.log 2>&1
	if find $*-roll -name \*.iso; then \
	  touch $@; \
	fi

%-checknodes: %-roll/RPMS/TIMESTAMP
	packs=`/bin/cat $*-roll/nodes/* | \
	       /usr/bin/perl -n \
	         -e 'next unless ($$p) = /<package>\s*([^\s<]+)/;' \
	         -e 'map($$p =~ s/((\S*)COMPILERNAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLCOMPILER)"));' \
	         -e 'map($$p =~ s/((\S*)MPINAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLMPI)"));' \
	         -e '$$p =~ s/(\S*)(COMPILER|MPI)NAME(\S*)//g;' \
	         -e 'print "$$p ";' | sort | uniq`; \
	built=`ls $*-roll/RPMS/*/*.rpm`; \
	for F in $$packs roll-$*-kickstart; do \
	  built=`echo $$built | sed "s/[^ ]*\/$$F-[^ ]* *//"`; \
	done; \
	if test -n "$$built"; then \
	  echo "WARNING: rpm(s) '$$built' not referenced in node file(s)"; \
	fi

/root/rolltests/%.t: %-roll/RPMS/TIMESTAMP
	$(MAKE) -f $(THIS_MAKEFILE) $*-checknodes
	for F in $*-roll/RPMS/*/*.rpm; do \
	  rpm -i --nodeps $$F || true; \
	done
	for F in `/usr/bin/perl -ne 'next if /sdsc-/; print "$$1\n" if /([^>\s]+)\s*<\/package>/' $*-roll/nodes/*`; do \
	  /usr/bin/yum install $$F; \
	done
	if test -f $@; then \
	  touch $@; \
	fi

%-test: /root/rolltests/%.t
	cd ~$($(*)_USER); \
	su -c "$< Compute" $($(*)_USER)

%-uninstall: %-roll
	packs=`/bin/cat $*-roll/nodes/* | \
	       /usr/bin/perl -n \
	         -e 'next unless ($$p) = /<package>\s*([^\s<]+)/;' \
	         -e 'map($$p =~ s/((\S*)COMPILERNAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLCOMPILER)"));' \
	         -e 'map($$p =~ s/((\S*)MPINAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLMPI)"));' \
	         -e 'map($$p =~ s/((\S*)PYVERSION(\S*))/$${2}2.7$$3 $$1/g, split(/\s+/, "$($(*)_ROLLPY)"));' \
	         -e '$$p =~ s/(\S*)(COMPILERNAME|MPINAME|PYVERSION)(\S*)//g;' \
	         -e 'print "$$p ";' | sort | uniq`; \
	for F in $$packs roll-$*-kickstart; do \
	  rpm -e --nodeps $$F > /dev/null 2>&1 || true; \
	done

%-vars:
	@echo $(*)_GET '$($(*)_GET)'
	@echo $(*)_MAKE '$($(*)_MAKE)'
	@echo $(*)_PREREQS '$($(*)_PREREQS)'
	@echo $(*)_PUT '$($(*)_PUT)'
	@echo $(*)_ROLLCOMPILER '$($(*)_ROLLCOMPILER)'
	@echo $(*)_ROLLMPI '$($(*)_ROLLMPI)'
	@echo $(*)_ROLLOPTS '$($(*)_ROLLOPTS)'
	@echo $(*)_ROLLPY '$($(*)_ROLLPY)'
	@echo ALL_PREREQS $(ALL_PREREQS)

%-packages: %-roll
	packs=`/bin/cat $*-roll/nodes/* | \
	       /usr/bin/perl -n \
	         -e 'next unless ($$p) = /<package>\s*([^\s<]+)/;' \
	         -e 'map($$p =~ s/((\S*)COMPILERNAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLCOMPILER)"));' \
	         -e 'map($$p =~ s/((\S*)MPINAME(\S*))/$$2$$_$$3 $$1/g, split(/\s+/, "$($(*)_ROLLMPI)"));' \
	         -e 'map($$p =~ s/((\S*)PYVERSION(\S*))/$${2}2.7$$3 $$1/g, split(/\s+/, "$($(*)_ROLLMPI)"));' \
	         -e '$$p =~ s/(\S*)(COMPILERNAME|MPINAME|PYVERSION)(\S*)//g;' \
	         -e 'print "$$p ";'`; \
	echo $$packs

# Tell gmake not to delete any targets when created as intermediates
.PRECIOUS: %-roll %-roll/RPMS/TIMESTAMP /root/rolltests/%.t
	

endif # __SDSCDEVEL_ROLLSTACK_MK
