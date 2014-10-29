ifndef __SDSCDEVEL_ROLL_MK
__SDSCDEVEL_ROLL_MK = yes

# This file packages a collection of gmake targets, variables and macros used
# in the construction of SDSC application Rocks rolls.
#
# Provided definitions include:
#
# * Settings for CC/CXX/F77/FC make variables determined by $(COMPILERNAME)
#
# * DESCRIBE_{CC,CXX,F77,FC,MPI,PKG,BOOST,CUDA,EIGEN,GMP} - variables that
#   contain recipe steps to extract and echo package information for incusion
#   in a DESCRIPTION file.
#
# * INSTALL_LICENSE_FILES - variable containing recipe steps to create a dir
#   in $(ROOT)/$(PKGROOT) to hold package licenses and copy the list of files
#   in $(LICENSE_FILES) into it
#
# * MODULE_LOAD_COMPILER(1,2) - macro that produces recipe steps to load
#   modulefile $(1) and run exe $(2) to report its version
#
# * MODULE_LOAD_PACKAGE(1,2) - macro that produces recipe steps to load
#   modulefile $(1) and echo the value of environment variable $(2)
#
# * MODULE_LOAD_{CC,CXX,F77,FC,MPI,PKG,BOOST,CUDA,EIGEN,GMP} - variables that
#   contain recipe steps to load specific modulefiles
#
# * PKGROOT_BIND{MOUNT,UMOUNT} - variables that contain recipe steps to create
#   $(PKGROOT) and mount it to $(ROOT)/$(PKGROOT), umount and destroy it.
#
# * typical-roll-test-install - build target for a standard roll-test install
#   recipe: cp *.t to $(ROOT)/$(PKGROOT); make substitutions for the standard
#   make vars--COMPILERNAME, MPINAME, ROLLCOMPILER, ROLLMPI, ROLLOPTS, ROLLPY,
#   VERSION
#
# * typical-modulefile-install - build target for a standard *-modules install
#   recipe: cp *.{module,version} to $(ROOT)/$(PKGROOT); make substitutions for
#   the standard make vars--COMPILERNAME, MPINAME, ROLLCOMPILER, ROLLMPI,
#   ROLLOPTS, ROLLPY, VERSION; link .version to copied version file.  Creates
#   multiple modulefile copies if the make variable EXTRA_MODULE_VERSIONS
#   contains a space-delimited set of additional modulefile versions.

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

DESCRIBE_CC = echo $(ROLLCOMPILER) $(call GET_EXE_VERSION, $(CC))
DESCRIBE_CXX = echo $(ROLLCOMPILER) $(call GET_EXE_VERSION, $(CXX))
DESCRIBE_F77 = echo $(ROLLCOMPILER) $(call GET_EXE_VERSION, $(F77))
DESCRIBE_FC = echo $(ROLLCOMPILER) $(call GET_EXE_VERSION, $(FC))

DESCRIBE_MPI = echo $(ROLLMPI) $(call GET_MODULE_VERSION, $(ROLLMPI))

DESCRIBE_PKG = echo $(NAME) $(VERSION) built using

DESCRIBE_BOOST = echo boost $(call GET_MODULE_VERSION, boost)
DESCRIBE_CUDA = echo cuda $(call GET_MODULE_VERSION, cuda)
DESCRIBE_EIGEN = echo eigen $(call GET_MODULE_VERSION, eigen)
DESCRIBE_GMP = echo gmp $(call GET_MODULE_VERSION, gmp)

# Macro to extract the version from running a program (arg1) with --version
GET_EXE_VERSION = \
  `$(1) --version 2>&1 | perl -ne 'print($$1) and exit if m/(\d+(\.\d+)*)/'`

# Macro to extract the version from a modulefile's (arg1) whatis text
GET_MODULE_VERSION = \
  `module display $(1) 2>&1 | perl -ne 'print($$1) and exit if m/version\D*(\d+(\.\d+)*)/i'`

