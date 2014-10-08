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
COMPILER = $(CC)

BOOSTSETUP = \
  module load boost || true; \
  echo === BOOSTHOME ===; \
  echo $${BOOSTHOME}

COMPILERSETUP = \
  module load $(ROLLCOMPILER) || true; \
  echo === Compiler and version ===; \
  $(COMPILER) --version

ifeq ("$(ROLLNETWORK)", "eth")
  MPIMODULE = $(ROLLMPI)
else
  MPIMODULE = $(ROLLMPI)_$(ROLLNETWORK)
endif

MPISETUP = \
  module load $(MPIMODULE) || true; \
  echo === MPIHOME ===; \
  echo $${MPIHOME}

GET_MODULE_VERSION = \
  `module display $(1) 2>&1 | grep -i version | grep -om1 '[0-9].*'`
