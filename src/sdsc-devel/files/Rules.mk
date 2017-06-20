ifndef __SDSCDEVEL_ROLL_MK
__SDSCDEVEL_ROLL_MK = yes

# This file packages a collection of gmake targets, variables and macros used
# in the construction of SDSC application Rocks rolls.
#
# Provided definitions include:
#
# * Settings for CC/CXX/F77/FC make variables determined by $(COMPILERNAME)
#
# * BIND_MOUNT(1,2) - macro that produces recipe steps to create dir $(1) and 
#   bind mount it to $(2)
#   BIND_UMOUNT(1) - macro that produces recipe steps to umount and remove $(1)
#
# * CHECK_LICENSE_FILES - variable containing recipe steps to check the files
#   in license-files/ against the same files in $(SOURCE_DIR).  Exits with
#   failure if any of the files differ.
#
# * DESCRIBE_{CC,CXX,F77,FC,PYTHON,MPI,PKG,BOOST,CUDA,EIGEN,FFTW,GMP,HDF4,HDF5,LAPACK,MKL,NETCDF,R} -
#   variables that contain recipe steps to extract and echo package information
#   for incusion in a DESCRIPTION file.
#
# * DESCRIBE_PKG - variable containing recipe steps to echo information about
#   package being built for inclusion in a DESCRIPTION file.
#
# * INSTALL_LICENSE_FILES - variable containing recipe steps to create a dir
#   in $(ROOT)/$(PKGROOT) to hold package licenses and copy the contents of
#   license-files/ into it
#
# * MODULE_LOAD_COMPILER(1,2) - macro that produces recipe steps to load
#   modulefile $(1) and run exe $(2) to report its version
#
# * MODULE_LOAD_PACKAGE(1,2) - macro that produces recipe steps to load
#   modulefile $(1) and echo the value of environment variable $(2)
#
# * MODULE_LOAD_{CC,CXX,F77,FC,PYTHON,MPI,PKG,BOOST,CUDA,EIGEN,FFTW,GMP,HDF4,HDF5,LAPACK,MKL,NETCDF,R} -
#   variables that contain recipe steps to load specific modulefiles
#
# * PKGROOT_BIND_{MOUNT,UMOUNT} - variables that contain recipe steps to create
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

BIND_MOUNT = mkdir -p -m 755 $(1) || true; mount --bind $(2) $(1)
BIND_UMOUNT = umount $(1); rmdir -p $(1) || true

CHECK_LICENSE_FILES = \
  if test -d license-files; then \
    for F in `find license-files -mindepth 1 -type f`; do \
      echo Checking $$F for changes; \
      /usr/bin/cmp $$F `echo $$F | sed 's/license-files/$(SOURCE_DIR)/'` || exit 2; \
    done; \
  else \
    echo WARNING: no license-files directory found; \
  fi

DESCRIBE_CC = echo built with $(CC) $(call GET_EXE_VERSION, $(CC))
DESCRIBE_CXX = echo built with $(CXX) $(call GET_EXE_VERSION, $(CXX))
DESCRIBE_F77 = echo built with $(F77) $(call GET_EXE_VERSION, $(F77))
DESCRIBE_FC = echo built with $(FC) $(call GET_EXE_VERSION, $(FC))

DESCRIBE_PYTHON = echo built with python $(call GET_EXE_VERSION, python)

DESCRIBE_MPI = echo built with $(ROLLMPI) $(call GET_MODULE_VERSION, $(ROLLMPI))

DESCRIBE_PKG = \
  echo $(NAME) $(VERSION); \
  if test -n "$(ROLLOPTS)"; then \
    echo built with ROLLOPTS=$(ROLLOPTS); \
  fi