INSTALL_LICENSE_FILES = \
  mkdir -p -m 755 $(ROOT)/$(PKGROOT)/license-info; \
  cp $(LICENSE_FILES) $(ROOT)/$(PKGROOT)/license-info

MODULE_LOAD_COMPILER = \
  module load $(1) || true; \
  echo === Compiler and version ===; \
  $(2) --version

MODULE_LOAD_PACKAGE = \
  module load $(1) || true; \
  echo === $(2) ===; \
  echo $${$(strip $(2))}

MODULE_LOAD_CC = $(call MODULE_LOAD_COMPILER, $(ROLLCOMPILER), $(CC))
MODULE_LOAD_CXX = $(call MODULE_LOAD_COMPILER, $(ROLLCOMPILER), $(CXX))
MODULE_LOAD_F77 = $(call MODULE_LOAD_COMPILER, $(ROLLCOMPILER), $(F77))
MODULE_LOAD_FC = $(call MODULE_LOAD_COMPILER, $(ROLLCOMPILER), $(FC))

MODULE_LOAD_MPI = $(call MODULE_LOAD_PACKAGE, $(ROLLMPI), MPIHOME)

MODULE_LOAD_BOOST = $(call MODULE_LOAD_PACKAGE, boost, BOOSTHOME)
MODULE_LOAD_CMAKE = $(call MODULE_LOAD_PACKAGE, cmake, CMAKEHOME)
MODULE_LOAD_CUDA = $(call MODULE_LOAD_PACKAGE, cuda, CUDAHOME)
MODULE_LOAD_EIGEN = $(call MODULE_LOAD_PACKAGE, eigen, EIGENHOME)
MODULE_LOAD_GMP = $(call MODULE_LOAD_PACKAGE, gmp, GMPHOME)

PKGROOT_BIND_MOUNT = \
  mkdir -p -m 755 $(ROOT)/$(PKGROOT); \
  mkdir -p -m 755 $(PKGROOT) || true; \
  mount --bind $(ROOT)/$(PKGROOT) $(PKGROOT)

PKGROOT_BIND_UMOUNT = umount $(PKGROOT); rmdir -p $(PKGROOT) || true

typical-roll-test-install:
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	cp *.t $(ROOT)/$(PKGROOT)/
	perl -pi -e 's#COMPILERNAME#$(COMPILERNAME)#g;' \
	         -e 's#MPINAME#$(MPINAME)#g;' \
	         -e 's#ROLLCOMPILER#$(ROLLCOMPILER)#g;' \
	         -e 's#ROLLMPI#$(ROLLMPI)#g;' \
	         -e 's#ROLLOPTS#$(ROLLOPTS)#g;' \
	         -e 's#ROLLPY#$(ROLLPY)#g;' \
	         -e 's#VERSION#$(VERSION)#g;' \
	  $(ROOT)/$(PKGROOT)/*.t

typical-modulefile-install:
	mkdir -p -m 755 $(ROOT)/$(PKGROOT)
	for V in $(VERSION) $(EXTRA_MODULE_VERSIONS); do \
	  cp *.module $(ROOT)/$(PKGROOT)/$$V; \
	  cp *.version $(ROOT)/$(PKGROOT)/.version.$$V; \
	  perl -pi -e 's#COMPILERNAME#$(COMPILERNAME)#g;' \
	           -e 's#MPINAME#$(ROLLCOMPILER)#g;' \
	           -e 's#ROLLCOMPILER#$(ROLLCOMPILER)#g;' \
	           -e 's#ROLLMPI#$(ROLLMPI)#g;' \
	           -e 's#ROLLOPTS#$(ROLLOPTS)#g;' \
	           -e 's#ROLLPY#$(ROLLPY)#g;' \
	           -e "s#VERSION#$$V#g;" \
	    $(ROOT)/$(PKGROOT)/.version.$$V $(ROOT)/$(PKGROOT)/$$V; \
	done
	ln -s $(PKGROOT)/.version.$(VERSION) $(ROOT)/$(PKGROOT)/.version

endif # __SDSCDEVEL_ROLL_MK
