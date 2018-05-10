ifndef __SDSCDEVEL_COMMONROLLS_MK
__SDSCDEVEL_COMMONROLLS_MK = yes

# Makes ROLLDEF calls (see RollStack.mk) for all SDSC rolls that aren't
# specific to a particular cluster.  include this file after including
# RollStack.mk and after defining these make vars:
#
# * MULTI_COMPILER - list of compiler modules to be loaded by rolls that can be
#     built and rolled with more than one compiler
# * MULTI_MPI - list of mpi modules to be loaded by rolls that can be built and
#     rolled with more than one mpi flavor
# * %-ROLLOPTS - optional package-specific ROLLOPTS values

# Implicit roll prereqs, not derived from ROLL{COMPILER,MPI,PY}
abyss_PREREQS = boost
amber_PREREQS = netcdf scipy
beast_PREREQS = beagle
biotools_PREREQS = boost cmake gnucompiler math scipy
cern_PREREQS = cmake gnucompiler
chemistry_PREREQS = cmake fftw netcdf
cilk_PREREQS = gnucompiler
cpmd_PREREQS = fftw
gaussian_PREREQS = pgi
geo_PREREQS = R
grace_PREREQS = fftw netcdf
gnutools_PREREQS = gnucompiler
guile_PREREQS = gnucompiler gnutools
jags_PREREQS = math R
llvm_PREREQS = cmake gnucompiler
math_PREREQS = cmake gnucompiler hdf
mpi_PREREQS = gnutools
mrbayes_PREREQS = beagle
ncar_PREREQS = hdf netcdf
ncl_PREREQS = hdf netcdf
netcdf_PREREQS = hdf
neuron_PREREQS = math
octave_PREREQS = fftw hdf
openbabel_PREREQS = cmake
p3dfft_PREREQS = fftw
polymake_PREREQS = boost gnucompiler
r-modules_PREREQS = netcdf R
scipy_PREREQS = llvm netcdf
siesta_PREREQS = hdf netcdf
trilinos_PREREQS = cmake
vasp_PREREQS = fftw
vmd_PREREQS = cmake netcdf
vtk_PREREQS = cmake

# Complete roll set categorized by ROLLCOMPILER value...
DEFAULT_COMPILER_ROLLS = \
  abinit abyss amber beagle beast biotools chemistry cilk cipres cpmd cryoem \
  dppdiv gamess geo grace jags migrate mpi4py mpiblast mrbayes ncar ncl neuron \
  nwchem octave phylobayes polymake python qe R r-modules raxml scipy siesta \
  upc vasp vmd vtk
MULTI_COMPILER_ROLLS = \
  atlas boost fftw fpmpi hdf math mpi netcdf p3dfft performance trilinos
NO_COMPILER_ROLLS = \
  beast2 blcr cern cmake data-transfer ddt fsa gaussian gnucompiler gnutools \
  guile hadoop idl intel intelmpi julia knime llvm molden mono nagios \
  openbabel pgi rapidminer qchem singularity slurm stata weka

# ... and again by ROLLMPI value.
DEFAULT_MPI_ROLLS = \
  abinit abyss amber biotools chemistry cpmd cryoem dppdiv gamess grace \
  migrate mpi4py mpiblast mrbayes ncar ncl neuron nwchem octave phylobayes qe \
  r-modules raxml siesta upc vasp vmd vtk
MULTI_MPI_ROLLS = \
  boost fftw fpmpi hdf math netcdf p3dfft performance trilinos
NO_MPI_ROLLS = \
  atlas beagle beast beast2 blcr cern cilk cipres cmake data-transfer ddt fsa \
  gaussian geo gnucompiler gnutools guile hadoop idl intel intelmpi jags \
  knime julia llvm molden mono mpi nagios openbabel pgi polymake python qchem \
  R rapidminer scipy singularity slurm stata weka

# Rolls that load the cuda module - presently documentation only, since we
# don't produce a cuda roll
CUDA_ROLLS = abinit amber beagle chemistry cryoem gaussian mpi scipy vasp

# Rolls that support ROLLPY make var
PYTHON_ROLLS = \
  amber biotools chemistry cryoem hdf julia llvm math mpi4py neuron openbabel \
  scipy trilinos vmd vtk

ALL_ROLLS = $(sort $(DEFAULT_COMPILER_ROLLS) $(MULTI_COMPILER_ROLLS) $(NO_COMPILER_ROLLS))

# Multi-compiler rolls known to have build failures w/the pgi compilers.
NO_PGI_ROLLS = atlas boost p3dfft performance trilinos

# Rolls not available from github, generally because of a paid license
RESTRICTED_ROLLS = \
  amber ddt gaussian idl intel intelmpi pgi qchem singularity slurm stata vasp

# gmake's handling of line continuations makes it difficult to format call
# invocations readably.  Placing the call into a variable to be passed to eval
# is at least better than squishing everything onto a single line.
DEFINE_ALL_ROLLS = \
$$(foreach roll,$$(ALL_ROLLS), \
  $$(call ROLLDEF, \
          $$(roll), \
          $$(if $$(filter $$(roll),$$(MULTI_COMPILER_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER)), \
          $$(if $$(filter $$(roll),$$(NO_PGI_ROLLS)),ROLLCOMPILER=$$(MULTI_COMPILER:pgi=)), \
          $$(if $$(filter $$(roll),$$(NO_COMPILER_ROLLS)),ROLLCOMPILER=), \
          $$(if $$(filter $$(roll),$$(MULTI_MPI_ROLLS)),ROLLMPI=$$(MULTI_MPI)), \
          $$(if $$(filter $$(roll),$$(NO_MPI_ROLLS)),ROLLMPI=), \
          $$(if $$(filter $$(roll),$$(PYTHON_ROLLS)),ROLLPY=python), \
          PREREQS=$$($$(roll)_PREREQS), \
          $$(if $$($$(roll)_ROLLOPTS),ROLLOPTS=$$($$(roll)_ROLLOPTS)), \
  ) \
)
comma := ,
empty :=
space := $(empty) $(empty)
$(eval $(subst $(comma)$(space),$(comma),$(DEFINE_ALL_ROLLS)))

# Bitbucket repos not packaged as rolls
# lustre-data-mover
# slurm

# SDSC devel roll; contains this file
# sdsc

# Comet-only
# matlab
# mlnx-ofed
# xsede-stats

# TSCC-only
# gold
# tscc-config
# tscc-private

# Rocks development
# img-storage
# json2roll

# Under development
# cuda
# rabbitmq

# TODO: orphaned?
# benchmarks
# git
# gordon-test-apps
# jmodeltest2
# lfs
# lustre
# lustre-sdsc
# node
# old-slurm
# perftest
# sdsc-sec
# triton-base - idea became sdsc-roll
# usetrax - abandoned
# wrf
# xsede-common
 
# Rolls marked as deprecated in README.md
# boltztrap - abandoned
# dataform - renamed netcdf
# db2 - abandoned
# fsl - abandoned
# garli - merged into raxml
# gdal - merged into geo
# geos - merged into geo
# mkl - merged into intel
# moab - abandoned
# mopac - 100-day license
# papi - merged into performance
# paraview - installation too complex
# plink - merged into biotools
# proj - merged into geo
# tecplot - abandoned
# visit - installation too complex

endif # __SDSCDEVEL_COMMONROLLS_MK
