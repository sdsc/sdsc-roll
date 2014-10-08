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

LOAD_COMPILER_MODULE = \
  module load $(1) || true; \
  echo === Compiler and version ===; \
  $(2) --version

LOAD_PACKAGE_MODULE = \
  module load $(1) || true; \
  echo === $(2) ===; \
  echo $${$(strip $(2))}

GET_COMPILER_VERSION = \
  `$(1) --version 2>&1 | grep -m1 -o '[0-9][0-9]*\.[0-9][^ ]*'`

GET_MODULE_VERSION = \
  `module display $(1) 2>&1 | grep -i version | grep -om1 '[0-9].*'`