DESCRIBE_BOOST = echo built with boost $(call GET_MODULE_VERSION, boost)
DESCRIBE_CUDA = echo built with cuda $(call GET_MODULE_VERSION, cuda)
DESCRIBE_EIGEN = echo built with eigen $(call GET_MODULE_VERSION, eigen)
DESCRIBE_FFTW = echo built with fftw $(call GET_MODULE_VERSION, fftw)
DESCRIBE_GMP = echo built with gmp $(call GET_MODULE_VERSION, gmp)
DESCRIBE_HDF4 = echo built with hdf4 $(call GET_MODULE_VERSION, hdf4)
DESCRIBE_HDF5 = echo built with hdf5 $(call GET_MODULE_VERSION, hdf5)
DESCRIBE_LAPACK = echo built with lapack $(call GET_MODULE_VERSION, lapack)
DESCRIBE_MKL = echo built with mkl $(call GET_MODULE_VERSION, mkl)
DESCRIBE_NETCDF = echo built with netcdf $(call GET_MODULE_VERSION, netcdf)
DESCRIBE_R = echo built with R $(call GET_MODULE_VERSION, R)
DESCRIBE_SCIPY = echo built with scipy $(call GET_MODULE_VERSION, scipy)

# Macro to extract the version from running $(1) with --version
GET_EXE_VERSION = \
  `$(1) --version 2>&1 | perl -ne 'print($$1) and exit if m/(\d+(\.\d+)*)/'`

# Macro to extract the version from the whatis text of modulefile $(1)
GET_MODULE_VERSION = \
  `module display $(1) 2>&1 | perl -ne 'print($$2) and exit if m/whatis\s*(version|$(1))\D+(\d+(\.\d+)*)/i'`

INSTALL_LICENSE_FILES = \
  if test -d license-files; then \
    mkdir -p -m 755 $(ROOT)/$(PKGROOT)/license-info/$(NAME); \
    cp -r license-files/* $(ROOT)/$(PKGROOT)/license-info/$(NAME)/; \
  else \
    echo WARNING: no license-files directory found; \
  fi

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

MODULE_LOAD_PYTHON = $(call MODULE_LOAD_COMPILER, $(ROLLPY), python)

MODULE_LOAD_BOOST = $(call MODULE_LOAD_PACKAGE, boost, BOOSTHOME)
MODULE_LOAD_CMAKE = $(call MODULE_LOAD_PACKAGE, cmake, CMAKEHOME)
MODULE_LOAD_CUDA = $(call MODULE_LOAD_PACKAGE, cuda, CUDAHOME)
MODULE_LOAD_EIGEN = $(call MODULE_LOAD_PACKAGE, eigen, EIGENHOME)
MODULE_LOAD_FFTW = $(call MODULE_LOAD_PACKAGE, fftw, FFTWHOME)
MODULE_LOAD_GMP = $(call MODULE_LOAD_PACKAGE, gmp, GMPHOME)
MODULE_LOAD_HDF4 = $(call MODULE_LOAD_PACKAGE, hdf4, HDF4HOME)
MODULE_LOAD_HDF5 = $(call MODULE_LOAD_PACKAGE, hdf5, HDF5HOME)
MODULE_LOAD_LAPACK = $(call MODULE_LOAD_PACKAGE, lapack, LAPACKHOME)
MODULE_LOAD_MKL = $(call MODULE_LOAD_PACKAGE, mkl, MKLHOME)
MODULE_LOAD_NETCDF = $(call MODULE_LOAD_PACKAGE, netcdf, NETCDFHOME)
MODULE_LOAD_R = $(call MODULE_LOAD_PACKAGE, R, RHOME)
MODULE_LOAD_SCIPY = $(call MODULE_LOAD_PACKAGE, scipy, SCIPYHOME)

PKGROOT_BIND_MOUNT = $(call BIND_MOUNT, $(PKGROOT), $(ROOT)/$(PKGROOT))

PKGROOT_BIND_UMOUNT = $(call BIND_UMOUNT, $(PKGROOT))

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
	           -e 's#MPINAME#$(MPINAME)#g;' \
	           -e 's#ROLLCOMPILER#$(ROLLCOMPILER)#g;' \
	           -e 's#ROLLMPI#$(ROLLMPI)#g;' \
	           -e 's#ROLLOPTS#$(ROLLOPTS)#g;' \
	           -e 's#ROLLPY#$(ROLLPY)#g;' \
	           -e "s#VERSION#$$V#g;" \
	    $(ROOT)/$(PKGROOT)/.version.$$V $(ROOT)/$(PKGROOT)/$$V; \
	done
	ln -s $(PKGROOT)/.version.$(VERSION) $(ROOT)/$(PKGROOT)/.version

endif # __SDSCDEVEL_ROLL_MK
