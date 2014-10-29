ifndef __SDSCDEVEL_ROLL_MK
__SDSCDEVEL_ROLL_MK = yes

# This file packages a collection of gmake recipes, variables and macros used
# in the construction of SDSC application Rocks rolls.

# Compilers as determined by COMPILERNAME, which defaults to gnu
CC = gcc
CXX = g++
F77 = gfortran
FC = gfortran
ifeq ("$(COMPILERNAME)", "intel")
  CC = icc
  CXX = icpc
  F77 = ifort
  FC = ifort
else ifeq ("$(COMPILERNAME)", "pgi")
  CC = pgcc
  CXX = pgCC
  F77 = pgf77
  FC = pgf90
endif

# Macro to extract the version from running a program (arg1) with --version
GET_EXE_VERSION = \
  `$(1) --version 2>&1 | perl -ne 'print($$1) and exit if m/(\d+(\.\d+)*)/'`

# Macro to extract the version from a modulefile's (arg1) whatis text
GET_MODULE_VERSION = \
  `module display $(1) 2>&1 | perl -ne 'print($$1) and exit if m/version\D*(\d+(\.\d+)*)/i'`

# Macro to load a modulefile (arg1) and print the version returned from running
# the a compiler (arg2) w/--version
MODULE_LOAD_COMPILER = \
  module load $(1) || true; \
  echo === Compiler and version ===; \
  $(2) --version

# Macro to load a modulefile (arg1) and print the value of the an environment
# variable (arg2)
MODULE_LOAD_PACKAGE = \
  module load $(1) || true; \
  echo === $(2) ===; \
  echo $${$(strip $(2))}

# Macro to load the modulefile named in $(ROLLCOMPILER) and print the $(CC) version
MODULE_LOAD_CC = $(call MODULE_LOAD_COMPILER, $(ROLLCOMPILER), $(CC))

# Macro to load boost and print its version
MODULE_LOAD_BOOST = $(call MODULE_LOAD_PACKAGE, boost, BOOSTHOME)

# Macro to load the modulefile named in $(ROLLMPI) and print $${MPIHOME}
MODULE_LOAD_MPI = $(call MODULE_LOAD_PACKAGE, $(ROLLMPI), MPIHOME)

# Recipe for including boost in the application DESCRIPTION file
desc-boost:
	$(COMPILERSETUP) >> /dev/null; \
	echo boost $(call GET_MODULE_VERSION, boost) >> DESCRIPTION

# Recipe for including $(CC) in the application DESCRIPTION file
desc-cc:
	$(COMPILERSETUP) >> /dev/null; \
	echo $(ROLLCOMPILER) $(call GET_EXE_VERSION, $(CC)) >> DESCRIPTION

# Recipe for including $(ROLLMPI) in the application DESCRIPTION file
desc-mpi:
	$(COMPILERSETUP) >> /dev/null; \
	echo $(ROLLMPI) $(call GET_MODULE_VERSION, $(ROLLMPI)) >> DESCRIPTION

# Recipe for including the package name and version in the application DESCRIPTION file
desc-pkg:
	echo $(NAME) $(VERSION) built using >> DESCRIPTION

# Standard recipe for a roll's roll-test install step
roll-test-install:
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	cp *.t $(ROOT)/$(PKGROOT)/
	perl -pi -e 's#COMPILERNAME#$(COMPILERNAME)#g;' \
	         -e 's#ROLLCOMPILER#$(ROLLCOMPILER)#g;' \
	         -e 's#ROLLMPI#$(ROLLMPI)#g;' \
	         -e 's#ROLLNETWORK#$(ROLLNETWORK)#g;' \
	         -e 's#ROLLPY#$(ROLLPY)#g;' \
	         -e 's#VERSION#$(VERSION)#g;' \
	  $(ROOT)/$(PKGROOT)/*.t

# Standard recipe for extracting version.inc from a package's version.mk
$(VERSION_INC): $(VERSION_SRC)
	/bin/grep 'VERSION.*=' $(VERSION_SRC) > $@
 
# Standard recipe for a roll's modulefile install step
modulefile-install:
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	for V in $(VERSION) $(VERSION_ADD); do \
	  cp *.module $(ROOT)/$(PKGROOT)/$$V; \
	  cp *.version $(ROOT)/$(PKGROOT)/.version.$$V; \
	  perl -pi -e 's#COMPILERNAME#$(COMPILERNAME)#g;' \
	           -e 's#ROLLCOMPILER#$(ROLLCOMPILER)#g;' \
	           -e 's#ROLLMPI#$(ROLLMPI)#g;' \
	           -e 's#ROLLNETWORK#$(ROLLNETWORK)#g;' \
	           -e 's#ROLLPY#$(ROLLPY)#g;' \
	           -e "s#VERSION#$$V#g;" \
	    $(ROOT)/$(PKGROOT)/.version.$$V $(ROOT)/$(PKGROOT)/$$V; \
	done
	ln -s $(PKGROOT)/.version.$(VERSION) $(ROOT)/$(PKGROOT)/.version

endif # __SDSCDEVEL_ROLL_MK
